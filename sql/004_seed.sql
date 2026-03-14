-- ============================================
-- SEED DATA (for development / testing)
-- Creates fake auth users first, then profiles, posts, etc.
-- Run this in Supabase SQL Editor (runs as superuser).
-- ============================================

do $$
declare
  id_alex uuid := 'a1b2c3d4-0001-0001-0001-000000000001';
  id_maya uuid := 'a1b2c3d4-0002-0002-0002-000000000002';
  id_carlos uuid := 'a1b2c3d4-0003-0003-0003-000000000003';
  id_zoe uuid := 'a1b2c3d4-0004-0004-0004-000000000004';
  id_marcus uuid := 'a1b2c3d4-0005-0005-0005-000000000005';
begin

-- ============================================
-- 1. CREATE AUTH USERS (required for FK constraint)
-- ============================================

insert into auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  recovery_token
)
values
  (id_alex,    '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'alex@forgeit.dev',   crypt('password123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"username":"alexbuilds","full_name":"Alex Chen"}', now(), now(), '', ''),
  (id_maya,    '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'maya@forgeit.dev',   crypt('password123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"username":"maya_ecom","full_name":"Maya Torres"}', now(), now(), '', ''),
  (id_carlos,  '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'carlos@forgeit.dev', crypt('password123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"username":"carloscontracts","full_name":"Carlos Rivera"}', now(), now(), '', ''),
  (id_zoe,     '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'zoe@forgeit.dev',    crypt('password123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"username":"zoe_agency","full_name":"Zoe Müller"}', now(), now(), '', ''),
  (id_marcus,  '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'marcus@forgeit.dev', crypt('password123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"username":"marcuslifts","full_name":"Marcus Powell"}', now(), now(), '', '')
on conflict (id) do nothing;

-- Also create identities (required for Supabase Auth to work)
insert into auth.identities (
  id,
  user_id,
  provider_id,
  identity_data,
  provider,
  last_sign_in_at,
  created_at,
  updated_at
)
values
  (id_alex,   id_alex,   id_alex::text,   jsonb_build_object('sub', id_alex::text,   'email', 'alex@forgeit.dev'),   'email', now(), now(), now()),
  (id_maya,   id_maya,   id_maya::text,    jsonb_build_object('sub', id_maya::text,   'email', 'maya@forgeit.dev'),   'email', now(), now(), now()),
  (id_carlos, id_carlos, id_carlos::text,  jsonb_build_object('sub', id_carlos::text, 'email', 'carlos@forgeit.dev'), 'email', now(), now(), now()),
  (id_zoe,    id_zoe,    id_zoe::text,     jsonb_build_object('sub', id_zoe::text,    'email', 'zoe@forgeit.dev'),    'email', now(), now(), now()),
  (id_marcus, id_marcus, id_marcus::text,  jsonb_build_object('sub', id_marcus::text, 'email', 'marcus@forgeit.dev'), 'email', now(), now(), now())
on conflict do nothing;

-- ============================================
-- 2. PROFILES (trigger may have created them, so upsert)
-- ============================================

insert into public.profiles (id, username, full_name, bio, category, country)
values
  (id_alex, 'alexbuilds', 'Alex Chen', 'Building ShipFast — SaaS for indie hackers. Day 847.', 'saas', 'US'),
  (id_maya, 'maya.ecom', 'Maya Torres', 'DTC founder. Scaled to $2M ARR. Obsessed with margins.', 'ecommerce', 'MX'),
  (id_carlos, 'carloscontracts', 'Carlos Rivera', 'General contractor turned tech entrepreneur. Build IRL and online.', 'construction', 'US'),
  (id_zoe, 'zoe.agency', 'Zoe Müller', 'Creative agency owner. 14 clients, 3-person team. Growing.', 'agency', 'DE'),
  (id_marcus, 'marcuslifts', 'Marcus Powell', 'Online fitness coaching. 200+ active clients. Building at 5am.', 'fitness', 'UK')
on conflict (id) do update set
  username = excluded.username,
  full_name = excluded.full_name,
  bio = excluded.bio,
  category = excluded.category,
  country = excluded.country;

