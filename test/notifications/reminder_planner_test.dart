import 'package:bible_reading_plan/notifications/reminder_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const planner = ReminderPlanner();
  const on = ReminderSettings(
    enabled: true,
    reminderMinutes: 7 * 60,
    nudgeEnabled: true,
    nudgeMinutes: 20 * 60,
  );
  final morning = DateTime(2026, 9, 14, 6, 30);
  final afternoon = DateTime(2026, 9, 14, 15, 0);

  test('disabled schedules nothing', () {
    expect(
      planner.plan(
        settings: on.copyWith(enabled: false),
        name: 'Yoseph',
        todayCompleted: false,
        nowLocal: morning,
      ),
      isEmpty,
    );
  });

  test(
    'a reminder time still ahead fires today; one already past, tomorrow',
    () {
      final early = planner.plan(
        settings: on,
        name: 'Y',
        todayCompleted: false,
        nowLocal: morning,
      );
      expect(early.first.firstFireLocal, DateTime(2026, 9, 14, 7, 0));
      final late = planner.plan(
        settings: on,
        name: 'Y',
        todayCompleted: false,
        nowLocal: afternoon,
      );
      expect(late.first.firstFireLocal, DateTime(2026, 9, 15, 7, 0));
    },
  );

  test('the nudge skips today once today is completed', () {
    final notDone = planner.plan(
      settings: on,
      name: 'Y',
      todayCompleted: false,
      nowLocal: afternoon,
    );
    expect(notDone[1].id, ScheduledReminder.nudgeId);
    expect(notDone[1].firstFireLocal, DateTime(2026, 9, 14, 20, 0));
    final done = planner.plan(
      settings: on,
      name: 'Y',
      todayCompleted: true,
      nowLocal: afternoon,
    );
    expect(done[1].firstFireLocal, DateTime(2026, 9, 15, 20, 0));
  });

  test('never more than two, and the name is in the copy', () {
    final r = planner.plan(
      settings: on,
      name: 'Yoseph',
      todayCompleted: false,
      nowLocal: morning,
    );
    expect(r.length, 2);
    expect(r.first.body, '📖 Time for today\'s Bible reading, Yoseph.');
    final noNudge = planner.plan(
      settings: on.copyWith(nudgeEnabled: false),
      name: '',
      todayCompleted: false,
      nowLocal: morning,
    );
    expect(noNudge.length, 1);
    expect(noNudge.first.body, '📖 Time for today\'s Bible reading.');
  });

  test('minutes of day formatting', () {
    expect(formatMinutesOfDay(7 * 60), '7:00 AM');
    expect(formatMinutesOfDay(20 * 60 + 5), '8:05 PM');
    expect(formatMinutesOfDay(0), '12:00 AM');
    expect(formatMinutesOfDay(12 * 60), '12:00 PM');
    expect(formatMinutesOfDay(20 * 60 + 5, use24h: true), '20:05');
  });
}
