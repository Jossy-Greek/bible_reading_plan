import 'package:flutter/material.dart';

/// "Quiet Sanctuary": parchment ground, iron-gall ink, river-clay teal, a
/// little hammered gold. Depth is tonal, never shadowed.
abstract final class AppColors {
  static const parchment = Color(0xFFFBF8F1);
  static const parchmentDeep = Color(0xFFF1EBDD);
  static const ink = Color(0xFF1F3A3D);
  static const inkSoft = Color(0xFF52696B);
  static const teal = Color(0xFF2F5D62);
  static const tealDeep = Color(0xFF14454A);
  static const gold = Color(0xFFC6A15B);
  static const success = Color(0xFF4E7D5B);
  static const missed = Color(0xFFC77B6A);
  static const card = Colors.white;
}

const kFontFamily = 'PlusJakartaSans';

/// For the reading timer: a countdown is not a disabled button, so it keeps
/// the full teal even while it cannot be pressed. Everything else that is
/// disabled looks disabled.
final ButtonStyle kTimerButtonStyle = FilledButton.styleFrom(
  disabledBackgroundColor: AppColors.teal,
  disabledForegroundColor: Colors.white,
);

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.teal,
    brightness: Brightness.light,
    surface: AppColors.parchment,
    primary: AppColors.teal,
    onPrimary: Colors.white,
    secondary: AppColors.gold,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.inkSoft,
    outlineVariant: AppColors.parchmentDeep,
  );
  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    fontFamily: kFontFamily,
  );

  // Sizes from the design system's type scale. Weights: headlines 600,
  // body 400, labels 600 with a little tracking, the countdown 300.
  final text = base.textTheme
      .copyWith(
        displayLarge: const TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w300,
          height: 64 / 56,
          letterSpacing: -1.1,
        ),
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 40 / 32,
          letterSpacing: -0.3,
        ),
        headlineMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 36 / 28,
          letterSpacing: -0.2,
        ),
        headlineSmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 32 / 24,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 28 / 20,
        ),
        titleMedium: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 24 / 18,
        ),
        titleSmall: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 20 / 15,
        ),
        bodyLarge: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          height: 26 / 17,
        ),
        bodyMedium: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 22 / 15,
        ),
        bodySmall: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 18 / 13,
        ),
        labelLarge: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          height: 22 / 17,
        ),
        labelMedium: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 18 / 13,
          letterSpacing: 0.5,
        ),
        labelSmall: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 16 / 11,
          letterSpacing: 0.6,
        ),
      )
      .apply(
        fontFamily: kFontFamily,
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      );

  return base.copyWith(
    textTheme: text,
    scaffoldBackgroundColor: AppColors.parchment,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.parchment,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.teal,
        textStyle: text.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      hintStyle: text.bodyLarge?.copyWith(color: AppColors.inkSoft),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.parchmentDeep,
      selectedColor: AppColors.teal,
      disabledColor: AppColors.parchmentDeep,
      labelStyle: text.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      secondaryLabelStyle: text.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      side: BorderSide.none,
      shape: const StadiumBorder(),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        side: const WidgetStatePropertyAll(BorderSide.none),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.teal
              : AppColors.parchmentDeep,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.selected) ? Colors.white : AppColors.ink,
        ),
        textStyle: WidgetStatePropertyAll(
          text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.parchment,
      indicatorColor: AppColors.parchmentDeep,
      elevation: 0,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => text.labelSmall?.copyWith(
          fontSize: 12,
          color: s.contains(WidgetState.selected)
              ? AppColors.teal
              : AppColors.inkSoft,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? AppColors.teal
              : AppColors.inkSoft,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.parchmentDeep,
      thickness: 1,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.inkSoft,
      titleTextStyle: text.bodyLarge,
      subtitleTextStyle: text.bodySmall?.copyWith(color: AppColors.inkSoft),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.parchment,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.parchment,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.teal,
      linearTrackColor: AppColors.parchmentDeep,
      circularTrackColor: AppColors.parchmentDeep,
    ),
  );
}
