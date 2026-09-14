import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/calendar/plan_calendar.dart';

/// One month, Monday first. ✓ completed · ○ missed · — future · today ringed.
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.year,
    required this.month,
    required this.calendar,
    required this.onTap,
  });

  final int year;
  final int month;
  final PlanCalendar calendar;
  final ValueChanged<LocalDate> onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final first = LocalDate(year, month, 1);
    final daysInMonth = LocalDate(year, month + 1, 1).plusDays(-1).day;
    final leading = first.weekday - 1; // Monday = 0
    final cells = <Widget>[
      for (var i = 0; i < leading; i++) const SizedBox.shrink(),
      for (var d = 1; d <= daysInMonth; d++)
        _DayCell(
          date: LocalDate(year, month, d),
          status: calendar.statusOn(LocalDate(year, month, d)),
          isToday: LocalDate(year, month, d) == calendar.today,
          onTap: onTap,
        ),
    ];
    return Column(
      children: [
        Row(
          children: [
            for (final w in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
              Expanded(
                child: Center(
                  child: Text(
                    w,
                    style: text.labelSmall?.copyWith(color: AppColors.inkSoft),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          children: cells,
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.status,
    required this.isToday,
    required this.onTap,
  });

  final LocalDate date;
  final DayStatus status;
  final bool isToday;
  final ValueChanged<LocalDate> onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final (Color bg, Color fg, String? mark) = switch (status) {
      DayStatus.completed => (AppColors.success, Colors.white, '✓'),
      DayStatus.missed => (
        AppColors.missed.withValues(alpha: 0.18),
        AppColors.missed,
        '○',
      ),
      DayStatus.todayPending => (AppColors.parchmentDeep, AppColors.ink, null),
      DayStatus.future => (Colors.white, AppColors.inkSoft, '—'),
      DayStatus.outsidePlan => (
        Colors.transparent,
        AppColors.inkSoft.withValues(alpha: 0.45),
        null,
      ),
    };
    return InkWell(
      onTap: status == DayStatus.outsidePlan ? null : () => onTap(date),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: isToday ? Border.all(color: AppColors.teal, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: text.bodyMedium?.copyWith(
                color: fg,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (mark != null)
              Text(
                mark,
                style: text.labelSmall?.copyWith(color: fg, height: 1),
              ),
          ],
        ),
      ),
    );
  }
}
