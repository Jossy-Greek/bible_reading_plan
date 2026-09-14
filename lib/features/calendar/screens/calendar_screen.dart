import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/time/format.dart';
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
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: false, label: Text('Month')),
                ButtonSegment(value: true, label: Text('Year')),
              ],
              selected: {_yearly},
              onSelectionChanged: (s) => setState(() => _yearly = s.first),
            ),
          ),
        ],
      ),
      body: cal == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                // Today, at a glance.
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Today', style: text.labelLarge),
                              const SizedBox(height: 4),
                              Text(
                                cal.dayOn(today)?.label ?? 'No reading today',
                                style: text.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                cal.isCompleted(cal.dayOn(today)!) == true
                                    ? 'Completed ✓'
                                    : 'Not completed',
                                style: text.bodySmall?.copyWith(
                                  color: AppColors.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text('🔥 $shownStreak', style: text.titleLarge),
                            Text(
                              'streak',
                              style: text.labelSmall?.copyWith(
                                color: AppColors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_yearly) ...[
                  Text(
                    '${formatMediumDate(cal.start)} → ${formatMediumDate(cal.end)}',
                    style: text.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cal.completedCount} of ${cal.days.length} days completed'
                    '${cal.missedCount > 0 ? '  ·  ${cal.missedCount} missed' : ''}',
                    style: text.bodyMedium?.copyWith(color: AppColors.inkSoft),
                  ),
                  const SizedBox(height: 16),
                  YearHeatmap(
                    calendar: cal,
                    onTap: (d) => showDayDetail(context, d),
                  ),
                ] else ...[
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => _shiftMonth(year, month, -1),
                      ),
                      Expanded(
                        child: Text(
                          formatMonthYear(year, month),
                          textAlign: TextAlign.center,
                          style: text.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => _shiftMonth(year, month, 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  MonthGrid(
                    year: year,
                    month: month,
                    calendar: cal,
                    onTap: (d) => showDayDetail(context, d),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '✓ completed   ○ missed   — ahead',
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(color: AppColors.inkSoft),
                  ),
                ],
              ],
            ),
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
