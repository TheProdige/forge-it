-- Enable required extensions
create extension if not exists "uuid-ossp";
create extension if not exists "pg_trgm"; -- for search

-- ============================================
-- TABLES
-- ============================================

-- profiles table (extends auth.users)
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  full_name text,
  avatar_url text,
  bio text,
  category text check (category in ('saas','ecommerce','agency','construction','fitness','creator','freelancer','local_business','other')),
  country text,
  timezone text default 'UTC',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- follows table
create table public.follows (
  id uuid primary key default gen_random_uuid(),
  follower_id uuid not null references public.profiles(id) on delete cascade,
  following_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(follower_id, following_id),
  constraint no_self_follow check (follower_id != following_id)
);

-- goals table
create table public.goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  description text,
  status text not null default 'pending' check (status in ('pending', 'in_progress', 'completed')),
  target_date date,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- posts table
create table public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  image_url text,
  caption text check (char_length(caption) <= 500),
  linked_goal_id uuid references public.goals(id) on delete set null,
  goal_marked_complete boolean not null default false,
  posted_for_date date not null default current_date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint post_requires_content check (image_url is not null or (caption is not null and char_length(caption) > 0))
);

-- post_reactions table
create table public.post_reactions (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  reaction_type text not null check (reaction_type in ('grind', 'respect')),
  created_at timestamptz not null default now(),
  unique(post_id, user_id, reaction_type)
);

-- daily_checkins table
create table public.daily_checkins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  checkin_date date not null default current_date,
  post_id uuid references public.posts(id) on delete set null,
  created_at timestamptz not null default now(),
  unique(user_id, checkin_date)
);

-- user_stats table (denormalized for performance)
create table public.user_stats (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  current_streak int not null default 0,
  longest_streak int not null default 0,
  total_goals_completed int not null default 0,
  total_posts int not null default 0,
  updated_at timestamptz not null default now()
);

-- ============================================
-- INDEXES
-- ============================================

-- profiles
create index idx_profiles_username on public.profiles using btree (username);
create index idx_profiles_category on public.profiles using btree (category);
create index idx_profiles_username_trgm on public.profiles using gin (username gin_trgm_ops);
create index idx_profiles_full_name_trgm on public.profiles using gin (full_name gin_trgm_ops);

-- follows
create index idx_follows_follower on public.follows using btree (follower_id);
create index idx_follows_following on public.follows using btree (following_id);

-- goals
create index idx_goals_user_id on public.goals using btree (user_id);
create index idx_goals_status on public.goals using btree (user_id, status);
create index idx_goals_target_date on public.goals using btree (user_id, target_date);

-- posts
create index idx_posts_user_id on public.posts using btree (user_id);
create index idx_posts_posted_for_date on public.posts using btree (posted_for_date desc);
create index idx_posts_created_at on public.posts using btree (created_at desc);
create index idx_posts_user_date on public.posts using btree (user_id, posted_for_date desc);

-- post_reactions
create index idx_reactions_post_id on public.post_reactions using btree (post_id);
create index idx_reactions_user_id on public.post_reactions using btree (user_id);

-- daily_checkins
create index idx_checkins_user_date on public.daily_checkins using btree (user_id, checkin_date desc);
