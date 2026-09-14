import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/plan/plan_definition.dart';
import '../../../domain/plan/reading_day.dart';
import '../../../domain/session/reading_session_service.dart';
import '../../reading/providers/reading_providers.dart';

/// Today's reading in one of three states: not started, in progress (live
/// remaining time), completed. The button is the ONLY way to a completion:
/// there is no shortcut that marks a day done without a timed session.
class TodayCard extends ConsumerWidget {
  const TodayCard({
    super.key,
    required this.plan,
    required this.day,
    required this.totalDays,
  });

  final PlanDefinition plan;
  final ReadingDay day;
  final int totalDays;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final completed =
        ref.watch(dayCompletedProvider((plan.id, day.dayIndex))).value ?? false;
    final session = ref.watch(openSessionProvider).value;
    final sessionIsToday =
        session != null &&
        session.planId == plan.id &&
        session.dayIndex == day.dayIndex;
    final timing = sessionIsToday ? ref.watch(sessionTimingProvider) : null;
    final mins = (day.requiredDuration.inSeconds / 60).round();
    final chaptersDone = completed ? day.chapterCount : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's Reading", style: text.labelLarge),
            const SizedBox(height: 8),
            Text(day.label, style: text.headlineSmall),
            const SizedBox(height: 12),
            Text(
              'Day ${day.dayIndex + 1} of $totalDays  ·  $mins min  ·  '
              '${day.verseCount} verses',
              style: text.bodyMedium?.copyWith(color: AppColors.inkSoft),
            ),
            const SizedBox(height: 6),
            Text(
              '$chaptersDone / ${day.chapterCount} chapters completed',
              style: text.bodyMedium?.copyWith(color: AppColors.inkSoft),
            ),
            const SizedBox(height: 24),
            if (completed)
              Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    "Today's reading completed",
                    style: text.titleMedium?.copyWith(color: AppColors.success),
                  ),
                ],
              )
            else if (session != null && !sessionIsToday)
              // A catch-up reading is open. Finish it before starting today's:
              // two open sessions would make "which one is the timer for"
              // ambiguous everywhere.
              FilledButton(
                onPressed: () => context.push('/reading'),
                child: const Text('Continue your open reading'),
              )
            else if (timing != null)
              FilledButton(
                onPressed: () => context.push('/reading'),
                child: Text(
                  timing.clockMovedBack
                      ? 'Clock changed — tap to fix'
                      : timing.isComplete
                      ? 'Mark as Done ✓'
                      : 'Keep reading — ${formatCountdown(timing.remaining)}',
                ),
              )
            else
              FilledButton(
                onPressed: () => _start(context, ref),
                child: const Text('Start Reading'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    await ref
        .read(progressRepositoryProvider)
        .startSession(
          plan: plan,
          day: day,
          nowUtc: ref.read(clockProvider).nowUtc(),
        );
    if (context.mounted) context.push('/reading');
  }
}
