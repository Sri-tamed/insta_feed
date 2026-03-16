import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/story_model.dart';
import '../theme/app_theme.dart';

/// Renders a single story avatar in the horizontal stories tray.
///
/// - Unviewed: colourful gradient ring
/// - Viewed: grey ring
/// - Your Story: shows a "+" add badge
class StoryBubble extends StatelessWidget {
  final StoryModel story;
  final VoidCallback? onTap;

  const StoryBubble({
    super.key,
    required this.story,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRing(),
            const SizedBox(height: 4),
            _buildLabel(),
          ],
        ),
      ),
    );
  }

  Widget _buildRing() {
    // The outer gradient ring is 2px larger on each side than the inner
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: story.isViewed || story.isYourStory
                ? null
                : AppGradients.storyRing,
            color: story.isViewed
                ? AppColors.storyRingViewed
                : (story.isYourStory ? Colors.transparent : null),
            border: story.isViewed
                ? Border.all(color: AppColors.storyRingViewed, width: 1.5)
                : null,
          ),
          padding: const EdgeInsets.all(2.5), // Gap between ring and avatar
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              // White border creates the visual gap between ring and avatar
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(2),
            child: _buildAvatar(),
          ),
        ),
        if (story.isYourStory) _buildAddBadge(),
      ],
    );
  }

  Widget _buildAvatar() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: story.user.avatarUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: AppColors.shimmerBase,
        ),
        errorWidget: (_, __, ___) => Container(
          color: AppColors.shimmerBase,
          child: const Icon(Icons.person, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildAddBadge() {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(bottom: 2, right: 2),
      decoration: const BoxDecoration(
        color: AppColors.igBlue,
        shape: BoxShape.circle,
        border: Border.fromBorderSide(
          BorderSide(color: Colors.white, width: 1.5),
        ),
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 13),
    );
  }

  Widget _buildLabel() {
    return SizedBox(
      width: 68,
      child: Text(
        story.isYourStory ? 'Your Story' : story.user.username,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

/// The horizontal scrollable stories tray
class StoriesTray extends StatelessWidget {
  final List<StoryModel> stories;

  const StoriesTray({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        physics: const BouncingScrollPhysics(),
        itemCount: stories.length,
        itemBuilder: (_, index) => StoryBubble(
          story: stories[index],
          onTap: () {
            // TODO: Open story viewer
          },
        ),
      ),
    );
  }
}
