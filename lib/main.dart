import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait — Instagram Home Feed is portrait-only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Make the status bar transparent so the white AppBar bleeds into it
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(
    // ProviderScope is the root widget required by Riverpod.
    // It initialises the container that holds all provider state.
    const ProviderScope(
      child: InstagramFeedApp(),
    ),
  );
}

class InstagramFeedApp extends StatelessWidget {
  const InstagramFeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram Feed',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // ScaffoldMessenger at root so any widget can show SnackBars
      builder: (context, child) {
        // Enforce max text scale to prevent layout overflow
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}
