import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/sanctuary.dart';
import '../../../core/time/format.dart';
import '../../../core/verses.dart';
import '../../../domain/calendar/plan_calendar.dart';
import '../../reading/providers/reading_providers.dart';
import '../providers/calendar_providers.dart';
import '../widgets/day_detail_sheet.dart';
import '../widgets/month_grid.dart';
import '../widgets/year_heatmap.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  bool _yearly = false;
  int? _year;
  int? _month;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cal = ref.watch(planCalendarProvider);
    final today = ref.watch(clockProvider).today();
    final year = _year ?? today.year;
    final month = _month ?? today.month;
    final streak = ref.watch(streakProvider).value;
    final shownStreak = streak == null
        ? 0
        : ref.watch(streakServiceProvider).displayed(streak, today);

    return Scaffold(
      appBar: const SanctuaryAppBar(title: 'Calendar'),
      body: cal == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Row(
                  children: [
                    const Spacer(),
                    SegmentedButton<bool>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: false, label: Text('Month')),
                        ButtonSegment(value: true, label: Text('Year')),
                      ],
                      selected: {_yearly},
                      onSelectionChanged: (s) =>
                          setState(() => _yearly = s.first),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _TodayCard(cal: cal, streak: shownStreak),
                const SizedBox(height: 20),
                if (_yearly) ...[
                  const Overline('Your reading journey'),
                  const SizedBox(height: 4),
                  Text(
                    '${formatMediumDate(cal.start)} → ${formatMediumDate(cal.end)}',
                    style: text.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cal.completedCount} of ${cal.days.length} days completed'
                    '${cal.missedCount > 0 ? ' · ${cal.missedCount} missed' : ''}',
                    style: text.bodyMedium?.copyWith(color: AppColors.inkSoft),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: YearHeatmap(
                        calendar: cal,
                        onTap: (d) => showDayDetail(context, d),
                      ),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Overline('$year reading journey'),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat.MMMM().format(DateTime(year, month)),
                              style: text.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () => _shiftMonth(year, month, -1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () => _shiftMonth(year, month, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  MonthGrid(
                    year: year,
                    month: month,
                    calendar: cal,
                    onTap: (d) => showDayDetail(context, d),
                  ),
                  const SizedBox(height: 20),
                  _PaceCard(cal: cal, year: year, month: month),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legend('✓', 'completed', AppColors.success),
                      const SizedBox(width: 20),
                      _legend('○', 'missed', AppColors.missed),
                      const SizedBox(width: 20),
                      _legend('–', 'ahead', AppColors.inkSoft),
                    ],
                  ),
                ],
                const SizedBox(height: 28),
                Text(
                  '"${verseFor(month).text}"',
                  textAlign: TextAlign.center,
                  style: text.titleMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    color: AppColors.inkSoft,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Center(child: Overline(verseFor(month).ref)),
              ],
            ),
    );
  }

  Widget _legend(String mark, String label, Color color) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(mark, style: text.titleMedium?.copyWith(color: color, height: 1)),
        const SizedBox(width: 6),
        Text(label, style: text.bodyMedium),
      ],
    );
  }

  void _shiftMonth(int year, int month, int delta) {
    final m = month + delta;
    setState(() {
      _year = year + (m - 1) ~/ 12 - (m <= 0 ? 1 : 0);
      _month = ((m - 1) % 12) + 1;
    });
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.cal, required this.streak});
  final PlanCalendar cal;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final day = cal.dayOn(cal.today);
    final done = day != null && cal.isCompleted(day);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Overline(
                        day == null
                            ? 'Today'
                            : 'Today • Day ${day.dayIndex + 1}',
                      ),
                      const SizedBox(width: 8),
                      if (day != null)
                        SoftChip(
                          done ? 'Done' : 'Pending',
                          color: done
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.parchmentDeep,
                          textColor: done ? AppColors.success : AppColors.ink,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    day?.label ?? 'No reading today',
                    style: text.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: done ? AppColors.success : AppColors.missed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        day == null
                            ? 'Outside your plan'
                            : done
                            ? 'Completed'
                            : 'Not completed yet',
                        style: text.bodyLarge?.copyWith(
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.parchmentDeep,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('🔥 $streak', style: text.titleLarge),
                  const Overline('streak'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaceCard extends StatelessWidget {
  const _PaceCard({required this.cal, required this.year, required this.month});
  final PlanCalendar cal;
  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final m = cal.monthStats(year, month);
    if (m.completed + m.missed + m.remaining == 0) {
      return const SizedBox.shrink();
    }
    final name = DateFormat.MMMM().format(DateTime(year, month));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const IconWell(Icons.done_all_rounded),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$name Pace', style: text.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${m.completed} completed • ${m.missed} missed • '
                    '${m.remaining} remaining',
                    style: text.bodySmall?.copyWith(color: AppColors.inkSoft),
                  ),
                ],
              ),
            ),
            Text(
              m.pace == null ? '—' : '${(m.pace! * 100).round()}%',
              style: text.headlineSmall?.copyWith(color: AppColors.success),
            ),
          ],
        ),
      ),
    );
  }
}
