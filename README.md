# Reelio

Reelio is a short-form video app built with Flutter and Firebase, inspired by TikTok and Instagram Reels.

This repository follows a feature-first clean architecture with BLoC for state management and GetIt + Injectable for dependency injection.

## Project Snapshot

- Platform: Flutter (Android + iOS)
- Backend: Firebase Auth + Cloud Firestore, Supabase Storage, Firebase Remote Config
- Architecture: Feature-first clean architecture (`data` -> `domain` -> `presentation`)
- State management: `flutter_bloc`
- Dependency injection: `get_it` + `injectable`
- Routing: `go_router` with auth-aware redirects

## Current Feature Status

### Implemented

1. Authentication
- Email/password sign up and login
- Google sign in
- Auth session listener and route redirects
- Logout

2. Username onboarding
- Mandatory username setup after signup/signin if username is missing
- Live username availability check
- Validation for username format and length

3. Reels feed core
- Vertical paged feed
- Firestore-backed initial fetch + pagination
- Pull-to-refresh
- Nearby-reel preloading (current reel + adjacent reels) for smoother swipes
- Video controllers outside the active preload window are disposed to control memory
- Disk cache strategy: up to 20 video files, stale after 3 days
- Tap anywhere on reel to pause/play with temporary center indicator
- Feed playback pauses when feed is not visible (tab/screen switches)
- Feed playback pauses before navigating to profile from username tap

4. Reels engagement
- Like/unlike with optimistic UI update and rollback on failure
- Like tap rate-limiting to reduce rapid repeated backend calls
- Comments bottom sheet with pagination
- Share action currently shows `Coming soon...` snackbar with anti-spam lock

5. Upload reel core
- Pick video from gallery
- 60-second duration guard
- File size guard from Firebase Remote Config (default fallback: 20 MB)
- Thumbnail generation
- Caption support (max length enforced)
- Upload progress UI with cancel support
- Atomic Firestore write path:
  - create reel document
  - increment `users.reelsCount`

6. Profile (current user)
- Load profile from Firestore
- Edit profile
- Change password for email/password accounts
- Display counters (`reelsCount`, followers, following)
- Own profile reels grid
- Tap own profile reel to open full-screen reels player

7. Search and public profiles
- User search
- Follow/unfollow from search and public profile
- Public profile route by username
- Public profile reels grid
- Tap public profile reel to open full-screen reels player
- Back navigation from player returns to profile context

## Architecture Overview

The app uses a strict layered approach inside each feature:

- `data`: Firebase models, remote data sources, repository implementations
- `domain`: entities, repository contracts, use cases (pure Dart)
- `presentation`: screens, widgets, cubits/blocs

Core app-wide modules live under `lib/core` (router, theme, DI, error handling, shared utilities).

Primary folders:

```text
lib/
  core/
  features/
	auth/
	feed/
	upload/
	profile/
	search/
	likes/
	comments/
  shared/
```

## Tech Stack

- Flutter SDK: Dart 3
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_remote_config`
- Supabase: `supabase_flutter`
- BLoC: `bloc`, `flutter_bloc`
- DI: `get_it`, `injectable`, `injectable_generator`
- Routing: `go_router`
- Video: `video_player`, `cached_video_player_plus`, `chewie`
- Utilities: `fpdart`, `image_picker`, `video_thumbnail`, `flutter_cache_manager`, `shimmer`

## Prerequisites

1. Flutter SDK installed and on PATH
2. Android Studio and/or Xcode configured for Flutter
3. Firebase project with:
	- Authentication (Email/Password + Google)
	- Cloud Firestore
	- Remote Config (for upload size limit)
4. Supabase project with Storage buckets
5. Dart/Flutter CLI tools available

## Firebase Setup

This project expects FlutterFire configuration.

1. Install FlutterFire CLI if needed.
2. Configure Firebase for this app:

```bash
flutterfire configure
```

3. Ensure platform config files exist:
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

4. Ensure generated `lib/firebase_options.dart` is present and up to date.

5. Add Firebase Remote Config parameter:
- `reel_file_size` (integer value in MB, example: `20`)

If config files are not committed in your checkout, generate/add them before running.

## Supabase Storage Setup

This project uses Supabase Storage for media files (videos + thumbnails).

1. Create buckets:
- `reels` (public)
- `thumbnails` (public)

2. Add storage policies in Supabase SQL Editor:

```sql
create policy "reels public read"
on storage.objects
for select
using (bucket_id = 'reels');

create policy "reels public write"
on storage.objects
for insert
with check (bucket_id = 'reels');

create policy "reels public update"
on storage.objects
for update
using (bucket_id = 'reels');

create policy "reels public delete"
on storage.objects
for delete
using (bucket_id = 'reels');

create policy "thumbnails public read"
on storage.objects
for select
using (bucket_id = 'thumbnails');

create policy "thumbnails public write"
on storage.objects
for insert
with check (bucket_id = 'thumbnails');

create policy "thumbnails public update"
on storage.objects
for update
using (bucket_id = 'thumbnails');

create policy "thumbnails public delete"
on storage.objects
for delete
using (bucket_id = 'thumbnails');
```

3. Configure Supabase constants in `lib/core/config/supabase_config.dart`:
- `url`
- `anonKey`

## Install and Run

From the project root (`reelio`):

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Common Developer Commands

```bash
# static analysis
flutter analyze

# format code (example)
dart format lib

# regenerate DI and other generated files
dart run build_runner build --delete-conflicting-outputs
```

## Router and App Flow

High-level route behavior:

1. Unauthenticated users are redirected to login/signup routes.
2. Authenticated users without username are redirected to username setup.
3. Authenticated users with username land in app shell tabs:
	- Feed
	- Upload
	- Profile
4. Additional top-level routes:
	- Search
	- Public profile by username
	- Profile reels player

## Firestore Data Notes

Upload writes reel documents compatible with feed/profile readers. Core reel fields:

- `userId`
- `username`
- `userAvatarUrl`
- `videoUrl`
- `thumbnailUrl`
- `caption`
- `likesCount`
- `commentsCount`
- `createdAt`

During publish, upload also increments `users.reelsCount` in the same atomic batch.

## Reviewer Walkthrough

Suggested review path:

1. Launch app and create account (or sign in).
2. Complete username setup.
3. Verify feed loads and scroll behavior works.
4. Open Upload tab:
	- pick a video
	- preview + caption
	- post reel
	- verify progress and cancel path
5. Open Profile tab:
	- verify user details and counters
	- test edit profile
6. In Feed:
	- test tap-to-pause/play behavior
	- test like/comment/share actions
7. In Profile/Public Profile:
	- open reels grid item and verify full-screen player opens
	- verify back returns to profile context
8. Open Search:
	- search users
	- follow/unfollow
	- open public profile

## Troubleshooting

### GetIt registration errors after changes

If you see errors like "Object/factory ... is not registered", regenerate DI and restart:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter clean
flutter pub get
flutter run
```

Use a full restart, not only hot restart, after major generated-file changes.

### Firebase connection or auth issues

1. Recheck `firebase_options.dart`
2. Recheck platform Firebase config files
3. Confirm Firebase services are enabled in console

### Supabase upload issues

1. Recheck values in `lib/core/config/supabase_config.dart`
2. Confirm both buckets exist (`reels`, `thumbnails`)
3. Confirm storage policies are applied

