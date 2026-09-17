import 'package:bible_reading_plan/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('both themes carry a Sanctuary palette', () {
    for (final b in Brightness.values) {
      final t = buildAppTheme(b);
      expect(
        t.extension<SanctuaryColors>(),
        isNotNull,
        reason: 'widgets read every colour through this extension',
      );
    }
  });

  test('the dark palette is actually dark, and inverts ink and ground', () {
    final light = SanctuaryColors.light;
    final dark = SanctuaryColors.dark;
    expect(dark.parchment.computeLuminance(), lessThan(0.1));
    expect(light.parchment.computeLuminance(), greaterThan(0.8));
    expect(
      dark.ink.computeLuminance(),
      greaterThan(dark.parchment.computeLuminance()),
    );
    expect(
      light.ink.computeLuminance(),
      lessThan(light.parchment.computeLuminance()),
    );
  });

  test('body text keeps a readable contrast ratio on its own ground', () {
    // WCAG AA for body text is 4.5:1.
    double ratio(Color fg, Color bg) {
      final a = fg.computeLuminance(), b = bg.computeLuminance();
      final (hi, lo) = a > b ? (a, b) : (b, a);
      return (hi + 0.05) / (lo + 0.05);
    }

    for (final c in [SanctuaryColors.light, SanctuaryColors.dark]) {
      expect(ratio(c.ink, c.parchment), greaterThanOrEqualTo(4.5));
      expect(ratio(c.ink, c.card), greaterThanOrEqualTo(4.5));
      expect(ratio(c.inkSoft, c.parchment), greaterThanOrEqualTo(4.5));
      expect(ratio(c.onTeal, c.teal), greaterThanOrEqualTo(4.5));
      expect(ratio(c.onSuccess, c.success), greaterThanOrEqualTo(4.5));
    }
  });

  test('the theme resolves through buildAppTheme, not a const default', () {
    expect(
      buildAppTheme(Brightness.dark).extension<SanctuaryColors>()!.parchment,
      SanctuaryColors.dark.parchment,
    );
    expect(
      buildAppTheme(Brightness.light).extension<SanctuaryColors>()!.parchment,
      SanctuaryColors.light.parchment,
    );
  });
}
