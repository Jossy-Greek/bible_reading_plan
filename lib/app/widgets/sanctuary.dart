import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers.dart';
import '../theme/app_theme.dart';
import '../../features/reading/providers/reading_providers.dart';

/// The app mark: a parchment tile holding a teal book with a gold marker.
class Emblem extends StatelessWidget {
  const Emblem({super.key, this.size = 40});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.colors.parchmentDeep,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            color: context.colors.teal,
            size: size * 0.55,
          ),
          Positioned(
            top: size * 0.17,
            child: Container(
              width: size * 0.13,
              height: size * 0.13,
              decoration: BoxDecoration(
                color: context.colors.gold,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small uppercase tracking label: "TODAY'S READING", "SEPTEMBER PACE".
class Overline extends StatelessWidget {
  const Overline(this.text, {super.key, this.color});
  final String text;

  /// Defaults to `inkSoft`, resolved at build so dark mode reaches it.
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: color ?? context.colors.inkSoft,
      letterSpacing: 1.1,
      fontWeight: FontWeight.w600,
    ),
  );
}

/// "🔥 7" on parchment deep. Hidden entirely when the streak is 0: an empty
/// flame is a reproach, and the app does not do those.
class StreakPill extends ConsumerWidget {
  const StreakPill({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider).value;
    final today = ref.watch(clockProvider).today();
    final n = streak == null
        ? 0
        : ref.watch(streakServiceProvider).displayed(streak, today);
    if (n == 0) return const SizedBox.shrink();
    return Semantics(
      label: '$n day reading streak',
      excludeSemantics: true,
      child: _pill(context, n),
    );
  }

  Widget _pill(BuildContext context, int n) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: context.colors.parchmentDeep,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '🔥 $n',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// The app bar every tab shares: emblem, overline + title, streak pill, and a
/// teal profile button that opens Settings.
class SanctuaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SanctuaryAppBar({
    super.key,
    required this.title,
    this.overline = 'Bible Reading Plan',
    this.leading,
    this.trailing = const [],
    this.showStreak = true,
    this.showProfile = true,
  });

  final String title;
  final String overline;
  final Widget? leading;
  final List<Widget> trailing;
  final bool showStreak;
  final bool showProfile;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      color: context.colors.parchment,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            children: [
              leading ?? const Emblem(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Overline(overline, color: context.colors.teal),
                    Text(title, style: text.titleLarge),
                  ],
                ),
              ),
              ...trailing,
              if (showStreak) ...[
                const StreakPill(compact: true),
                const SizedBox(width: 10),
              ],
              if (showProfile)
                InkWell(
                  onTap: () => context.go('/settings'),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.colors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: context.colors.onTeal,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The height a grid tile needs at the reader's chosen text size.
///
/// `childAspectRatio` ties a tile's height to its width, so at 200% font
/// scale the content overflows and Flutter paints the yellow bars. Passing
/// this as `mainAxisExtent` instead lets the tile grow with the text.
double scaledExtent(BuildContext context, double base) =>
    MediaQuery.textScalerOf(context).scale(base);

/// A small tinted circle with an icon, used as a leading mark in cards.
class IconWell extends StatelessWidget {
  const IconWell(this.icon, {super.key, this.size = 44, this.color});
  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? context.colors.parchmentDeep,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: context.colors.teal, size: size * 0.5),
    ),
  );
}

/// 6 px rounded bar on a parchment-deep rail. Green at 100%.
class ThinBar extends StatelessWidget {
  const ThinBar(this.value, {super.key, this.height = 6, this.color});
  final double value;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(999),
    child: LinearProgressIndicator(
      value: value.clamp(0.0, 1.0),
      minHeight: height,
      backgroundColor: context.colors.parchmentDeep,
      color:
          color ?? (value >= 1 ? context.colors.success : context.colors.teal),
    ),
  );
}

/// Parchment-deep pill: "Pending", "One year", "~15 min".
class SoftChip extends StatelessWidget {
  const SoftChip(this.label, {super.key, this.color, this.textColor});
  final String label;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color ?? context.colors.parchmentDeep,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: textColor ?? context.colors.ink,
      ),
    ),
  );
}
