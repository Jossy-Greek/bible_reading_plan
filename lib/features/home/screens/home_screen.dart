import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/sanctuary.dart';
import '../../../core/time/format.dart';
import '../../../core/verses.dart';
import '../../../domain/achievements/badges.dart';
import '../../achievements/providers/achievement_providers.dart';
import '../../calendar/providers/calendar_providers.dart';
import '../../reading/providers/reading_providers.dart';
import '../widgets/today_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final name = ref.watch(settingsProvider).name ?? '';
    final clock = ref.watch(clockProvider);
    final plan = ref.watch(activePlanProvider);
    final days = ref.watch(scheduleProvider).value ?? const [];
    final today = ref.watch(todayReadingProvider);
    final cal = ref.watch(planCalendarProvider);
    final badges = ref.watch(unlockedBadgesProvider).value ?? const {};

    final now = clock.nowLocal();
    final greeting = now.hour < 12
        ? 'Good morning'
        : now.hour < 18
        ? 'Good afternoon'
        : 'Good evening';
    final verse = verseFor(today?.dayIndex ?? clock.today().epochDay);
    final tomorrow = today != null && today.dayIndex + 1 < days.length
        ? days[today.dayIndex + 1]
        : null;

    return Scaffold(
      appBar: const SanctuaryAppBar(title: 'Home'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Overline(DateFormat('EEEE, d MMMM').format(now)),
          const SizedBox(height: 4),
          Text('$greeting, $name 👋', style: text.headlineMedium),
          const SizedBox(height: 20),
          plan.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Could not load your plan: $e'),
            data: (p) {
              if (p == null) return const Text('No plan yet.');
              if (today == null) {
                if (days.isEmpty) {
                  return Text('Preparing your plan…', style: text.titleMedium);
                }
                final beforeStart = clock.today().isBefore(p.startDate);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          beforeStart
                              ? 'Your plan starts on ${formatMediumDate(p.startDate)}.'
                              : 'Your plan has finished. 🎉',
                          style: text.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context.push('/settings/plan'),
                          child: Text(
                            beforeStart ? 'Change plan' : 'Start a new plan',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return TodayCard(plan: p, day: today, totalDays: days.length);
            },
          ),
          const SizedBox(height: 16),

          // A verse, as a quiet accent. Rotates with the plan day.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '❝',
                        style: text.titleLarge?.copyWith(color: AppColors.gold),
                      ),
                      const SizedBox(width: 8),
                      const Overline('Verse for today'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '"${verse.text}"',
                    style: text.titleLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    verse.ref,
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.inkSoft,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (tomorrow != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.parchmentDeep.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const IconWell(
                    Icons.wb_twilight_outlined,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Overline("Tomorrow's passage"),
                        const SizedBox(height: 2),
                        Text(tomorrow.label, style: text.titleLarge),
                      ],
                    ),
                  ),
                  SoftChip(
                    '~${(tomorrow.requiredDuration.inSeconds / 60).round()} min',
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          // Outside the plan: a passage on its own, timed like any reading.
          Card(
            child: InkWell(
              onTap: () => context.push('/passages'),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const IconWell(Icons.explore_outlined),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Overline('One-time reading'),
                          const SizedBox(height: 2),
                          Text(
                            'Read a passage outside your plan',
                            style: text.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sermon on the Mount, Psalm 23, any chapters you choose',
                            style: text.bodySmall?.copyWith(
                              color: AppColors.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.inkSoft),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickTile(
                  icon: Icons.calendar_month_outlined,
                  label: 'Calendar',
                  value: cal == null
                      ? '—'
                      : '${cal.completedCount} of ${cal.days.length} days',
                  onTap: () => context.go('/calendar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickTile(
                  icon: Icons.military_tech_outlined,
                  label: 'Badges',
                  value: '${badges.length} of ${kBadges.length} earned',
                  onTap: () => context.go('/achievements'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconWell(icon),
              const SizedBox(height: 32),
              Text(
                label,
                style: text.bodyMedium?.copyWith(color: AppColors.inkSoft),
              ),
              const SizedBox(height: 2),
              Text(value, style: text.titleSmall),
            ],
          ),
        ),
      ),
    );
  }
}
