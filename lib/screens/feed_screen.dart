import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/feed_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/feed_app_bar.dart';
import '../widgets/post_card.dart';
import '../widgets/shimmer_widgets.dart';
import '../widgets/story_bubble.dart';

/// The main home feed screen.
///
/// Pagination logic:
/// - A [ScrollController] listens to scroll position
/// - When [_scrollThreshold] px from bottom → triggers [loadNextPage()]
/// - The "2 posts away" rule is approximated by using maxScrollExtent - 800px
///   (800px ≈ 2 × average post height)
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  /// How many pixels from the bottom to trigger a load-more fetch.
  /// ~800px ≈ 2 average post heights.
  static const double _scrollThreshold = 800.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Fires every time the scroll position changes.
  /// Uses [extentAfter] to check remaining scrollable distance.
  void _onScroll() {
    final position = _scrollController.position;
    final remaining = position.maxScrollExtent - position.pixels;

    if (remaining <= _scrollThreshold) {
      // Read — not watch — because we're in an event handler, not build()
      ref.read(feedNotifierProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const FeedAppBar(),
      body: feedState.isLoadingInitial
          ? _buildInitialShimmer()
          : _buildFeed(feedState),
    );
  }

  // ---------------------------------------------------------------------------
  // INITIAL LOAD SHIMMER
  // ---------------------------------------------------------------------------
  Widget _buildInitialShimmer() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Stories shimmer
          SizedBox(
            height: 104,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 8,
              itemBuilder: (_, __) => const ShimmerStoryBubble(),
            ),
          ),
          const Divider(height: 1, thickness: 0.3),
          // Post skeletons
          const ShimmerPostCard(),
          const ShimmerPostCard(),
          const ShimmerPostCard(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN FEED
  // ---------------------------------------------------------------------------
  Widget _buildFeed(feedState) {
    return RefreshIndicator(
      color: AppColors.igBlue,
      onRefresh: () => ref.read(feedNotifierProvider.notifier).refresh(),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(), // iOS-style bounce
        ),
        slivers: [
          // Stories Tray
          SliverToBoxAdapter(
            child: Column(
              children: [
                StoriesTray(stories: feedState.stories),
                const Divider(height: 1, thickness: 0.3, color: AppColors.divider),
              ],
            ),
          ),

          // Post list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = feedState.posts[index];
                return PostCard(
                  key: ValueKey(post.id), // Stable keys prevent re-render on append
                  post: post,
                );
              },
              childCount: feedState.posts.length,
            ),
          ),

          // Bottom state — loading more or end of feed
          SliverToBoxAdapter(
            child: _buildBottomIndicator(feedState),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomIndicator(feedState) {
    if (feedState.isLoadingMore) {
      return const PaginationShimmer();
    }
    if (feedState.hasReachedEnd) {
      return const _EndOfFeedWidget();
    }
    return const SizedBox(height: 32);
  }
}

// =============================================================================
// END-OF-FEED WIDGET
// =============================================================================

/// Shown when there are no more posts to load.
/// Instagram shows the user's profile avatar + "You're all caught up" message.
class _EndOfFeedWidget extends StatelessWidget {
  const _EndOfFeedWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider, width: 1.5),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.textSecondary,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "You're all caught up",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'You've seen all new posts from the\npast 3 days.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.textPrimary, width: 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'View older posts',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
