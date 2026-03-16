import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Instagram's bottom navigation bar — 5 tabs.
/// Only the Home tab is active; others trigger a SnackBar.
///
/// Uses a custom painter-free approach with pure Icons to match
/// Instagram's icon weight and sizing precisely.
class FeedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const FeedBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                isActive: currentIndex == 0,
                onTap: () => onTap?.call(0),
              ),
              _NavItem(
                icon: Icons.search_rounded,
                activeIcon: Icons.search_rounded,
                isActive: currentIndex == 1,
                onTap: () => onTap?.call(1),
              ),
              _NavItem(
                icon: Icons.add_box_outlined,
                activeIcon: Icons.add_box,
                isActive: currentIndex == 2,
                onTap: () => onTap?.call(2),
              ),
              _NavItem(
                icon: Icons.movie_creation_outlined,
                activeIcon: Icons.movie_creation,
                isActive: currentIndex == 3,
                onTap: () => onTap?.call(3),
              ),
              // Profile avatar tab
              _ProfileNavItem(
                avatarUrl: 'https://i.pravatar.cc/150?img=50',
                isActive: currentIndex == 4,
                onTap: () => onTap?.call(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 52,
        height: 50,
        child: Center(
          child: Icon(
            isActive ? activeIcon : icon,
            size: 28,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ProfileNavItem extends StatelessWidget {
  final String avatarUrl;
  final bool isActive;
  final VoidCallback onTap;

  const _ProfileNavItem({
    required this.avatarUrl,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 52,
        height: 50,
        child: Center(
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isActive
                  ? Border.all(color: AppColors.textPrimary, width: 1.5)
                  : null,
            ),
            child: ClipOval(
              child: Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person_outline, size: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
