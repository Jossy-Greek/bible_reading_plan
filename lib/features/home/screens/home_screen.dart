import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
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
    final streak = ref.watch(streakProvider).value;
    final shownStreak = streak == null
        ? 0
        : ref.watch(streakServiceProvider).displayed(streak, clock.today());

    final hour = clock.nowLocal().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
        ? 'Good afternoon'
        : 'Good evening';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$greeting, $name 👋',
                    style: text.headlineMedium,
                  ),
                ),
                if (shownStreak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.parchmentDeep,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('🔥 $shownStreak', style: text.titleMedium),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            plan.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Could not load your plan: $e'),
              data: (p) {
                if (p == null) return const Text('No plan yet.');
                if (today == null) {
                  if (days.isEmpty) {
                    return Text(
                      'Preparing your plan…',
                      style: text.titleMedium,
                    );
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
                                ? 'Your plan starts on ${p.startDate}.'
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
          ],
        ),
      ),
    );
  }
}
