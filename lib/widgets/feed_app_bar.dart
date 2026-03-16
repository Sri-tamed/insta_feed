import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Replicates Instagram's top navigation bar.
///
/// Left: Instagram wordmark (gradient-coloured text simulating the logo)
/// Right: Notification heart + DM paper plane icons
class FeedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMessagesTap;
  final int notificationCount;

  const FeedAppBar({
    super.key,
    this.onNotificationTap,
    this.onMessagesTap,
    this.notificationCount = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0.8,
      leadingWidth: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            // Instagram wordmark — gradient effect via ShaderMask
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppGradients.storyRing.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: const Text(
                'Instagram',
                style: TextStyle(
                  fontFamily: 'Billabong', // Falls back gracefully
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.5,
                  color: Colors.white, // Masked by shader
                ),
              ),
            ),
            // Chevron down for account switching (Instagram detail)
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.textPrimary,
            ),
            const Spacer(),
            // Notification heart icon
            _TopBarIconButton(
              icon: Icons.favorite_border_rounded,
              badge: notificationCount,
              onTap: onNotificationTap ??
                  () => _showSnackbar(context, 'Notifications coming soon'),
            ),
            const SizedBox(width: 4),
            // Messages / DM icon
            _TopBarIconButton(
              icon: Icons.send_outlined,
              badge: 3, // Mock unread count
              onTap: onMessagesTap ??
                  () => _showSnackbar(context, 'Messages coming soon'),
            ),
          ],
        ),
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

class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final int badge;
  final VoidCallback? onTap;

  const _TopBarIconButton({
    required this.icon,
    this.badge = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 27, color: AppColors.textPrimary),
            if (badge > 0)
              Positioned(
                top: -3,
                right: -4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badge > 9 ? '9+' : badge.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
