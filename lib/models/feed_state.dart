import 'post_model.dart';
import 'story_model.dart';

/// Immutable snapshot of the feed's current state.
/// Riverpod will diff and rebuild only what changed.
class FeedState {
  final List<PostModel> posts;
  final List<StoryModel> stories;
  final bool isLoadingInitial;  // First load — show full shimmer
  final bool isLoadingMore;     // Pagination — show bottom shimmer
  final bool hasReachedEnd;     // No more pages to fetch
  final int currentPage;
  final String? error;

  const FeedState({
    this.posts = const [],
    this.stories = const [],
    this.isLoadingInitial = true,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.currentPage = 0,
    this.error,
  });

  FeedState copyWith({
    List<PostModel>? posts,
    List<StoryModel>? stories,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    int? currentPage,
    String? error,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      stories: stories ?? this.stories,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
      error: error ?? this.error,
    );
  }
}
