import 'package:flutter/material.dart';

/// "Quiet Sanctuary": parchment ground, iron-gall ink, river-clay teal, a
/// little hammered gold. Depth is tonal, never shadowed.
///
/// Every colour the app draws lives here, as a [ThemeExtension] so the same
/// token resolves differently by night. Widgets read them through
/// `context.colors` — never a `const` colour, or dark mode would not reach it.
@immutable
class SanctuaryColors extends ThemeExtension<SanctuaryColors> {
  const SanctuaryColors({
    required this.parchment,
    required this.parchmentDeep,
    required this.card,
    required this.ink,
    required this.inkSoft,
    required this.teal,
    required this.tealDeep,
    required this.onTeal,
    required this.gold,
    required this.success,
    required this.onSuccess,
    required this.missed,
  });

  /// The page ground.
  final Color parchment;

  /// A raised or recessed tint of the ground: chips, tracks, wells.
  final Color parchmentDeep;

  /// Card fill, one step off the ground.
  final Color card;

  /// Primary text.
  final Color ink;

  /// Secondary text, and every icon that is not an accent.
  final Color inkSoft;

  /// The accent: buttons, selected state, progress.
  final Color teal;
  final Color tealDeep;

  /// Text and icons drawn *on* [teal].
  final Color onTeal;

  /// The one warm accent. Used sparingly, for quotation marks and the emblem.
  final Color gold;

  /// Completed.
  final Color success;
  final Color onSuccess;

  /// A missed day. Never red — this app does not scold.
  final Color missed;

  /// Day: warm paper, dark ink.
  static const light = SanctuaryColors(
    parchment: Color(0xFFFBF8F1),
    parchmentDeep: Color(0xFFF1EBDD),
    card: Colors.white,
    ink: Color(0xFF1F3A3D),
    inkSoft: Color(0xFF52696B),
    teal: Color(0xFF2F5D62),
    tealDeep: Color(0xFF14454A),
    onTeal: Colors.white,
    gold: Color(0xFFC6A15B),
    success: Color(0xFF4E7D5B),
    onSuccess: Colors.white,
    missed: Color(0xFFC77B6A),
  );

  /// Night: the same room with the lamp low. Deliberately not black — a
  /// pure-black ground under a 56 px countdown is a glare at 5 a.m.
  static const dark = SanctuaryColors(
    parchment: Color(0xFF0F1718),
    parchmentDeep: Color(0xFF1E2C2E),
    card: Color(0xFF162122),
    ink: Color(0xFFEBE6DA),
    inkSoft: Color(0xFF9FB2B3),
    teal: Color(0xFF7FC0C5),
    tealDeep: Color(0xFFA5D8DC),
    onTeal: Color(0xFF0B1718),
    gold: Color(0xFFD9B878),
    success: Color(0xFF7FB88F),
    onSuccess: Color(0xFF0B1718),
    missed: Color(0xFFD79A88),
  );

  @override
  SanctuaryColors copyWith({
    Color? parchment,
    Color? parchmentDeep,
    Color? card,
    Color? ink,
    Color? inkSoft,
    Color? teal,
    Color? tealDeep,
    Color? onTeal,
    Color? gold,
    Color? success,
    Color? onSuccess,
    Color? missed,
  }) => SanctuaryColors(
    parchment: parchment ?? this.parchment,
    parchmentDeep: parchmentDeep ?? this.parchmentDeep,
    card: card ?? this.card,
    ink: ink ?? this.ink,
    inkSoft: inkSoft ?? this.inkSoft,
    teal: teal ?? this.teal,
    tealDeep: tealDeep ?? this.tealDeep,
    onTeal: onTeal ?? this.onTeal,
    gold: gold ?? this.gold,
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    missed: missed ?? this.missed,
  );

  @override
  SanctuaryColors lerp(ThemeExtension<SanctuaryColors>? other, double t) {
    if (other is! SanctuaryColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return SanctuaryColors(
      parchment: c(parchment, other.parchment),
      parchmentDeep: c(parchmentDeep, other.parchmentDeep),
      card: c(card, other.card),
      ink: c(ink, other.ink),
      inkSoft: c(inkSoft, other.inkSoft),
      teal: c(teal, other.teal),
      tealDeep: c(tealDeep, other.tealDeep),
      onTeal: c(onTeal, other.onTeal),
      gold: c(gold, other.gold),
      success: c(success, other.success),
      onSuccess: c(onSuccess, other.onSuccess),
      missed: c(missed, other.missed),
    );
  }
}

/// `context.colors.ink` — the only way widgets should reach a colour.
extension SanctuaryColorsX on BuildContext {
  SanctuaryColors get colors =>
      Theme.of(this).extension<SanctuaryColors>() ?? SanctuaryColors.light;
}

const kFontFamily = 'PlusJakartaSans';

/// For the reading timer: a countdown is not a disabled button, so it keeps
/// the full teal even while it cannot be pressed. Everything else that is
/// disabled looks disabled.
ButtonStyle timerButtonStyle(SanctuaryColors c) => FilledButton.styleFrom(
  disabledBackgroundColor: c.teal,
  disabledForegroundColor: c.onTeal,
);

ThemeData buildAppTheme(Brightness brightness) {
  final c = brightness == Brightness.dark
      ? SanctuaryColors.dark
      : SanctuaryColors.light;

  final scheme = ColorScheme.fromSeed(
    seedColor: c.teal,
    brightness: brightness,
    surface: c.parchment,
    primary: c.teal,
    onPrimary: c.onTeal,
    secondary: c.gold,
    onSurface: c.ink,
    onSurfaceVariant: c.inkSoft,
    outlineVariant: c.parchmentDeep,
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
      .apply(fontFamily: kFontFamily, bodyColor: c.ink, displayColor: c.ink);

  return base.copyWith(
    extensions: [c],
    textTheme: text,
    scaffoldBackgroundColor: c.parchment,
    appBarTheme: AppBarTheme(
      backgroundColor: c.parchment,
      foregroundColor: c.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: c.card,
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
        foregroundColor: c.teal,
        textStyle: text.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.card,
      hintStyle: text.bodyLarge?.copyWith(color: c.inkSoft),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c.teal, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.parchmentDeep,
      selectedColor: c.teal,
      disabledColor: c.parchmentDeep,
      labelStyle: text.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: c.ink,
      ),
      secondaryLabelStyle: text.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: c.onTeal,
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
          (s) => s.contains(WidgetState.selected) ? c.teal : c.parchmentDeep,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.onTeal : c.ink,
        ),
        textStyle: WidgetStatePropertyAll(
          text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.parchment,
      indicatorColor: c.parchmentDeep,
      elevation: 0,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => text.labelSmall?.copyWith(
          fontSize: 12,
          color: s.contains(WidgetState.selected) ? c.teal : c.inkSoft,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? c.teal : c.inkSoft,
        ),
      ),
    ),
    dividerTheme: DividerThemeData(color: c.parchmentDeep, thickness: 1),
    listTileTheme: ListTileThemeData(
      iconColor: c.inkSoft,
      titleTextStyle: text.bodyLarge,
      subtitleTextStyle: text.bodySmall?.copyWith(color: c.inkSoft),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.parchment,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.parchment,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.teal,
      linearTrackColor: c.parchmentDeep,
      circularTrackColor: c.parchmentDeep,
    ),
  );
}
