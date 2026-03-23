# Reelio

Reelio is a short-form video app built with Flutter and Firebase, inspired by TikTok and Instagram Reels.

This repository follows a feature-first clean architecture with BLoC for state management and GetIt + Injectable for dependency injection.

## Project Snapshot

- Platform: Flutter (Android + iOS)
- Backend: Firebase Auth, Cloud Firestore, Firebase Storage
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
- Video preloading and lifecycle-aware playback pause/resume
- Cached video file fallback for smoother playback

4. Upload reel core
- Pick video from gallery
- 60-second duration guard
- Thumbnail generation
- Caption support (max length enforced)
- Upload progress UI with cancel support
- Atomic Firestore write path:
  - create reel document
  - increment `users.reelsCount`

5. Profile (current user)
- Load profile from Firestore
- Edit profile
- Change password for email/password accounts
- Display counters (`reelsCount`, followers, following)

6. Search and public profiles
- User search
- Follow/unfollow from search and public profile
- Public profile route by username
- Public profile reels grid

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
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
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
	- Firebase Storage
4. Dart/Flutter CLI tools available

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

If config files are not committed in your checkout, generate/add them before running.

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
6. Open Search:
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

