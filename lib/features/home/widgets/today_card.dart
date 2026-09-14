import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/sanctuary.dart';
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
    final fraction = completed ? 1.0 : 0.0;

    // Chapter chips: "Ch 1" within one book, "Gen 49 · Exo 1" across two.
    final multiBook = day.assignments.length > 1;
    final chips = [
      for (final c in day.chapters)
        multiBook ? '${c.book.abbreviation} ${c.chapter}' : 'Ch ${c.chapter}',
    ];

    return Card(
      child: Stack(
        children: [
          // Decorative disc, tucked under the button's corner.
          Positioned(
            right: -40,
            bottom: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.parchmentDeep.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: Overline("Today's Reading")),
                    SoftChip(plan.title.split(' · ').last),
                  ],
                ),
                const SizedBox(height: 14),
                Text(day.label, style: text.headlineLarge),
                const SizedBox(height: 6),
                Text(
                  'Day ${day.dayIndex + 1} of $totalDays · $mins min · '
                  '${day.verseCount} verses',
                  style: text.bodyLarge?.copyWith(color: AppColors.inkSoft),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$chaptersDone / ${day.chapterCount} chapters completed',
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ),
                    Text(
                      '${(fraction * 100).round()}%',
                      style: text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: completed ? AppColors.success : AppColors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ThinBar(fraction),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final label in chips)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: completed
                              ? AppColors.success
                              : AppColors.parchmentDeep,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          completed ? '$label ✓' : label,
                          style: text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: completed ? Colors.white : AppColors.ink,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                if (completed)
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Today's reading completed",
                        style: text.titleMedium?.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  )
                else if (session != null && !sessionIsToday)
                  // A catch-up reading is open. Finish it before starting
                  // today's: two open sessions would make "which one is the
                  // timer for" ambiguous everywhere.
                  FilledButton.icon(
                    onPressed: () => context.push('/reading'),
                    icon: const Icon(Icons.hourglass_top_rounded),
                    label: const Text('Continue your open reading'),
                  )
                else if (timing != null)
                  FilledButton.icon(
                    onPressed: () => context.push('/reading'),
                    icon: Icon(
                      timing.isComplete
                          ? Icons.check_rounded
                          : Icons.hourglass_top_rounded,
                    ),
                    label: Text(
                      timing.clockMovedBack
                          ? 'Clock changed — tap to fix'
                          : timing.isComplete
                          ? 'Mark as Done ✓'
                          : 'Keep reading — ${formatCountdown(timing.remaining)}',
                    ),
                  )
                else
                  FilledButton.icon(
                    onPressed: () => _start(context, ref),
                    icon: const Icon(Icons.menu_book_rounded),
                    label: const Text('Start Reading'),
                  ),
              ],
            ),
          ),
        ],
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
