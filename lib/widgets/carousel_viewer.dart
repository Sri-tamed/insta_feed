import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme/app_theme.dart';

// =============================================================================
// PINCH TO ZOOM OVERLAY
// =============================================================================

/// Wraps a child widget and adds pinch-to-zoom capability.
///
/// Implementation strategy:
/// 1. GestureDetector catches scale (pinch) events
/// 2. On scale start — create an OverlayEntry containing the image
///    at its exact position (using RenderBox transform)
/// 3. InteractiveViewer handles the actual zoom transform
/// 4. On scale end — animate scale back to 1.0 then remove overlay
///
/// This approach lifts the image ABOVE the feed UI, exactly like Instagram.
class PinchZoomOverlay extends StatefulWidget {
  final Widget child;
  final String imageUrl;

  const PinchZoomOverlay({
    super.key,
    required this.child,
    required this.imageUrl,
  });

  @override
  State<PinchZoomOverlay> createState() => _PinchZoomOverlayState();
}

class _PinchZoomOverlayState extends State<PinchZoomOverlay>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  final TransformationController _transformController =
      TransformationController();

  late AnimationController _animController;
  Animation<Matrix4>? _animation;

  bool _isZooming = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        if (_animation != null) {
          _transformController.value = _animation!.value;
        }
      });

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _removeOverlay();
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _transformController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onInteractionStart(ScaleStartDetails details) {
    if (details.pointerCount < 2) return; // Only activate on pinch
    if (!_isZooming) {
      _isZooming = true;
      _showOverlay();
    }
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    if (!_isZooming) return;
    _isZooming = false;

    // Animate back to identity matrix (original size/position)
    _animation = Matrix4Tween(
      begin: _transformController.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward(from: 0);
  }

  void _showOverlay() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (_) => _ZoomOverlayWidget(
        offset: offset,
        size: size,
        imageUrl: widget.imageUrl,
        transformController: _transformController,
        onInteractionStart: _onInteractionStart,
        onInteractionEnd: _onInteractionEnd,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _transformController.value = Matrix4.identity();
    _animController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _onInteractionStart,
      onScaleEnd: _onInteractionEnd,
      child: widget.child,
    );
  }
}

/// The actual overlay widget shown during zoom.
/// Positioned at the exact screen location of the original image.
class _ZoomOverlayWidget extends StatelessWidget {
  final Offset offset;
  final Size size;
  final String imageUrl;
  final TransformationController transformController;
  final void Function(ScaleStartDetails) onInteractionStart;
  final void Function(ScaleEndDetails) onInteractionEnd;

  const _ZoomOverlayWidget({
    required this.offset,
    required this.size,
    required this.imageUrl,
    required this.transformController,
    required this.onInteractionStart,
    required this.onInteractionEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Semi-transparent backdrop
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
          // The zoomed image — positioned at original location
          Positioned(
            left: offset.dx,
            top: offset.dy,
            width: size.width,
            height: size.height,
            child: InteractiveViewer(
              transformationController: transformController,
              minScale: 0.5,
              maxScale: 5.0,
              panEnabled: true,
              onInteractionStart: onInteractionStart,
              onInteractionEnd: onInteractionEnd,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: size.width,
                height: size.height,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CAROUSEL VIEWER
// =============================================================================

/// Displays a horizontal PageView with a synchronized dot indicator below.
/// The dot indicator uses smooth_page_indicator for the Instagram-style
/// "sliding dot" animation.
class CarouselViewer extends StatefulWidget {
  final List<String> imageUrls;
  final double aspectRatio;

  const CarouselViewer({
    super.key,
    required this.imageUrls,
    this.aspectRatio = 1.0, // Square by default
  });

  @override
  State<CarouselViewer> createState() => _CarouselViewerState();
}

class _CarouselViewerState extends State<CarouselViewer> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (_, index) {
              return PinchZoomOverlay(
                imageUrl: widget.imageUrls[index],
                child: _PostImage(imageUrl: widget.imageUrls[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Dot indicator — synchronized via PageController
        SmoothPageIndicator(
          controller: _pageController,
          count: widget.imageUrls.length,
          effect: const ExpandingDotsEffect(
            activeDotColor: AppColors.igBlue,
            dotColor: AppColors.dotInactive,
            dotHeight: 6,
            dotWidth: 6,
            expansionFactor: 2.5,
            spacing: 4,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// =============================================================================
// SINGLE POST IMAGE
// =============================================================================

/// Handles network image loading with error and placeholder states.
class _PostImage extends StatelessWidget {
  final String imageUrl;

  const _PostImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      // Fade in animation matches Instagram's feel
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: (_, __) => Container(
        color: AppColors.shimmerBase,
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.shimmerBase,
        child: const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
        ),
      ),
    );
  }
}

/// Single image post (not carousel) with pinch-to-zoom
class SingleImagePost extends StatelessWidget {
  final String imageUrl;

  const SingleImagePost({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: PinchZoomOverlay(
        imageUrl: imageUrl,
        child: _PostImage(imageUrl: imageUrl),
      ),
    );
  }
}
