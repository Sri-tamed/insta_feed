import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// COLOUR PALETTE
// =============================================================================

class AppColors {
  AppColors._();

  // Instagram brand
  static const Color igBlue = Color(0xFF0095F6);
  static const Color igGradientStart = Color(0xFFF9ED32);
  static const Color igGradientMid1 = Color(0xFFEE2A7B);
  static const Color igGradientMid2 = Color(0xFF6228D7);
  static const Color igGradientEnd = Color(0xFF4F5BD5);

  // Text
  static const Color textPrimary = Color(0xFF050505);
  static const Color textSecondary = Color(0xFF8E8E8E);
  static const Color textLight = Color(0xFFDBDBDB);

  // UI
  static const Color background = Colors.white;
  static const Color divider = Color(0xFFEFEFEF);
  static const Color storyRingViewed = Color(0xFFDBDBDB);
  static const Color dotInactive = Color(0xFFDBDBDB);

  // Shimmer
  static const Color shimmerBase = Color(0xFFEDEDED);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF2A2A2A);
  static const Color shimmerHighlightDark = Color(0xFF3A3A3A);
}

// =============================================================================
// GRADIENTS
// =============================================================================

class AppGradients {
  AppGradients._();

  // The iconic Instagram story ring gradient
  static const LinearGradient storyRing = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0xFFF9ED32), // Yellow
      Color(0xFFEE2A7B), // Pink/Red
      Color(0xFF6228D7), // Purple
      Color(0xFF4F5BD5), // Blue-purple
    ],
    stops: [0.0, 0.35, 0.70, 1.0],
  );
}

// =============================================================================
// THEME
// =============================================================================

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.igBlue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 0.3,
        space: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 13.5,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
