-- ============================================
-- ENABLE RLS ON ALL TABLES
-- ============================================

alter table public.profiles enable row level security;
alter table public.follows enable row level security;
alter table public.goals enable row level security;
alter table public.posts enable row level security;
alter table public.post_reactions enable row level security;
alter table public.daily_checkins enable row level security;
alter table public.user_stats enable row level security;

-- ============================================
-- PROFILES POLICIES
-- ============================================

-- Anyone can read profiles (public network)
create policy "profiles_select_public"
  on public.profiles for select
  using (true);

-- Only owner can update their profile
create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Profile is created automatically via trigger (not directly by user)
create policy "profiles_insert_own"
  on public.profiles for insert
  with check (auth.uid() = id);

-- ============================================
-- FOLLOWS POLICIES
-- ============================================

-- Authenticated users can read follows
create policy "follows_select_authenticated"
  on public.follows for select
  to authenticated
  using (true);

-- Only the follower can create a follow
create policy "follows_insert_own"
  on public.follows for insert
  to authenticated
  with check (auth.uid() = follower_id);

-- Only the follower can delete their follow
create policy "follows_delete_own"
  on public.follows for delete
  to authenticated
  using (auth.uid() = follower_id);

-- ============================================
-- GOALS POLICIES
-- ============================================

-- Only owner can see their goals
create policy "goals_select_own"
  on public.goals for select
  to authenticated
  using (auth.uid() = user_id);

-- Only owner can insert goals
create policy "goals_insert_own"
  on public.goals for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Only owner can update goals
create policy "goals_update_own"
  on public.goals for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Only owner can delete goals
create policy "goals_delete_own"
  on public.goals for delete
  to authenticated
  using (auth.uid() = user_id);

-- ============================================
-- POSTS POLICIES
-- ============================================

-- Anyone can read posts (public feed)
create policy "posts_select_public"
  on public.posts for select
  using (true);

-- Only owner can insert posts
create policy "posts_insert_own"
  on public.posts for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Only owner can update posts
create policy "posts_update_own"
  on public.posts for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Only owner can delete posts
create policy "posts_delete_own"
  on public.posts for delete
  to authenticated
  using (auth.uid() = user_id);

-- ============================================
-- POST_REACTIONS POLICIES
-- ============================================

-- Anyone can read reactions
create policy "reactions_select_public"
  on public.post_reactions for select
  using (true);

-- Only owner can insert their reaction
create policy "reactions_insert_own"
  on public.post_reactions for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Only owner can delete their reaction
create policy "reactions_delete_own"
  on public.post_reactions for delete
  to authenticated
  using (auth.uid() = user_id);

-- ============================================
-- DAILY_CHECKINS POLICIES
-- ============================================

-- Authenticated users can read checkins
create policy "checkins_select_authenticated"
  on public.daily_checkins for select
  to authenticated
  using (true);

-- Only owner can insert checkin
create policy "checkins_insert_own"
  on public.daily_checkins for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Only owner can update checkin
create policy "checkins_update_own"
  on public.daily_checkins for update
  to authenticated
  using (auth.uid() = user_id);

-- ============================================
-- USER_STATS POLICIES
-- ============================================

-- Anyone can read user_stats
create policy "user_stats_select_public"
  on public.user_stats for select
  using (true);

-- Only the system (via triggers) or owner can update stats
-- We use security definer functions for updates, so no direct update policy needed
create policy "user_stats_update_own"
  on public.user_stats for update
  to authenticated
  using (auth.uid() = user_id);
