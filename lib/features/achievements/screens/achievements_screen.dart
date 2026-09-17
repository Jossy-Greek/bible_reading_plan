import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/sanctuary.dart';
import '../../../core/time/format.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/achievements/badges.dart';
import '../providers/achievement_providers.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final unlocked = ref.watch(unlockedBadgesProvider).value ?? const {};
    return Scaffold(
      appBar: SanctuaryAppBar(
        title: 'Badges',
        trailing: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              '${unlocked.length} / ${kBadges.length}',
              style: text.titleMedium?.copyWith(color: context.colors.inkSoft),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          for (final c in BadgeCategory.values) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 10),
              child: Row(
                children: [
                  Expanded(child: Text(c.title, style: text.titleMedium)),
                  Text(
                    '${kBadges.where((b) => b.category == c && unlocked.containsKey(b.id)).length}'
                    ' / ${kBadges.where((b) => b.category == c).length}',
                    style: text.bodySmall?.copyWith(
                      color: context.colors.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: scaledExtent(context, 158),
              ),
              children: [
                for (final b in kBadges.where((b) => b.category == c))
                  _BadgeTile(badge: b, unlockedAt: unlocked[b.id]),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.unlockedAt});

  final BadgeDefinition badge;
  final DateTime? unlockedAt;

  @override
  Widget build(BuildContext context) {
    final earned = unlockedAt != null;
    final earnedOn = earned
        ? formatMediumDate(LocalDate.fromDateTime(unlockedAt!.toLocal()))
        : null;
    return Semantics(
      label: earned
          ? '${badge.title}, earned $earnedOn'
          : '${badge.title}, not yet earned. ${badge.description}',
      excludeSemantics: true,
      child: _tile(context, earned, earnedOn),
    );
  }

  Widget _tile(BuildContext context, bool earned, String? earnedOn) {
    final text = Theme.of(context).textTheme;
    return Card(
      color: earned
          ? context.colors.card
          : context.colors.parchmentDeep.withValues(alpha: 0.6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: earned ? 1 : 0.35,
              child: Text(badge.emoji, style: text.headlineMedium),
            ),
            const Spacer(),
            Text(
              badge.title,
              style: text.titleSmall?.copyWith(
                color: earned ? context.colors.ink : context.colors.inkSoft,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              earned ? 'Earned $earnedOn' : badge.description,
              style: text.bodySmall?.copyWith(color: context.colors.inkSoft),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
