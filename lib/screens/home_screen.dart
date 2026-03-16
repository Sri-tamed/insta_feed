import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import 'feed_screen.dart';

/// Top-level screen that hosts the bottom nav bar and manages tab switching.
/// Only the Home tab (index 0) renders real content — other tabs show a
/// placeholder SnackBar message, matching the assignment's requirement for
/// unimplemented screens to give user feedback.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    if (index == 0) {
      setState(() => _currentIndex = 0);
      return;
    }
    // All other tabs are unimplemented — show snackbar
    const labels = ['Home', 'Search', 'Create', 'Reels', 'Profile'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${labels[index]} coming soon'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // IndexedStack keeps FeedScreen alive even when switching tabs —
      // critical to preserve scroll position and loaded state.
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          FeedScreen(),
          // Other tabs intentionally left as empty containers —
          // IndexedStack requires matching children count
          _PlaceholderScreen(label: 'Search'),
          _PlaceholderScreen(label: 'Create'),
          _PlaceholderScreen(label: 'Reels'),
          _PlaceholderScreen(label: 'Profile'),
        ],
      ),
      bottomNavigationBar: FeedBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

/// Intentionally minimal — not part of the assignment scope.
class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
