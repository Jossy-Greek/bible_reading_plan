import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/time/format.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/calendar/plan_calendar.dart';

/// The whole journey as a week-column heatmap, Monday at the top.
///
/// Spans the plan from its first Monday to its last Sunday, so a 90-day plan
/// is 13 columns and a 2-year plan scrolls sideways. Intensity is the day's
/// chapter count in four steps; missed days are a soft red; today is ringed.
class YearHeatmap extends StatelessWidget {
  const YearHeatmap({super.key, required this.calendar, required this.onTap});

  final PlanCalendar calendar;
  final ValueChanged<LocalDate> onTap;

  static const _cell = 14.0;
  static const _gap = 3.0;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final first = calendar.start.plusDays(-(calendar.start.weekday - 1));
    final last = calendar.end.plusDays(7 - calendar.end.weekday);
    final weeks = (first.daysUntil(last) + 1) ~/ 7;
    final maxChapters = calendar.days.fold<int>(
      0,
      (m, d) => d.chapterCount > m ? d.chapterCount : m,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month labels over the first column of each month.
              Row(
                children: [
                  for (var w = 0; w < weeks; w++)
                    SizedBox(
                      width: _cell + _gap,
                      child: _monthLabel(first.plusDays(w * 7), w == 0, text),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  for (var w = 0; w < weeks; w++)
                    Column(
                      children: [
                        for (var r = 0; r < 7; r++)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: _gap,
                              bottom: _gap,
                            ),
                            child: _cellFor(
                              first.plusDays(w * 7 + r),
                              maxChapters,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            _legend(AppColors.success.withValues(alpha: 0.35), 'Lighter day'),
            _legend(AppColors.success, 'Heavier day'),
            _legend(AppColors.missed.withValues(alpha: 0.35), 'Missed'),
            _legend(AppColors.parchmentDeep, 'Ahead'),
          ],
        ),
      ],
    );
  }

  Widget _monthLabel(LocalDate weekStart, bool isFirst, TextTheme text) {
    // Label a column when the month changes within it (or on the first).
    final weekEnd = weekStart.plusDays(6);
    final show =
        isFirst ||
        weekStart.month != weekStart.plusDays(-1).month ||
        weekEnd.month != weekStart.month && weekEnd.day <= 7;
    if (!show) return const SizedBox.shrink();
    final month = weekEnd.day <= 7 && weekEnd.month != weekStart.month
        ? weekEnd.month
        : weekStart.month;
    return Text(
      formatMonthShort(month),
      style: text.labelSmall?.copyWith(color: AppColors.inkSoft, fontSize: 10),
      overflow: TextOverflow.visible,
      softWrap: false,
    );
  }

  Widget _cellFor(LocalDate date, int maxChapters) {
    final status = calendar.statusOn(date);
    final day = calendar.dayOn(date);
    Color color;
    switch (status) {
      case DayStatus.completed:
        final level = maxChapters == 0
            ? 1.0
            : (day!.chapterCount / maxChapters).clamp(0.25, 1.0);
        color = AppColors.success.withValues(alpha: 0.3 + 0.7 * level);
      case DayStatus.missed:
        color = AppColors.missed.withValues(alpha: 0.35);
      case DayStatus.todayPending:
        color = AppColors.parchmentDeep;
      case DayStatus.future:
        color = AppColors.parchmentDeep;
      case DayStatus.outsidePlan:
        color = Colors.transparent;
    }
    final isToday = date == calendar.today;
    return GestureDetector(
      onTap: status == DayStatus.outsidePlan ? null : () => onTap(date),
      child: Container(
        width: _cell,
        height: _cell,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          border: isToday
              ? Border.all(color: AppColors.teal, width: 1.5)
              : null,
        ),
      ),
    );
  }

  Widget _legend(Color c, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
      ),
    ],
  );
}
