# Flutter Short Video Feed Application (Instagram Reels / YouTube Shorts)

A production-ready, high-performance Flutter short video browsing application built with Clean Architecture, BLoC state management, resilient video controller lifecycle management, and offline-first persistence.

---

## 1. Project Overview

This application simulates a vertical short video browsing feed (akin to TikTok, Instagram Reels, and YouTube Shorts). It allows users to browse through vertical videos smoothly, auto-play the active on-screen video, pause off-screen content, interact via Likes, Comments, and Native Shares, paginate infinite feeds seamlessly, and maintain state across app launches and network fluctuations.

The codebase is built following Senior Flutter Developer engineering standards, focusing on memory efficiency, deterministic controller lifecycles, sound null safety, and clean separation of concerns.

---

## 2. Features Implemented

- **Full-Screen Vertical Video Browsing**: Built with `PageView.builder` for virtualized viewport rendering and zero frame drop.
- **Auto-Play & Playback Management**: Automatically plays visible video, pauses previous video, and auto-disposes controllers outside the immediate view range.
- **Background/Foreground Lifecycle Adaptation**: Video automatically pauses when the application enters the background or becomes inactive, and resumes upon foregrounding.
- **Interactive Gestures**:
  - Single tap anywhere to toggle Play/Pause with center visual indicator.
  - Double tap to like with animated heart pop effect.
- **Right Action Bar**:
  - Profile avatar with follow badge.
  - Like button with instant optimistic UI update, heart color change, and formatted counts (e.g., `14.2K`).
  - Comment button with count that opens an interactive modal bottom sheet.
  - Share button using `share_plus` native share sheet.
  - Global Mute/Unmute toggle.
  - Rotating animated vinyl disc.
- **Comments Modal Sheet**:
  - Displays comments list with author avatar, username, and relative timestamp.
  - Allows adding new comments with optimistic additions and real-time feed count synchronization.
  - Comment like toggling.
- **Infinite Pagination & Feed Refresh**:
  - Page-based pagination triggered automatically when approaching the end of the feed (`threshold = 2`).
  - Pull-to-refresh (`RefreshIndicator`) to reset the feed without flickering.
  - Duplicate video ID prevention.
- **State Preservation & Offline Resilience**:
  - Persists liked videos, last viewed index, and user comment counts in `SharedPreferences`.
  - Restores browsing position on application restart.
  - Real-time network connectivity monitoring with top banner notification and non-destructive retry fallback.

---

## 3. Technology Stack

| Technology | Purpose |
| :--- | :--- |
| **Flutter 3.44+ / Dart 3.12+** | Core mobile application framework with sound null safety |
| **flutter_bloc (v9.1+)** | Feature state management, immutable state transitions |
| **video_player (v2.14+)** | Native hardware-accelerated video playback |
| **dio (v5.11+)** | REST API HTTP client with interceptors, timeouts, and error handling |
| **shared_preferences (v2.5+)**| Lightweight persistent key-value storage |
| **connectivity_plus (v7.3+)** | Network connectivity detection and live stream monitoring |
| **share_plus (v13.3+)** | Native system sharing dialog integration |
| **cached_network_image (v4.0+)** | High-performance memory and disk image caching |
| **equatable (v3.0+)** | Value equality without manual operator overrides |
| **bloc_test & mocktail** | Unit, BLoC, and widget test suites |

---

## 4. Architecture Overview

The application follows **Clean Architecture** using a **feature-first** folder structure. This cleanly decouples presentation, business logic, domain entities, and data sources:

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                      │
│     (Screens, Reusable Widgets, BLoC / Cubits, Managers)    │
└───────────────────────────────┬─────────────────────────────┘
                                │ Depends on Domain Use Cases
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                        Domain Layer                         │
│            (Entities, Repository Contracts, Use Cases)      │
└───────────────────────────────▲─────────────────────────────┘
                                │ Implements Repository Contracts
                                │
┌─────────────────────────────────────────────────────────────┐
│                         Data Layer                          │
│     (Models, Remote & Local Data Sources, Repositories)     │
└───────────────────────────────┬─────────────────────────────┘
                                │ Uses Core Utilities
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                         Core Layer                          │
│       (Network, Errors, Theme, Constants, Formatters)       │
└─────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities
- **Domain Layer (`domain/`)**: Pure Dart with zero Flutter UI dependencies. Defines `Video` and `Comment` entities, `VideoRepository` contract, and isolated use cases (`GetVideosUseCase`, `ToggleLikeUseCase`, `PersistenceUseCases`).
- **Data Layer (`data/`)**: Implements `VideoRepositoryImpl`, `VideoModel` JSON serialization/deserialization, `VideoRemoteDataSource` (Dio-based with mock fallback), and `VideoLocalDataSource` (`SharedPreferences`).
- **Presentation Layer (`presentation/`)**: Contains `VideoFeedBloc`, `VideoControllerManager`, `CommentsCubit`, screens, and modular widgets.
- **Core Layer (`core/`)**: Shared infrastructure including `ApiClient`, `NetworkInfo`, `AppTheme`, `AppColors`, formatters, and reusable error/loading widgets.

