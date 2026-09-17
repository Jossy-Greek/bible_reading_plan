import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/time/format.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/calendar/plan_calendar.dart';
import '../../reading/providers/reading_providers.dart';
import '../providers/calendar_providers.dart';

Future<void> showDayDetail(BuildContext context, LocalDate date) =>
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => _DayDetail(date: date),
    );

class _DayDetail extends ConsumerWidget {
  const _DayDetail({required this.date});
  final LocalDate date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final cal = ref.watch(planCalendarProvider);
    final day = cal?.dayOn(date);
    final status = cal?.statusOn(date) ?? DayStatus.outsidePlan;
    final openSession = ref.watch(openSessionProvider).value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formatLongDate(date), style: text.titleMedium),
          const SizedBox(height: 8),
          if (day == null) ...[
            Text('No reading scheduled.', style: text.bodyLarge),
          ] else ...[
            Text(day.label, style: text.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Day ${day.dayIndex + 1}  ·  ${day.chapterCount} chapters  ·  '
              '${(day.requiredDuration.inSeconds / 60).round()} min',
              style: text.bodyMedium?.copyWith(color: context.colors.inkSoft),
            ),
            const SizedBox(height: 20),
            switch (status) {
              DayStatus.completed => Row(
                children: [
                  Icon(Icons.check_circle, color: context.colors.success),
                  const SizedBox(width: 8),
                  Text(
                    'Completed ✓',
                    style: text.titleMedium?.copyWith(
                      color: context.colors.success,
                    ),
                  ),
                ],
              ),
              DayStatus.future => Text(
                'Not yet — this reading opens on its day.',
                style: text.bodyLarge?.copyWith(color: context.colors.inkSoft),
              ),
              DayStatus.missed || DayStatus.todayPending => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    status == DayStatus.missed
                        ? 'Not completed. You can still read it.'
                        : 'Not completed yet.',
                    style: text.bodyLarge?.copyWith(
                      color: context.colors.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (openSession != null &&
                      openSession.dayIndex != day.dayIndex)
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push('/reading');
                      },
                      child: const Text('Finish your open reading first'),
                    )
                  else
                    FilledButton(
                      onPressed: () async {
                        final plan = ref.read(activePlanProvider).value;
                        if (plan == null) return;
                        if (openSession == null) {
                          await ref
                              .read(progressRepositoryProvider)
                              .startSession(
                                plan: plan,
                                day: day,
                                nowUtc: ref.read(clockProvider).nowUtc(),
                              );
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          context.push('/reading');
                        }
                      },
                      child: Text(
                        openSession != null
                            ? 'Continue reading'
                            : status == DayStatus.missed
                            ? 'Read this day'
                            : 'Start Reading',
                      ),
                    ),
                ],
              ),
              DayStatus.outsidePlan => const SizedBox.shrink(),
            },
          ],
        ],
      ),
    );
  }
}
