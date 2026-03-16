# Instagram Feed — Flutter UI/UX Challenge

A pixel-perfect replication of the Instagram Home Feed built for the ZREX Flutter UI/UX Challenge. Every architectural decision is documented below so you can explain every line during the technical interview.

---

## Demo Checklist

| Feature | Status |
|---|---|
| Shimmer loading state | ✅ |
| Stories tray (horizontal scroll) | ✅ |
| Post feed (vertical scroll) | ✅ |
| Carousel posts with dot indicator | ✅ |
| Double-tap to like (heart overlay) | ✅ |
| Like / Save toggle with animation | ✅ |
| Pinch-to-zoom overlay | ✅ |
| Infinite scroll pagination | ✅ |
| Cached network images | ✅ |
| Snackbar for unimplemented buttons | ✅ |
| Pull-to-refresh | ✅ |
| Bottom navigation bar | ✅ |

---

## How to Run

### Prerequisites

- Flutter SDK `>=3.0.0` — [install guide](https://docs.flutter.dev/get-started/install)
- Dart SDK `>=3.0.0` (bundled with Flutter)
- A device or emulator (iOS Simulator / Android Emulator / Chrome)

### Steps

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/instagram_feed.git
cd instagram_feed

# 2. Install dependencies
flutter pub get

# 3. Run on your preferred platform
flutter run                    # auto-detect connected device
flutter run -d chrome          # web
flutter run -d ios             # iOS Simulator
flutter run -d android         # Android Emulator

# 4. Run with release optimisations (best scroll performance)
flutter run --release
```

No API keys. No environment variables. No `.env` file needed — the app uses public Unsplash image URLs and generated avatar URLs from `pravatar.cc`.

---

## State Management Choice — Riverpod

**Why Riverpod over Provider or Bloc?**

| Concern | Provider | Bloc | Riverpod ✅ |
|---|---|---|---|
| Compile-time safety | ❌ `context.watch` can fail at runtime | ✅ | ✅ |
| Boilerplate | Low | High (Events/States/Blocs) | Low |
| Testing | Needs widget tree | Pure unit tests | Pure unit tests |
| Global vs scoped state | Needs `MultiProvider` nesting | Needs `BlocProvider` | Flat, auto-resolved |
| Pagination state | Gets messy | Clean but verbose | Clean, concise |

Riverpod's `StateNotifier` gives us **immutable state** (every change creates a new `FeedState` object). This means:
- No accidental mutations that cause subtle UI bugs
- Easy to unit-test: just assert on `FeedState` values
- Riverpod's `.select()` means a widget like `_LikeButton` only rebuilds when *its specific post's* like state changes — not the entire feed

---

## Architecture Walkthrough

```
lib/
├── main.dart                       # Entry point, ProviderScope root
├── models/
│   ├── user_model.dart             # Immutable user data
│   ├── post_model.dart             # Post + carousel logic
│   ├── story_model.dart            # Story bubble data
│   └── feed_state.dart             # Immutable feed snapshot (pagination state)
├── data/
│   ├── services/
│   │   └── mock_data_service.dart  # Raw data source (fake API, Unsplash URLs)
│   └── repositories/
│       └── post_repository.dart    # Abstraction over service (swap for real API)
├── providers/
│   └── feed_notifier.dart          # All Riverpod providers + StateNotifiers
├── screens/
│   ├── home_screen.dart            # Bottom nav + IndexedStack host
│   └── feed_screen.dart           # ScrollController + pagination trigger
├── widgets/
│   ├── feed_app_bar.dart           # Logo + Notifications + Messages
│   ├── story_bubble.dart           # Story ring gradient + "Your Story"
│   ├── post_card.dart              # Full post card (header, media, actions)
│   ├── carousel_viewer.dart        # PageView + dot indicator + PinchZoom
│   ├── shimmer_widgets.dart        # Shimmer skeletons for loading states
│   └── bottom_nav_bar.dart         # 5-tab bottom navigation
├── utils/
│   └── number_formatter.dart       # "12500" → "12.5K"
└── theme/
    └── app_theme.dart              # Colors, gradients, ThemeData
```

### Data Flow (top-down)

```
MockDataService (raw data)
    ↓
PostRepository (abstraction — swap for real API without touching UI)
    ↓
FeedNotifier : StateNotifier<FeedState> (business logic, pagination)
    ↓
feedNotifierProvider (Riverpod global provider)
    ↓
FeedScreen (ConsumerWidget — reads FeedState, drives scroll listener)
    ↓
PostCard → _PostMedia / _PostActions / _PostLikeCount
    ↓
likedPostsProvider / savedPostsProvider (isolated toggle state)
```

---

## Key Technical Decisions

### 1. Repository Pattern

`PostRepository` is an abstract class (`PostRepositoryBase`) with a concrete `PostRepository` implementation. The Riverpod `postRepositoryProvider` injects it into `FeedNotifier`. To swap in a real API:

```dart
// Replace this line in feed_notifier.dart:
final postRepositoryProvider = Provider<PostRepository>(
  (ref) => const PostRepository(), // ← swap MockDataService for ApiClient here
);
```

No other files change.

### 2. Pagination — "2 Posts Away" Trigger

```dart
// feed_screen.dart
void _onScroll() {
  final remaining = _scrollController.position.maxScrollExtent
                  - _scrollController.position.pixels;
  if (remaining <= 800.0) {          // 800px ≈ 2 average post heights
    ref.read(feedNotifierProvider.notifier).loadNextPage();
  }
}
```

The `_isFetching` boolean guard in `FeedNotifier` prevents duplicate simultaneous fetches even if the user scrolls aggressively — a common real-world bug.

### 3. Shimmer Loading

Two distinct shimmer states:
- **Initial load** (`isLoadingInitial: true`): Full-screen shimmer with story bubbles + 3 post skeletons. User sees this for 1.5s on first launch.
- **Pagination** (`isLoadingMore: true`): 2 shimmer post cards appended below the real posts while next page loads.

The `ShimmerWrapper` adapts to dark/light mode via theme-aware colours.

### 4. Pinch-to-Zoom Overlay

The implementation lifts the image above all other UI using Flutter's `Overlay`:

```
User pinches → GestureDetector catches ScaleStart with 2+ pointers
    → RenderBox.localToGlobal() captures exact screen position
    → OverlayEntry inserted with image at that exact position
    → InteractiveViewer handles zoom transform via TransformationController
    → On scale end → Matrix4Tween animates back to identity
    → Overlay removed when animation completes
```

The backdrop (`Colors.black.withOpacity(0.5)`) creates the "lifted above UI" Instagram feel.

### 5. Double-Tap Like

`_PostMedia` is a `ConsumerStatefulWidget` with an `AnimationController` for the white heart overlay. On double-tap:
1. If the post isn't already liked, `likedPostsProvider.notifier.toggle()` is called
2. The heart scales in with `elasticOut` curve (0→1.3→1.0) then fades out
3. This runs entirely in the widget — no state management overhead for a pure animation

### 6. Carousel Dot Indicator

The `SmoothPageIndicator` widget subscribes to the `PageController` stream — it updates the dot position on every scroll frame with zero manual state management. Using `ExpandingDotsEffect` matches Instagram's exact dot style.

### 7. Like Count Reactivity

```dart
// _PostLikeCount widget
ref.watch(likedPostsProvider.select((ids) => ids.contains(post.id)));
final count = ref.watch(likedPostsProvider.notifier).adjustedCount(post);
```

The `.select()` call means this widget only rebuilds when *this specific post's* like state changes — not when any other post is liked. This is a critical performance optimisation for long lists.

---

## Performance Notes

| Concern | Solution |
|---|---|
| Image memory pressure | `cached_network_image` LRU memory + disk cache |
| List re-renders on pagination append | `ValueKey(post.id)` on each `PostCard` |
| Like/Save toggle rebuilds | `.select()` scopes Riverpod rebuilds to single post |
| Scroll jank | `BouncingScrollPhysics`, `const` widgets throughout |
| Text scale overflow | `MediaQuery` clamp to 0.8–1.2 in `main.dart` |

---

## Edge Cases Handled

- **Image load failure**: `CachedNetworkImage` shows `broken_image_outlined` icon with grey background
- **Empty page response**: `FeedNotifier.loadNextPage()` sets `hasReachedEnd: true`, shows "You're all caught up" widget
- **Rapid scroll**: `_isFetching` guard prevents duplicate API calls
- **Pull to refresh**: Resets `FeedState` to initial and re-runs `init()`
- **Text overflow**: All username/caption text has `maxLines` + `overflow: TextOverflow.ellipsis`
- **Long captions**: "more" tap expands inline without layout shift

---

## Dependencies Explained

| Package | Why |
|---|---|
| `flutter_riverpod ^2.4.9` | Compile-safe state management — chosen over Provider/Bloc |
| `cached_network_image ^3.3.1` | Memory + disk image caching, placeholder/error states |
| `shimmer ^3.0.0` | Shimmer skeleton loading animation |
| `smooth_page_indicator ^1.1.0` | Carousel dot indicator with smooth animation |
| `google_fonts ^6.1.0` | Inter typeface — closest match to Instagram's typography |
| `flutter_svg ^2.0.9` | SVG support for icon assets |
| `timeago ^3.6.0` | "2h ago" style relative timestamps |

---

## What I Would Add Given More Time

1. **Story Viewer** — full-screen story with progress bar animation and swipe-to-next
2. **Real Riverpod `AsyncNotifier`** — replace `StateNotifier` + manual error handling with `AsyncNotifier` for cleaner `AsyncValue` states
3. **Unit Tests** — `FeedNotifier` is fully testable without Flutter (pure Dart)
4. **Integration Tests** — scroll-to-bottom triggers pagination, shimmer appears
5. **Dark Mode** — `AppTheme.dark` is partially wired; just needs colour overrides
6. **Video Posts** — `video_player` package for Reels-style inline video

---

*Built for the ZREX Flutter UI/UX Challenge — quality over quantity.*
