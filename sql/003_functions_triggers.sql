-- ============================================
-- HELPER: updated_at trigger function
-- ============================================

create or replace function public.handle_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Apply updated_at triggers
create trigger handle_updated_at_profiles
  before update on public.profiles
  for each row execute function public.handle_updated_at();

create trigger handle_updated_at_goals
  before update on public.goals
  for each row execute function public.handle_updated_at();

create trigger handle_updated_at_posts
  before update on public.posts
  for each row execute function public.handle_updated_at();

create trigger handle_updated_at_user_stats
  before update on public.user_stats
  for each row execute function public.handle_updated_at();

-- ============================================
-- AUTO-CREATE PROFILE + STATS ON SIGNUP
-- ============================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, username, full_name, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', 'user_' || substr(new.id::text, 1, 8)),
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'avatar_url', '')
  )
  on conflict (id) do nothing;

  insert into public.user_stats (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================
-- AUTO CHECKIN ON POST
-- ============================================

create or replace function public.handle_post_checkin()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  -- Create or update daily checkin
  insert into public.daily_checkins (user_id, checkin_date, post_id)
  values (new.user_id, new.posted_for_date, new.id)
  on conflict (user_id, checkin_date)
  do update set post_id = new.id;

  -- If goal completion requested, mark goal as completed
  if new.goal_marked_complete = true and new.linked_goal_id is not null then
    update public.goals
    set status = 'completed', completed_at = now()
    where id = new.linked_goal_id
      and user_id = new.user_id
      and status != 'completed';

    -- Increment total_goals_completed in user_stats
    insert into public.user_stats (user_id, total_goals_completed)
    values (new.user_id, 1)
    on conflict (user_id)
    do update set total_goals_completed = public.user_stats.total_goals_completed + 1;
  end if;

  -- Increment total_posts in user_stats
  insert into public.user_stats (user_id, total_posts)
  values (new.user_id, 1)
  on conflict (user_id)
  do update set total_posts = public.user_stats.total_posts + 1;

  return new;
end;
$$;

create trigger on_post_created
  after insert on public.posts
  for each row execute function public.handle_post_checkin();

-- ============================================
-- STREAK CALCULATION FUNCTION
-- ============================================

create or replace function public.compute_streak(p_user_id uuid)
returns int
language plpgsql
stable security definer set search_path = public
as $$
declare
  v_streak int := 0;
  v_check_date date := current_date;
  v_found bool;
begin
  loop
    select exists(
      select 1 from public.daily_checkins
      where user_id = p_user_id
        and checkin_date = v_check_date
    ) into v_found;

    exit when not v_found;

    v_streak := v_streak + 1;
    v_check_date := v_check_date - interval '1 day';
  end loop;

  return v_streak;
end;
$$;

-- ============================================
-- UPDATE STREAK FUNCTION (called by app after checkin)
-- ============================================

create or replace function public.refresh_user_streak(p_user_id uuid)
returns int
language plpgsql
security definer set search_path = public
as $$
declare
  v_streak int;
begin
  v_streak := public.compute_streak(p_user_id);

  insert into public.user_stats (user_id, current_streak, longest_streak)
  values (p_user_id, v_streak, v_streak)
  on conflict (user_id)
  do update set
    current_streak = v_streak,
    longest_streak = greatest(public.user_stats.longest_streak, v_streak);

  return v_streak;
end;
$$;

-- ============================================
-- DAILY PROGRESS SUMMARY FUNCTION
-- ============================================

create or replace function public.daily_progress_summary(p_user_id uuid, p_date date default current_date)
returns json
language plpgsql
stable security definer set search_path = public
as $$
declare
  v_total int;
  v_completed int;
  v_checked_in bool;
  v_post_id uuid;
begin
  -- Count today's goals (target_date = today or null = all active)
  select
    count(*) filter (where status != 'completed' or (status = 'completed' and completed_at::date = p_date)),
    count(*) filter (where status = 'completed' and completed_at::date = p_date)
  into v_total, v_completed
  from public.goals
  where user_id = p_user_id
    and (target_date = p_date or target_date is null)
    and created_at::date <= p_date;

  -- Check if user posted today
  select exists(
    select 1 from public.daily_checkins
    where user_id = p_user_id and checkin_date = p_date
  ) into v_checked_in;

  -- Get today's post_id if exists
  select post_id into v_post_id
  from public.daily_checkins
  where user_id = p_user_id and checkin_date = p_date;

  return json_build_object(
    'total_goals', coalesce(v_total, 0),
    'completed_goals', coalesce(v_completed, 0),
    'progress_pct', case when coalesce(v_total, 0) = 0 then 0
                         else round((coalesce(v_completed, 0)::numeric / v_total::numeric) * 100)
                    end,
    'checked_in_today', v_checked_in,
    'post_id', v_post_id
  );
end;
$$;

-- ============================================
-- FRIENDS FEED VIEW
-- ============================================

create or replace view public.friends_feed_view as
select
  p.*,
  pr.username,
  pr.full_name,
  pr.avatar_url,
  pr.category,
  coalesce(grind.cnt, 0) as grind_count,
  coalesce(respect.cnt, 0) as respect_count,
  us.current_streak
from public.posts p
join public.profiles pr on pr.id = p.user_id
left join (
  select post_id, count(*) as cnt
  from public.post_reactions
  where reaction_type = 'grind'
  group by post_id
) grind on grind.post_id = p.id
left join (
  select post_id, count(*) as cnt
  from public.post_reactions
  where reaction_type = 'respect'
  group by post_id
) respect on respect.post_id = p.id
left join public.user_stats us on us.user_id = p.user_id;

-- ============================================
-- EXPLORE FEED VIEW
-- ============================================

create or replace view public.explore_feed_view as
select
  p.*,
  pr.username,
  pr.full_name,
  pr.avatar_url,
  pr.category,
  coalesce(grind.cnt, 0) as grind_count,
  coalesce(respect.cnt, 0) as respect_count,
  us.current_streak
from public.posts p
join public.profiles pr on pr.id = p.user_id
left join (
  select post_id, count(*) as cnt
  from public.post_reactions
  where reaction_type = 'grind'
  group by post_id
) grind on grind.post_id = p.id
left join (
  select post_id, count(*) as cnt
  from public.post_reactions
  where reaction_type = 'respect'
  group by post_id
) respect on respect.post_id = p.id
left join public.user_stats us on us.user_id = p.user_id
order by p.created_at desc;

-- ============================================
-- GOAL COMPLETION (when toggled manually)
-- ============================================

create or replace function public.complete_goal(p_goal_id uuid, p_user_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  update public.goals
  set status = 'completed', completed_at = now()
  where id = p_goal_id
    and user_id = p_user_id
    and status != 'completed';

  if found then
    insert into public.user_stats (user_id, total_goals_completed)
    values (p_user_id, 1)
    on conflict (user_id)
    do update set total_goals_completed = public.user_stats.total_goals_completed + 1;
  end if;
end;
$$;

create or replace function public.uncomplete_goal(p_goal_id uuid, p_user_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  update public.goals
  set status = 'pending', completed_at = null
  where id = p_goal_id
    and user_id = p_user_id
    and status = 'completed';

  if found then
    update public.user_stats
    set total_goals_completed = greatest(0, total_goals_completed - 1)
    where user_id = p_user_id;
  end if;
end;
$$;