---

## 5. Folder Structure

```
lib/
├── app/
│   ├── app.dart               # Root MaterialApp with theme & providers
│   ├── injection.dart         # Service locator / dependency injection wiring
│   └── routes.dart            # Route definitions and generator
├── core/
│   ├── constants/
│   │   ├── api_constants.dart # Sample video URLs, endpoints, timeouts
│   │   └── app_constants.dart # Local storage keys, pagination thresholds
│   ├── errors/
│   │   ├── exceptions.dart    # Data layer exceptions (Server, Network, Cache)
│   │   └── failures.dart      # Domain layer failures (Equatable)
│   ├── network/
│   │   ├── api_client.dart    # Dio wrapper with timeouts & interceptors
│   │   └── network_info.dart  # Connectivity listener
│   ├── theme/
│   │   ├── app_colors.dart    # AMOLED dark mode color palette
│   │   └── app_theme.dart     # Material 3 dark theme specification
│   ├── utils/
│   │   └── formatters.dart    # Social metric formatting (14.2K, duration)
│   └── widgets/
│       ├── error_view.dart    # Standardized error presentation with retry
│       ├── loading_view.dart  # Sleek loading spinners
│       └── offline_banner.dart# Non-intrusive offline connectivity notification
├── features/
│   ├── comments/
│   │   ├── domain/
│   │   │   └── entities/comment.dart
│   │   └── presentation/
│   │       ├── cubit/comments_cubit.dart
│   │       └── widgets/
│   │           ├── comment_tile.dart
│   │           └── comments_bottom_sheet.dart
│   └── video_feed/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── video_local_data_source.dart
│       │   │   └── video_remote_data_source.dart
│       │   ├── models/video_model.dart
│       │   └── repositories/video_repository_impl.dart
│       ├── domain/
│       │   ├── entities/video.dart
│       │   ├── repositories/video_repository.dart
│       │   └── usecases/
│       │       ├── get_videos_usecase.dart
│       │       ├── persistence_usecases.dart
│       │       └── toggle_like_usecase.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── video_feed_bloc.dart
│           │   ├── video_feed_event.dart
│           │   └── video_feed_state.dart
│           ├── manager/
│           │   └── video_controller_manager.dart # Lifecycle & resource orchestrator
│           ├── pages/
│           │   └── video_feed_screen.dart        # Full screen PageView feed
│           └── widgets/
│               ├── feed_bottom_nav_bar.dart      # Reels-style bottom navigation
│               ├── video_actions_bar.dart        # Like, Comment, Share, Mute
│               ├── video_info_overlay.dart       # User handle, caption, hashtags, audio
│               ├── video_player_item.dart        # Player container with gestures
│               └── video_progress_bar.dart       # Playback position bar
└── main.dart
```

---

## 6. Video Controller Management Strategy

Video streaming apps must manage hardware decoders and memory strictly to avoid OOM crashes and frame drops. The dedicated `VideoControllerManager` implements the following rules:

1. **Window-Bounded Controller Allocation**:
   - At most 2–3 controllers exist at any time: the active video (`index`) and adjacent preloaded neighbors (`index - 1`, `index + 1`).
   - Any controller outside `(index - activeIndex).abs() > 1` is immediately paused, listeners removed, and `.dispose()` invoked.
2. **Deterministic Single Playback**:
   - When a page transition begins, the outgoing controller is paused synchronously.
   - If a background initialization resolves for an index that has already been scrolled past, it will **not** play.
3. **Safe Async Initialization**:
   - Tracks ongoing initialization Futures in `_initFutures` to prevent race conditions during rapid flick-scrolling.
4. **App Lifecycle Awareness**:
   - Implements `WidgetsBindingObserver`.
   - On `AppLifecycleState.paused`, `inactive`, or `hidden`, the active video is automatically paused.
   - On `AppLifecycleState.resumed`, playback resumes only if not previously paused manually by the user.
5. **Global Audio Synchronization**:
   - Mute/unmute state is managed globally and propagates to all active and newly initialized controllers.

---

## 7. BLoC State Management Explanation

`VideoFeedBloc` uses immutable states inheriting from `Equatable`:

### States
- `VideoFeedStatus.initial`: Feed has not yet loaded.
- `VideoFeedStatus.loading`: Fetching initial page.
- `VideoFeedStatus.loaded`: Videos ready, displaying feed.
- `VideoFeedStatus.loadingMore`: Fetching subsequent page while keeping existing videos visible.
- `VideoFeedStatus.refreshing`: Silently pulling fresh feed data.
- `VideoFeedStatus.empty`: Feed has zero entries.
- `VideoFeedStatus.error`: Request failed, displaying error view with retry action.

### Optimistic Updates & Rollback
When a user taps **Like**:
1. The BLoC emits an updated video list immediately with `isLiked = true` and `likesCount + 1`.
2. Asynchronously saves the like ID to local storage via `ToggleLikeUseCase`.
3. If the storage operation fails, the BLoC cleanly rolls back to the previous state.

