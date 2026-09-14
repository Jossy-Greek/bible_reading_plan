import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
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
      appBar: AppBar(
        title: const Text('Achievements'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                '${unlocked.length} / ${kBadges.length}',
                style: text.titleMedium?.copyWith(color: AppColors.inkSoft),
              ),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemCount: kBadges.length,
        itemBuilder: (_, i) =>
            _BadgeTile(badge: kBadges[i], unlockedAt: unlocked[kBadges[i].id]),
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
    final text = Theme.of(context).textTheme;
    final earned = unlockedAt != null;
    return Card(
      color: earned
          ? Colors.white
          : AppColors.parchmentDeep.withValues(alpha: 0.6),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                color: earned ? AppColors.ink : AppColors.inkSoft,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              earned
                  ? 'Earned ${formatMediumDate(LocalDate.fromDateTime(unlockedAt!.toLocal()))}'
                  : badge.description,
              style: text.bodySmall?.copyWith(color: AppColors.inkSoft),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
