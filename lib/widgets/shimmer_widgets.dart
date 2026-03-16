import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

/// A rounded box with shimmer animation — base building block for all skeletons
class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer wrapper — wraps children in the sliding shimmer effect
class ShimmerWrapper extends StatelessWidget {
  final Widget child;

  const ShimmerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
      highlightColor:
          isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlight,
      child: child,
    );
  }
}

/// Stories tray shimmer — single story bubble skeleton
class ShimmerStoryBubble extends StatelessWidget {
  const ShimmerStoryBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            const _ShimmerBox(width: 64, height: 64, borderRadius: 32),
            const SizedBox(height: 4),
            const _ShimmerBox(width: 48, height: 10, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// Full post card shimmer — mirrors the layout of a real PostCard
class ShimmerPostCard extends StatelessWidget {
  const ShimmerPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ShimmerWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: avatar + username + menu
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const _ShimmerBox(width: 36, height: 36, borderRadius: 18),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _ShimmerBox(width: 120, height: 12),
                    SizedBox(height: 4),
                    _ShimmerBox(width: 80, height: 10),
                  ],
                ),
              ],
            ),
          ),
          // Image placeholder
          _ShimmerBox(
            width: screenWidth,
            height: screenWidth, // 1:1 aspect ratio
            borderRadius: 0,
          ),
          // Action row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: const [
                _ShimmerBox(width: 24, height: 24, borderRadius: 4),
                SizedBox(width: 16),
                _ShimmerBox(width: 24, height: 24, borderRadius: 4),
                SizedBox(width: 16),
                _ShimmerBox(width: 24, height: 24, borderRadius: 4),
              ],
            ),
          ),
          // Like count
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: _ShimmerBox(width: 100, height: 12),
          ),
          const SizedBox(height: 6),
          // Caption
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: _ShimmerBox(width: 260, height: 12),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: _ShimmerBox(width: 180, height: 12),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Bottom-of-feed loading indicator (pagination shimmer)
class PaginationShimmer extends StatelessWidget {
  const PaginationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ShimmerPostCard(),
        const ShimmerPostCard(),
      ],
    );
  }
}
