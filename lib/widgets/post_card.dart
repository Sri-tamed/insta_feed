import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/post_model.dart';
import '../providers/feed_notifier.dart';
import '../theme/app_theme.dart';
import '../utils/number_formatter.dart';
import 'carousel_viewer.dart';

/// The complete post card — header, media, actions, caption.
/// Uses ConsumerWidget so it can read Riverpod providers directly.
/// Each PostCard only rebuilds when its specific post's like/save state changes
/// (thanks to .select() in child widgets).
class PostCard extends ConsumerWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _PostHeader(post: post),
        _PostMedia(post: post),
        _PostActions(post: post),
        _PostLikeCount(post: post),
        _PostCaption(post: post),
        _PostTimestamp(post: post),
        const SizedBox(height: 4),
        const Divider(height: 1, thickness: 0.2, color: AppColors.divider),
      ],
    );
  }
}

// =============================================================================
// POST HEADER
// =============================================================================
class _PostHeader extends StatelessWidget {
  final PostModel post;
  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Avatar with story-style gradient ring (always shown as "unviewed")
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.storyRing,
            ),
            padding: const EdgeInsets.all(1.5),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(1.5),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: post.author.avatarUrl,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: AppColors.shimmerBase),
                  errorWidget: (_, __, ___) => const Icon(Icons.person),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Username + location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      post.author.username,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    if (post.author.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: AppColors.igBlue,
                        size: 14,
                      ),
                    ],
                  ],
                ),
                if (post.locationTag != null)
                  Text(
                    post.locationTag!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
          // Three-dot menu
          GestureDetector(
            onTap: () => _showOptionsSheet(context),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.more_horiz, size: 20, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _BottomSheetTile(icon: Icons.bookmark_border, label: 'Save'),
          _BottomSheetTile(icon: Icons.person_outline, label: 'Follow'),
          _BottomSheetTile(icon: Icons.info_outline, label: 'About this account'),
          _BottomSheetTile(
              icon: Icons.report_gmailerrorred_outlined,
              label: 'Report',
              isDestructive: true),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _BottomSheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;

  const _BottomSheetTile({
    required this.icon,
    required this.label,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label,
          style: TextStyle(
              color: color, fontSize: 15, fontWeight: FontWeight.w400)),
      dense: true,
      onTap: () => Navigator.pop(context),
    );
  }
}

// =============================================================================
// POST MEDIA (single image or carousel) — with double-tap to like
// =============================================================================
class _PostMedia extends ConsumerStatefulWidget {
  final PostModel post;
  const _PostMedia({required this.post});

  @override
  ConsumerState<_PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends ConsumerState<_PostMedia>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartScale;
  late Animation<double> _heartOpacity;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _heartScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.3)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_heartController);

    _heartOpacity = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: 1.0), weight: 20),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_heartController);

    _heartController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showHeart = false);
      }
    });
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    // Like the post on double-tap (if not already liked)
    final likedPosts = ref.read(likedPostsProvider);
    if (!likedPosts.contains(widget.post.id)) {
      ref.read(likedPostsProvider.notifier).toggle(widget.post.id);
    }
    setState(() => _showHeart = true);
    _heartController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.post.isCarousel
        ? CarouselViewer(imageUrls: widget.post.imageUrls)
        : SingleImagePost(imageUrl: widget.post.primaryImageUrl);

    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          media,
          // Floating heart animation on double-tap
          if (_showHeart)
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _heartController,
                builder: (_, __) => Opacity(
                  opacity: _heartOpacity.value,
                  child: Transform.scale(
                    scale: _heartScale.value,
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 90,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// POST ACTIONS (Like, Comment, Share, Save)
// =============================================================================
class _PostActions extends ConsumerWidget {
  final PostModel post;
  const _PostActions({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = ref.watch(
      likedPostsProvider.select((ids) => ids.contains(post.id)),
    );
    final isSaved = ref.watch(
      savedPostsProvider.select((ids) => ids.contains(post.id)),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Like button — animated heart
          _LikeButton(
            postId: post.id,
            isLiked: isLiked,
            onTap: () {
              ref.read(likedPostsProvider.notifier).toggle(post.id);
            },
          ),
          const SizedBox(width: 16),
          // Comment button
          _ActionIconButton(
            icon: Icons.chat_bubble_outline_rounded,
            onTap: () => _showSnackbar(context, 'Comments coming soon'),
          ),
          const SizedBox(width: 16),
          // Share button
          _ActionIconButton(
            icon: Icons.send_outlined,
            onTap: () => _showSnackbar(context, 'Sharing coming soon'),
          ),
          const Spacer(),
          // Save button
          _SaveButton(
            postId: post.id,
            isSaved: isSaved,
            onTap: () {
              ref.read(savedPostsProvider.notifier).toggle(post.id);
            },
          ),
        ],
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Colors.black87,
      ),
    );
  }
}

class _LikeButton extends StatefulWidget {
  final String postId;
  final bool isLiked;
  final VoidCallback onTap;

  const _LikeButton({
    required this.postId,
    required this.isLiked,
    required this.onTap,
  });

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scale,
        child: Icon(
          widget.isLiked ? Icons.favorite : Icons.favorite_border,
          color: widget.isLiked ? Colors.red : AppColors.textPrimary,
          size: 26,
        ),
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  final String postId;
  final bool isSaved;
  final VoidCallback onTap;

  const _SaveButton({
    required this.postId,
    required this.isSaved,
    required this.onTap,
  });

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0);
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scale,
        child: Icon(
          widget.isSaved ? Icons.bookmark : Icons.bookmark_border_outlined,
          color: AppColors.textPrimary,
          size: 26,
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 26, color: AppColors.textPrimary),
    );
  }
}

// =============================================================================
// LIKE COUNT
// =============================================================================
class _PostLikeCount extends ConsumerWidget {
  final PostModel post;
  const _PostLikeCount({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedNotifier = ref.watch(likedPostsProvider.notifier);
    // Watch the liked set so this widget rebuilds when like state changes
    ref.watch(likedPostsProvider.select((ids) => ids.contains(post.id)));
    final count = likedNotifier.adjustedCount(post);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        '${NumberFormatter.compact(count)} ${count == 1 ? 'like' : 'likes'}',
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// =============================================================================
// CAPTION
// =============================================================================
class _PostCaption extends StatefulWidget {
  final PostModel post;
  const _PostCaption({required this.post});

  @override
  State<_PostCaption> createState() => _PostCaptionState();
}

class _PostCaptionState extends State<_PostCaption> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.post.caption == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: widget.post.author.username,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: ' '),
                TextSpan(text: _captionText),
              ],
            ),
            maxLines: _expanded ? null : 2,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
          // "more" / "less" toggle — only shown for long captions
          if (!_expanded && _captionText.length > 80)
            GestureDetector(
              onTap: () => setState(() => _expanded = true),
              child: const Text(
                'more',
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String get _captionText => widget.post.caption ?? '';
}

// =============================================================================
// TIMESTAMP
// =============================================================================
class _PostTimestamp extends StatelessWidget {
  final PostModel post;
  const _PostTimestamp({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Text(
        timeago.format(post.createdAt),
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