-- ============================================
-- 3. USER STATS
-- ============================================

insert into public.user_stats (user_id, current_streak, longest_streak, total_goals_completed, total_posts)
values
  (id_alex, 14, 32, 87, 48),
  (id_maya, 7, 21, 53, 31),
  (id_carlos, 3, 12, 29, 18),
  (id_zoe, 21, 21, 112, 67),
  (id_marcus, 45, 61, 203, 89)
on conflict (user_id) do update set
  current_streak = excluded.current_streak,
  longest_streak = excluded.longest_streak,
  total_goals_completed = excluded.total_goals_completed,
  total_posts = excluded.total_posts;

-- ============================================
-- 4. GOALS
-- ============================================

insert into public.goals (user_id, title, status, target_date)
values
  (id_alex, 'Ship landing page v2', 'completed', current_date),
  (id_alex, 'Write 3 onboarding emails', 'pending', current_date),
  (id_alex, 'Fix Stripe webhook bug', 'completed', current_date),
  (id_maya, 'Review ad creatives for Q2', 'pending', current_date),
  (id_maya, 'Meet with fulfillment partner', 'completed', current_date),
  (id_carlos, 'Send quote for Henderson project', 'pending', current_date),
  (id_zoe, 'Client deck for Acme Corp', 'completed', current_date),
  (id_marcus, 'Record 4 workout videos', 'completed', current_date),
  (id_marcus, 'Reach out to 10 prospects', 'pending', current_date);

-- ============================================
-- 5. POSTS
-- ============================================

insert into public.posts (user_id, image_url, caption, posted_for_date, goal_marked_complete)
values
  (id_alex,
   'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800',
   'Shipped the new onboarding flow today. Cut drop-off from 68% to 41% in first tests. Pure execution.',
   current_date, false),
  (id_alex,
   'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=800',
   'Deep work session from 5am. Fixed the Stripe webhook that was killing MRR. Never skip the boring work.',
   current_date - 1, false),
  (id_maya,
   'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800',
   'New product launch prep. 3 SKUs, 2 colorways. Every detail matters at this scale.',
   current_date, false),
  (id_maya,
   'https://images.unsplash.com/photo-1553729459-efe14ef6055d?w=800',
   'Margin analysis done. Found 8% cost reduction with new supplier. That''s 160k/year recaptured.',
   current_date - 1, false),
  (id_carlos,
   'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800',
   'On site at 6am. Foundation pour starts today. This one''s a 2.4M build. Keep showing up.',
   current_date, false),
  (id_zoe,
   'https://images.unsplash.com/photo-1558655146-d09347e92766?w=800',
   'Finished the brand identity for Vantage client. 3 weeks of work compressed into a clean deck.',
   current_date, false),
  (id_zoe,
   'https://images.unsplash.com/photo-1542744094-3a31f272c490?w=800',
   'Running a 3-person agency means you do everything. Proposal writing at midnight. Just ship it.',
   current_date - 2, false),
  (id_marcus,
   'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
   '45 day streak. Not missing this no matter what. 4:58am alarm. Dark outside. Build anyway.',
   current_date, false);

-- ============================================
-- 6. FOLLOWS (create a network)
-- ============================================

insert into public.follows (follower_id, following_id)
values
  (id_alex, id_maya),
  (id_alex, id_zoe),
  (id_alex, id_marcus),
  (id_maya, id_alex),
  (id_maya, id_zoe),
  (id_maya, id_marcus),
  (id_carlos, id_alex),
  (id_carlos, id_marcus),
  (id_zoe, id_alex),
  (id_zoe, id_maya),
  (id_zoe, id_marcus),
  (id_marcus, id_alex),
  (id_marcus, id_zoe)
on conflict do nothing;

-- ============================================
-- 7. DAILY CHECKINS
-- ============================================

insert into public.daily_checkins (user_id, checkin_date)
values
  (id_alex, current_date),
  (id_alex, current_date - 1),
  (id_maya, current_date),
  (id_maya, current_date - 1),
  (id_carlos, current_date),
  (id_zoe, current_date),
  (id_zoe, current_date - 2),
  (id_marcus, current_date)
on conflict do nothing;

end $$;
