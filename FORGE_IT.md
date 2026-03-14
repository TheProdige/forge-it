# Forge It — V1 Complete Documentation

> **"Show what you're building today."**
> A daily grind network for entrepreneurs. Dark. Premium. Action-oriented.

---

## Table of Contents

1. [Vision & Product](#1-vision--product)
2. [Architecture](#2-architecture)
3. [Tech Stack](#3-tech-stack)
4. [Project Structure](#4-project-structure)
5. [Data Model](#5-data-model)
6. [Features V1](#6-features-v1)
7. [Design System](#7-design-system)
8. [Running Locally](#8-running-locally)
9. [Supabase Setup](#9-supabase-setup)
10. [Manual Test Checklist](#10-manual-test-checklist)
11. [Roadmap / V2 Ideas](#11-roadmap--v2-ideas)

---

## 1. Vision & Product

### What it is

Forge It is a **daily grind network** for entrepreneurs of all types — SaaS founders, contractors, e-commerce operators, agencies, fitness coaches, creators, freelancers, local business owners.

### Core promise

Every day, post one thing you worked on. A photo, a caption, or both. Link it to a goal. Show the world (or your network) that you're building.

### Why it's different from BeReal

| BeReal | Forge It |
|--------|----------|
| Social capture moment | Work accountability |
| Random dual-camera | Intentional work photo |
| Friends/fun social | Entrepreneur network |
| No goals system | Daily goals + streak |
| Likes | Grind / Respect reactions |
| Entertainment | Productivity + motivation |

### The loop

```
Post grind → Get reactions → See progress → Stay consistent → Post again
```

### User segments

- SaaS / startup founders
- E-commerce operators
- Agency owners
- Construction / trades entrepreneurs
- Fitness coaches
- Content creators
- Freelancers
- Local business owners

---

## 2. Architecture

### Pattern: MVVM + Service Layer

```
View → ViewModel (@Observable) → Service (async/await) → Supabase
```

- **Views** are SwiftUI structs. Pure UI. No business logic.
- **ViewModels** are `@Observable` classes marked `@MainActor`. Hold state, call services.
- **Services** are `@MainActor` singletons. Own Supabase queries. Return typed models.
- **Models** are `Codable` structs. Map directly to Supabase table rows.

### State management

- `@Observable` (iOS 17 macro) for ViewModels
- `AuthService.shared` as a global `ObservableObject` for session state
- No Redux/TCA — MVVM is sufficient for V1 scope
- Optimistic updates on reactions and follow/unfollow with server reconciliation

### Navigation

- `RootView` — top-level session router (splash → auth → onboarding → app)
- `MainTabView` — custom bottom tab bar (5 tabs)
- Each feature uses its own `NavigationStack`
- Sheets for: add goal, edit profile

---

## 3. Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Swift 5.10 |
| UI Framework | SwiftUI |
| Minimum iOS | iOS 17.0 |
| Backend | Supabase (Postgres + Auth + Storage) |
| SDK | supabase-swift v2.5+ |
| State | @Observable (iOS 17) |
| Async | async/await + structured concurrency |
| Project gen | XcodeGen |
| Image picker | PhotosUI (native) |
| Media storage | Supabase Storage |

---

## 4. Project Structure

```
forgeit/
├── FORGE_IT.md                    # This file
├── project.yml                    # XcodeGen project config
├── Configs/
│   ├── Debug.xcconfig
│   └── Release.xcconfig
├── sql/
│   ├── 001_schema.sql             # Tables + indexes
│   ├── 002_rls_policies.sql       # Row-level security
│   ├── 003_functions_triggers.sql # Functions, triggers, views
│   └── 004_seed.sql               # Dev seed data
└── ForgeIt/
    ├── App/
    │   ├── ForgeItApp.swift        # @main entry
    │   └── RootView.swift          # Session router
    ├── Navigation/
    │   └── MainTabView.swift       # Custom bottom tab bar
    ├── Models/
    │   ├── EntrepreneurCategory.swift
    │   ├── Profile.swift
    │   ├── Goal.swift
    │   ├── Post.swift
    │   ├── PostReaction.swift
    │   ├── DailyCheckin.swift
    │   ├── UserStats.swift
    │   └── FeedPost.swift          # Enriched feed model
    ├── Core/
    │   ├── Supabase/
    │   │   └── SupabaseManager.swift
    │   ├── DesignSystem/
    │   │   ├── AppColors.swift
    │   │   ├── AppTypography.swift
    │   │   └── AppSpacing.swift
    │   ├── Components/
    │   │   ├── UserAvatar.swift
    │   │   ├── EmptyState.swift
    │   │   ├── LoadingSkeleton.swift
    │   │   ├── StatPill.swift
    │   │   ├── SectionCard.swift
    │   │   └── FollowButton.swift
    │   └── Extensions/
    │       ├── Date+Extensions.swift
    │       └── View+Extensions.swift
    ├── Features/
    │   ├── Auth/
    │   │   ├── Services/AuthService.swift
    │   │   ├── ViewModels/
    │   │   │   ├── AuthViewModel.swift
    │   │   │   └── OnboardingViewModel.swift
    │   │   └── Views/
    │   │       ├── AuthRootView.swift
    │   │       ├── SignInView.swift
    │   │       ├── SignUpView.swift
    │   │       ├── Components/AppTextField.swift
    │   │       └── Onboarding/
    │   │           ├── OnboardingFlow.swift
    │   │           ├── OnboardingStepHeader.swift
    │   │           ├── UsernameStepView.swift
    │   │           ├── CategoryStepView.swift
    │   │           ├── BioStepView.swift
    │   │           └── DoneStepView.swift
    │   ├── Feed/
    │   │   ├── Services/FeedService.swift
    │   │   ├── ViewModels/FeedViewModel.swift
    │   │   └── Views/
    │   │       ├── FriendsView.swift
    │   │       └── Components/
    │   │           ├── PostCard.swift
    │   │           ├── PostHeader.swift
    │   │           ├── PostMedia.swift
    │   │           ├── PostCaption.swift
    │   │           ├── PostGoalBadge.swift
    │   │           └── ReactionBar.swift
    │   ├── Explore/
    │   │   ├── ViewModels/ExploreViewModel.swift
    │   │   └── Views/ExploreView.swift
    │   ├── Capture/
    │   │   ├── Services/PostService.swift
    │   │   ├── ViewModels/CaptureViewModel.swift
    │   │   └── Views/
    │   │       ├── CaptureView.swift
    │   │       └── Components/
    │   │           ├── ImageUploader.swift
    │   │           └── GoalLinkSelect.swift
    │   ├── Progress/
    │   │   ├── Services/GoalService.swift
    │   │   ├── ViewModels/ProgressViewModel.swift
    │   │   └── Views/
    │   │       ├── ForgeItProgressView.swift  ← used by nav (avoids SwiftUI conflict)
    │   │       └── Components/
    │   │           ├── StreakCard.swift
    │   │           ├── TodayCheckinCard.swift
    │   │           ├── DailyProgressCard.swift
    │   │           ├── GoalsList.swift
    │   │           ├── GoalItem.swift
    │   │           └── AddGoalSheet.swift
    │   └── Profile/
    │       ├── Services/ProfileService.swift
    │       ├── ViewModels/ProfileViewModel.swift
    │       └── Views/
    │           ├── ProfileView.swift
    │           ├── MyProfileView.swift
    │           ├── EditProfileView.swift
    │           └── Components/
    │               ├── ProfileHeader.swift
    │               ├── ProfileStats.swift
    │               └── UserPostsList.swift
    └── Resources/
        └── Info.plist
```

---

## 5. Data Model

### Tables

#### `profiles`
Extends `auth.users`. One row per user.

| Column | Type | Notes |
|--------|------|-------|
| id | uuid PK | references auth.users |
| username | text UNIQUE | min 3 chars, alphanumeric + underscore |
| full_name | text | optional display name |
| avatar_url | text | Supabase Storage URL |
| bio | text | max 160 chars |
| category | text | one of 9 entrepreneur types |
| country | text | ISO code e.g. "US" |
| timezone | text | IANA e.g. "America/New_York" |
| created_at | timestamptz | auto |
| updated_at | timestamptz | auto via trigger |

#### `posts`
A daily grind post.

| Column | Type | Notes |
|--------|------|-------|
| id | uuid PK | |
| user_id | uuid FK | references profiles |
| image_url | text | nullable |
| caption | text | max 500 chars, nullable |
| linked_goal_id | uuid FK | optional goal link |
| goal_marked_complete | bool | marks goal done on post |
| posted_for_date | date | date this grind is for |
| created_at / updated_at | timestamptz | auto |

Constraint: `image_url IS NOT NULL OR (caption IS NOT NULL AND length > 0)`

#### `goals`
Personal goals (private, only owner can read).

| Column | Type | Notes |
|--------|------|-------|
| id | uuid PK | |
| user_id | uuid FK | |
| title | text NOT NULL | |
| description | text | optional |
| status | text | pending / in_progress / completed |
| target_date | date | optional |
| completed_at | timestamptz | set on completion |

#### `follows`
Directed follow relationships.

| Column | Type | Notes |
|--------|------|-------|
| follower_id | uuid FK | |
| following_id | uuid FK | |
| UNIQUE | (follower_id, following_id) | |
| CHECK | follower_id != following_id | no self-follow |

#### `post_reactions`
Two reaction types only: grind (🔥) and respect (💪).

| Column | Type | Notes |
|--------|------|-------|
| post_id | uuid FK | |
| user_id | uuid FK | |
| reaction_type | text | grind OR respect |
| UNIQUE | (post_id, user_id, reaction_type) | one per type per user |

#### `daily_checkins`
One row per user per day. Created automatically by trigger on post insert.

| Column | Type | Notes |
|--------|------|-------|
| user_id | uuid FK | |
| checkin_date | date | |
| post_id | uuid FK | nullable — last post of that day |
| UNIQUE | (user_id, checkin_date) | |

#### `user_stats`
Denormalized stats for fast reads. Updated by triggers and RPC calls.

| Column | Type |
|--------|------|
| user_id | uuid PK FK |
| current_streak | int |
| longest_streak | int |
| total_goals_completed | int |
| total_posts | int |

### Key functions

| Function | Description |
|----------|-------------|
| `handle_new_user()` | Trigger on auth.users insert — creates profile + user_stats |
| `handle_post_checkin()` | Trigger on posts insert — creates daily_checkin, handles goal completion |
| `compute_streak(user_id)` | Walks backwards from today counting consecutive checkins |
| `refresh_user_streak(user_id)` | Calls compute_streak, updates user_stats |
| `daily_progress_summary(user_id, date)` | Returns JSON: goals total/completed, checkin status |
| `complete_goal(goal_id, user_id)` | Marks goal completed, increments stats |
| `uncomplete_goal(goal_id, user_id)` | Reverts completion |

### RLS Summary

| Table | Read | Write |
|-------|------|-------|
| profiles | Public | Own row only |
| follows | Authenticated | Own follows only |
| goals | Own only | Own only |
| posts | Public | Own only |
| post_reactions | Public | Own only |
| daily_checkins | Authenticated | Own only |
| user_stats | Public | Own only |

---

## 6. Features V1

### Auth
- Email + password signup/login via Supabase Auth
- Auto profile creation via database trigger on signup
- Session persistence (Supabase handles token refresh)
- Sign out

### Onboarding (3 steps)
1. **Username** — with real-time availability check, sanitization
2. **Category** — 9 entrepreneur types, 2-column grid
3. **Bio** — optional, 160 char limit, skip available

### Friends Feed
- Posts from followed users, paginated (20/page)
- Infinite scroll (loads more on last item appear)
- Pull to refresh
- Optimistic reactions (immediate UI update, server reconciliation)
- Optimistic follow/unfollow
- Empty state → CTA to Explore

### Explore
- All public posts, newest first
- Horizontal category chip filter (8 categories)
- Text search (username, full_name, caption)
- Follow button on each card
- Empty state adapts to context

### Capture
- Photo picker (PhotosUI — native, no permissions friction)
- Text caption (500 char limit, auto-resize textarea)
- Optional goal link (Menu picker)
- Mark goal complete toggle (appears only when goal linked)
- Validation: image OR non-empty caption required
- Upload image → Supabase Storage → create post record
- Success toast + form reset

### Progress
- **Streak card** — current streak, motivational phrase, best streak
- **Today check-in status** — posted vs not posted
- **Daily progress bar** — completed goals / total goals with animation
- **Goals list** — pending first, completed below, swipe to delete
- **Add goal sheet** — bottom sheet, auto-focus, add for today
- Pull to refresh

### Profile
- Public profile (avatar, name, username, bio, category, country)
- Follow counts (following / followers)
- Stats row (streak, goals done, total posts, best streak)
- Build history (chronological post list with thumbnails)
- Edit profile (avatar upload, display name, bio, category, country)
- Own profile shows "Edit" button; others show "Follow" button

### Reactions
- 🔥 Grind — "This is real work, respect the grind"
- 💪 Respect — "I see you, keep going"
- Toggle on/off, one of each type per user per post
- Optimistic UI

---

## 7. Design System

### Color Palette (Dark)

| Token | Hex | Usage |
|-------|-----|-------|
| bgPrimary | #0A0A0A | Main background |
| bgSecondary | #111111 | Elevated background |
| bgCard | #161616 | Card fills |
| bgElevated | #1C1C1C | Elevated elements |
| bgInput | #1F1F1F | Form inputs |
| textPrimary | #FFFFFF | Main text |
| textSecondary | #A0A0A0 | Secondary text |
| textMuted | #606060 | Timestamps, labels |
| accent | #E8FF5A | Electric lime — CTAs, active states |
| border | #282828 | Card borders |
| borderSubtle | #1E1E1E | Dividers |
| grindOrange | #FF6B35 | 🔥 reaction |
| respectBlue | #6BC8FF | 💪 reaction |
| success | #4ADE80 | Completed goals |
| error | #F87171 | Errors |
| streakFire | #FF9500 | Streak display |

### Typography Scale

| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| heading | 28 | Bold | Page headers |
| title1 | 24 | Bold | Section titles |
| title2 | 20 | Semibold | Card titles |
| title3 | 17 | Semibold | Subtitles |
| bodyLarge | 17 | Regular | Large body |
| body | 15 | Regular | Default body |
| bodySemibold | 15 | Semibold | Emphasized body |
| bodySmall | 13 | Regular | Small text |
| caption | 12 | Regular | Timestamps |
| captionBold | 12 | Semibold | Labels |
| labelSmall | 11 | Medium | Section headers (uppercase) |
| buttonLabel | 15 | Semibold | Buttons |

### Spacing Scale

```
xxs=2, xs=4, sm=8, md=16, lg=24, xl=32, xxl=48, xxxl=64
```

### Radius Scale

```
radiusXS=6, radiusSM=8, radiusMD=12, radiusLG=16, radiusXL=20, radiusFull=999
```

### View Modifiers (shortcuts)

```swift
.cardStyle()        // bgCard + radiusLG + borderSubtle
.elevatedCardStyle() // bgElevated + radiusLG + border
.primaryButton()    // accent bg + textInverse + h:52 + radiusMD
.secondaryButton()  // bgElevated bg + textPrimary + border + h:52
.screenBackground() // bgPrimary ignoring safe area
.shimmer()          // shimmer animation overlay
```

---

## 8. Running Locally

### Prerequisites

```bash
# Install Homebrew (macOS)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install XcodeGen
brew install xcodegen

# Install Supabase CLI (for local dev)
brew install supabase/tap/supabase

# Xcode 16+ required (iOS 17 SDK)
```

### 1. Clone and setup

```bash
cd /path/to/forgeit
```

### 2. Configure Supabase credentials

Create your Supabase project at https://supabase.com, then:

```bash
# Edit project.yml — fill in your credentials in the configs section:
# configs:
#   Debug:
#     SUPABASE_URL: "https://YOUR_PROJECT.supabase.co"
#     SUPABASE_ANON_KEY: "YOUR_ANON_KEY"
```

Or set them directly in `SupabaseManager.swift` for quick local testing:

```swift
client = SupabaseClient(
    supabaseURL: URL(string: "https://YOUR_PROJECT.supabase.co")!,
    supabaseKey: "YOUR_ANON_KEY"
)
```

### 3. Run SQL migrations

In your Supabase project dashboard → SQL Editor, run in order:

```sql
-- Run each file in sequence:
-- 1. sql/001_schema.sql
-- 2. sql/002_rls_policies.sql
-- 3. sql/003_functions_triggers.sql
-- 4. sql/004_seed.sql  (optional — for test data)
```

### 4. Configure Supabase Storage buckets

In Supabase dashboard → Storage, create:

1. **`avatars`** bucket — Public read, authenticated write
   - Allowed MIME types: `image/jpeg, image/png, image/webp`
   - Max file size: 5 MB

2. **`post-images`** bucket — Public read, authenticated write
   - Allowed MIME types: `image/jpeg, image/png, image/webp`
   - Max file size: 10 MB

Storage policies (run in SQL Editor):

```sql
-- avatars: anyone can read, authenticated users can upload to own folder
create policy "avatars_public_read" on storage.objects for select using (bucket_id = 'avatars');
create policy "avatars_upload_own" on storage.objects for insert to authenticated
  with check (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);
create policy "avatars_update_own" on storage.objects for update to authenticated
  using (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);

-- post-images: anyone can read, authenticated users can upload to own folder
create policy "postimages_public_read" on storage.objects for select using (bucket_id = 'post-images');
create policy "postimages_upload_own" on storage.objects for insert to authenticated
  with check (bucket_id = 'post-images' and auth.uid()::text = (storage.foldername(name))[1]);
```

### 5. Generate Xcode project

```bash
cd /path/to/forgeit
xcodegen generate
```

This creates `ForgeIt.xcodeproj`.

### 6. Open and run

```bash
open ForgeIt.xcodeproj
```

- Select `ForgeIt` scheme
- Select iPhone 15 Pro simulator (iOS 17+)
- Press ⌘R

---

## 9. Supabase Setup

### Auth settings

In Supabase Dashboard → Authentication → Settings:

- **Email confirmations**: Disable for development (enable for production)
- **Password minimum length**: 8
- **Site URL**: Add your app's URL scheme (e.g., `forgeit://`)

### Email templates (optional)

Customize the confirmation and password reset emails with your branding.

### Useful Supabase queries for debugging

```sql
-- Check user's streak
select public.compute_streak('USER_UUID_HERE');

-- Check daily progress
select public.daily_progress_summary('USER_UUID_HERE');

-- See who posted today
select p.username, po.caption, po.created_at
from public.posts po
join public.profiles p on p.id = po.user_id
where po.posted_for_date = current_date
order by po.created_at desc;

-- Check streaks leaderboard
select p.username, us.current_streak, us.longest_streak
from public.user_stats us
join public.profiles p on p.id = us.user_id
order by us.current_streak desc
limit 20;
```

---

## 10. Manual Test Checklist

### Auth

- [ ] Sign up with email + password
- [ ] Email validation works (invalid email rejected)
- [ ] Password too short shows error
- [ ] Sign in with correct credentials
- [ ] Sign in with wrong password shows error
- [ ] Session persists on app restart (kill + reopen)
- [ ] Sign out works and redirects to auth screen

### Onboarding

- [ ] Username step: too short shows error
- [ ] Username step: duplicate username shows "taken"
- [ ] Username step: valid unique username shows "Available" ✓
- [ ] Category step: must select before continuing
- [ ] Bio step: skip works (optional)
- [ ] Bio step: over 160 chars disables submit
- [ ] Done screen animates in properly
- [ ] Profile is updated in Supabase after onboarding

### Friends Feed

- [ ] Empty state shown when following nobody
- [ ] Posts appear after following someone
- [ ] Pull to refresh loads new posts
- [ ] Scroll to bottom loads more (infinite scroll)
- [ ] Tap 🔥 Grind — count increases, button activates
- [ ] Tap 🔥 again — count decreases, button deactivates
- [ ] Tap 💪 Respect — same behavior
- [ ] Follow button in post header works
- [ ] Long caption truncates with "more" button

### Explore

- [ ] Posts visible immediately
- [ ] Category chips filter posts correctly
- [ ] "All" chip shows everything
- [ ] Search by username works
- [ ] Search by caption keyword works
- [ ] Clear search button resets
- [ ] Empty state shows when no results
- [ ] Follow button on explore cards works

### Capture

- [ ] Photo picker opens and image appears
- [ ] Image can be changed
- [ ] Caption textarea works, placeholder disappears on focus
- [ ] 500 char limit enforced (counter shows)
- [ ] Submit disabled if both image and caption empty
- [ ] Goal dropdown shows active goals
- [ ] Mark complete toggle appears only after selecting a goal
- [ ] Post creates successfully
- [ ] Success toast appears and auto-dismisses
- [ ] Form resets after post
- [ ] Post appears in Friends feed immediately
- [ ] If goal marked complete: goal shows as completed in Progress tab

### Progress

- [ ] Streak card shows current streak
- [ ] Today check-in: "not posted" before posting
- [ ] Today check-in: "done" after posting
- [ ] Progress bar animates on load
- [ ] Progress bar reflects correct % (completed/total)
- [ ] Add goal via "+ Add" opens sheet
- [ ] New goal appears in list immediately
- [ ] Tap circle to complete goal — strikethrough appears
- [ ] Tap circle again to uncomplete goal
- [ ] Progress bar updates after toggle
- [ ] Swipe left on goal → delete confirmation → deletes
- [ ] Pull to refresh works

### Profile

- [ ] Avatar displays
- [ ] Username, bio, category visible
- [ ] Following / followers counts correct
- [ ] Stats row: streak, goals done, posts, best streak
- [ ] Build history shows posts
- [ ] Own profile: "Edit profile" button visible
- [ ] Other profile: "Follow" button visible
- [ ] Follow toggles correctly
- [ ] Edit profile: change display name → saved
- [ ] Edit profile: change bio → saved
- [ ] Edit profile: change category → saved
- [ ] Edit profile: upload new avatar → displays

### General

- [ ] App is portrait-only
- [ ] Dark mode throughout (forced, no light mode)
- [ ] Custom tab bar visible with accent capture button
- [ ] Capture button elevated above tab bar
- [ ] Bottom padding on all scrollable screens (content not hidden behind tab bar)
- [ ] Skeleton loaders appear during first load
- [ ] Empty states have correct messaging and CTAs
- [ ] No crashes on rapid tab switching

---

## 11. Roadmap / V2 Ideas

Architecture is prepared for these without breaking V1:

### Near-term (V1.1)
- Push notifications (daily grind reminder, reaction notification)
- Dual camera capture mode
- Weekly summary view
- Post comments (simple, not threaded)

### Mid-term (V2)
- Challenges system (30-day streak challenge, category challenges)
- Leaderboard (streak, goals completed)
- Hashtags / topics
- Direct messages (1:1)

### Long-term
- AI-powered goal suggestions
- Milestones / journey map (visual build history)
- Groups / mastermind rooms
- Marketplace (tools, courses, services)
- API for integrations (Notion goals, GitHub commits, Stripe MRR)

---

## Notes for Development

### Naming: `ForgeItProgressView` vs `ProgressView`

SwiftUI ships a built-in `ProgressView` (spinner/progress bar). To avoid compiler ambiguity, the app's Progress tab screen is named `ForgeItProgressView` in [ForgeIt/Features/Progress/Views/ForgeItProgressView.swift](ForgeIt/Features/Progress/Views/ForgeItProgressView.swift). This is the view used in `MainTabView`.

### Supabase Swift SDK — decoder configuration

The Supabase Swift SDK v2 uses `JSONDecoder` with `.convertFromSnakeCase` by default, which handles `full_name → fullName` automatically. The `CodingKeys` in models are included for explicitness and safety, but would not be strictly required for the snake_case fields.

### Streak calculation

The streak is computed server-side via `compute_streak()` SQL function. The app calls `refresh_user_streak()` RPC after a successful post to update `user_stats.current_streak`. This avoids timezone edge cases — the server uses `current_date` based on the Supabase project timezone (default UTC). For production, consider accepting the user's timezone and passing it as a parameter.

### Offline handling

V1 has no offline support. All operations require network. Errors are surfaced to the user with human-readable messages. A proper offline queue (CoreData + sync) is a V2 consideration.

---

*Built with Swift + SwiftUI + Supabase. Designed for builders.*
