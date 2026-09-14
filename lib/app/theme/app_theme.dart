import 'package:flutter/material.dart';

/// Warm parchment ground, deep teal ink, a little gold. Quiet on purpose:
/// the app is a companion to reading, not the thing being read.
abstract final class AppColors {
  static const parchment = Color(0xFFFBF8F1);
  static const parchmentDeep = Color(0xFFF1EBDD);
  static const ink = Color(0xFF1F3A3D);
  static const inkSoft = Color(0xFF52696B);
  static const teal = Color(0xFF2F5D62);
  static const gold = Color(0xFFC6A15B);
  static const success = Color(0xFF4E7D5B);
  static const missed = Color(0xFFC77B6A);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.teal,
    brightness: Brightness.light,
    surface: AppColors.parchment,
    primary: AppColors.teal,
    onPrimary: Colors.white,
    secondary: AppColors.gold,
    onSurface: AppColors.ink,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.parchment,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.parchment,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
  );
}