---

## 8. API and Pagination Implementation

- **Pagination Approach**: Page-based pagination (`page` and `limit`).
- **Load More Trigger**: Triggered when the user scrolls within `paginationThreshold = 2` videos of the feed end.
- **Race Condition Prevention**: `VideoFeedLoadMore` ignores incoming requests if the BLoC is already `loadingMore`, `loading`, or has reached `hasReachedMax`.
- **Deduplication**: Newly fetched videos are cross-checked by ID against existing items in memory; duplicates are discarded before appending.
- **Public Video Samples**: Configured with Google Cloud Storage public sample MP4 videos (`ForBiggerBlazes`, `ForBiggerEscapes`, `BigBuckBunny`, `TearsOfSteel`, etc.) which are CDN-hosted, fast, reliable, and CORS-compliant.

---

## 9. Local Persistence Strategy

Using `SharedPreferences` via `VideoLocalDataSource`:
- **Liked Video IDs**: Stored as a `List<String>` under key `pref_liked_video_ids`.
- **Feed Position**: Stored as an integer under `pref_last_viewed_index` on every page change.
- **Comment Counts**: Stored under `pref_comment_count_<videoId>` to preserve user-added comments across app sessions.
- **App Startup Restoration**: On cold start, the app fetches page 1, reads the saved index, jumps the `PageController` to the saved position, and initializes playback there.

---

## 10. Network Resilience Strategy

- **Dio Configuration**: 10-second connection timeout and 10-second receive timeout to fail gracefully on slow networks.
- **Connectivity Stream**: `NetworkInfoImpl` listens to `Connectivity.onConnectivityChanged`. When the device loses internet, an offline banner appears at the top.
- **Pagination Safety**: If a page fails to load due to network error, existing loaded videos are retained, allowing the user to continue browsing already fetched content.
- **Playback Retries**: If an individual video stream fails due to a network glitch, a localized retry UI is rendered over that specific video without disrupting the feed.

---

## 11. Setup Instructions

### Prerequisites
- Flutter SDK (v3.22.0 or higher, verified on Flutter 3.44.0).
- Dart SDK (v3.4.0 or higher, verified on Dart 3.12.0).
- Android Studio / VS Code / Xcode configured with Flutter extensions.

### Installation
1. Clone the repository or navigate to the project directory:
   ```bash
   cd d:/FlutterProjects/ott_app
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Verify static analysis:
   ```bash
   flutter analyze
   ```

---

## 12. Commands to Run the Application

### Run on Connected Android Device or Emulator
```bash
flutter run
```

### Run on Windows Desktop
```bash
flutter run -d windows
```

### Run in Release Mode
```bash
flutter run --release
```

---

## 13. Testing Instructions

The project includes unit tests for use cases, BLoC state transitions, repository deduplication, and widget tests for feed rendering.

Run the test suite:
```bash
flutter test
```

### Test Coverage Highlights
- `usecases_test.dart`: Validates `GetVideosUseCase`, `ToggleLikeUseCase`, and persistence use cases.
- `video_feed_bloc_test.dart`: Validates initial fetch, empty state, error state, pagination appending, duplicate video prevention, optimistic like updates, and rollback on failure.
- `video_repository_impl_test.dart`: Validates data source aggregation, local persistence enrichment, ID deduplication, and failure mapping.
- `widget_test.dart`: Validates UI rendering for `LoadingView`, `ErrorView`, top navigation header, and bottom navigation bar.

---

## 14. Assumptions and Trade-offs

| Decision | Rationale |
| :--- | :--- |
| **Google Cloud Storage Samples** | Avoids unreliable third-party APIs and paid API keys while providing standard MP4 videos natively supported across platforms. |
| **Window-based Controller Pool (max 3)** | Balancing smooth swipe transitions (adjacent preloading) with strict RAM usage to prevent Android OOM errors. |
| **In-Memory + SharedPreferences Comments** | Realistic simulated comments with instant local additions without requiring a custom backend server for a machine test. |
| **Optimistic Like Updates** | Matches industry standards (Instagram/TikTok) where likes provide instant tactile feedback without waiting for network round-trips. |

---

## 15. Future Improvements

- **ExoPlayer Cache DataSource (Android) / AVAssetResourceLoader (iOS)**: Direct disk cache integration using `flutter_cache_manager` with video chunking.
- **Dynamic Bitrate Switching (HLS / DASH)**: Support `.m3u8` streams with adaptive bitrate based on bandwidth.
- **Video Pre-caching**: Download the first 1MB of upcoming videos in the background for instant playback on swipe.
- **Audio Ducking**: Automatically lower background music when comments feature voice notes or overlays.
- **Double Tap Floating Heart Coordinates**: Display the animated heart at the exact touch offset coordinates (`TapDownDetails`).

---

## Verification & Quality Assurance

- `flutter pub get`: Completed successfully.
- `dart format .`: Applied to all 43 files.
- `flutter analyze`: **0 issues found** (clean analysis).
- `flutter test`: **18 / 18 tests passed**.
