import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/post_repository.dart';
import '../models/feed_state.dart';
import '../models/post_model.dart';

// ---------------------------------------------------------------------------
// Providers — defined at top level so Riverpod can resolve the dependency
// graph at compile time. No Provider.of() lookups needed.
// ---------------------------------------------------------------------------

/// Singleton repository — shared across the app
final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(),
);

/// The main feed state notifier — drives the entire home screen
final feedNotifierProvider =
    StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final repo = ref.watch(postRepositoryProvider);
  return FeedNotifier(repo)..init();
});

/// Tracks which post IDs are liked by the current user (local state only)
final likedPostsProvider = StateNotifierProvider<LikedPostsNotifier, Set<String>>(
  (ref) => LikedPostsNotifier(),
);

/// Tracks which post IDs are saved by the current user (local state only)
final savedPostsProvider = StateNotifierProvider<SavedPostsNotifier, Set<String>>(
  (ref) => SavedPostsNotifier(),
);

// ---------------------------------------------------------------------------
// FeedNotifier
// ---------------------------------------------------------------------------

/// Controls the lifecycle of the feed: initial load, pagination, refresh.
///
/// Why StateNotifier over ChangeNotifier?
/// - Immutable state → predictable, testable, no accidental mutation
/// - Works perfectly with Riverpod's [select] for granular rebuilds
class FeedNotifier extends StateNotifier<FeedState> {
  final PostRepository _repository;
  bool _isFetching = false; // Guard to prevent duplicate simultaneous fetches

  FeedNotifier(this._repository) : super(const FeedState());

  /// Called once on startup — loads stories + first page of posts in parallel.
  Future<void> init() async {
    state = state.copyWith(isLoadingInitial: true);

    try {
      // Parallel fetch: both requests fire simultaneously, halving total wait time.
      // We use separate typed futures instead of Future.wait to preserve type safety.
      final storiesFuture = _repository.getStories();
      final postsFuture = _repository.getPosts(page: 0);

      final stories = await storiesFuture;
      final posts = await postsFuture;

      state = state.copyWith(
        stories: stories,
        posts: posts,
        isLoadingInitial: false,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingInitial: false,
        error: 'Failed to load feed. Pull to refresh.',
      );
    }
  }

  /// Called when the user scrolls near the bottom.
  /// Guard [_isFetching] prevents duplicate calls if the user scrolls fast.
  Future<void> loadNextPage() async {
    if (_isFetching || state.hasReachedEnd || state.isLoadingMore) return;

    _isFetching = true;
    state = state.copyWith(isLoadingMore: true);

    try {
      final newPosts = await _repository.getPosts(page: state.currentPage);

      if (newPosts.isEmpty) {
        state = state.copyWith(
          isLoadingMore: false,
          hasReachedEnd: true,
        );
      } else {
        state = state.copyWith(
          posts: [...state.posts, ...newPosts],
          isLoadingMore: false,
          currentPage: state.currentPage + 1,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: 'Could not load more posts.',
      );
    } finally {
      _isFetching = false;
    }
  }

  /// Pull-to-refresh: reset everything and re-init
  Future<void> refresh() async {
    state = const FeedState();
    await init();
  }
}

// ---------------------------------------------------------------------------
// Simple toggle notifiers
// ---------------------------------------------------------------------------

class LikedPostsNotifier extends StateNotifier<Set<String>> {
  LikedPostsNotifier() : super({});

  void toggle(String postId) {
    final updated = Set<String>.from(state);
    if (updated.contains(postId)) {
      updated.remove(postId);
    } else {
      updated.add(postId);
    }
    state = updated;
  }

  /// Returns the adjusted like count: +1 if liked, -1 if just unliked
  int adjustedCount(PostModel post) {
    return state.contains(post.id)
        ? post.likeCount + 1
        : post.likeCount;
  }
}

class SavedPostsNotifier extends StateNotifier<Set<String>> {
  SavedPostsNotifier() : super({});

  void toggle(String postId) {
    final updated = Set<String>.from(state);
    if (updated.contains(postId)) {
      updated.remove(postId);
    } else {
      updated.add(postId);
    }
    state = updated;
  }
