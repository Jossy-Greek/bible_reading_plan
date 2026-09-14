/// Reminder preferences. Minutes of day, local wall clock.
class ReminderSettings {
  const ReminderSettings({
    required this.enabled,
    required this.reminderMinutes,
    required this.nudgeEnabled,
    required this.nudgeMinutes,
  });

  final bool enabled;
  final int reminderMinutes;
  final bool nudgeEnabled;
  final int nudgeMinutes;

  ReminderSettings copyWith({
    bool? enabled,
    int? reminderMinutes,
    bool? nudgeEnabled,
    int? nudgeMinutes,
  }) => ReminderSettings(
    enabled: enabled ?? this.enabled,
    reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    nudgeEnabled: nudgeEnabled ?? this.nudgeEnabled,
    nudgeMinutes: nudgeMinutes ?? this.nudgeMinutes,
  );
}

/// One notification the OS should hold for us.
class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.firstFireLocal,
    required this.title,
    required this.body,
  });

  static const dailyId = 1;
  static const nudgeId = 2;

  final int id;

  /// Local wall-clock time of the first delivery. Every reminder repeats
  /// daily at the same wall time after that.
  final DateTime firstFireLocal;
  final String title;
  final String body;
}

/// Decides what should be scheduled. Pure, so "the nudge must not fire on a
/// day already completed" is a unit test, not a field report.
///
/// At most two notifications exist at any time: the daily reminder and the
/// evening nudge. Both repeat daily at a wall-clock time. The nudge's first
/// delivery is pushed to tomorrow when today's reading is already done, and
/// every completion re-runs this planner, so it never fires after a finished
/// day while the app was there to know about it.
class ReminderPlanner {
  const ReminderPlanner();

  List<ScheduledReminder> plan({
    required ReminderSettings settings,
    required String name,
    required bool todayCompleted,
    required DateTime nowLocal,
  }) {
    if (!settings.enabled) return const [];
    final who = name.trim().isEmpty ? '' : ', ${name.trim()}';
    final out = <ScheduledReminder>[
      ScheduledReminder(
        id: ScheduledReminder.dailyId,
        firstFireLocal: _next(
          nowLocal,
          settings.reminderMinutes,
          skipToday: false,
        ),
        title: 'Bible Reading Plan',
        body: '📖 Time for today\'s Bible reading$who.',
      ),
    ];
    if (settings.nudgeEnabled) {
      out.add(
        ScheduledReminder(
          id: ScheduledReminder.nudgeId,
          firstFireLocal: _next(
            nowLocal,
            settings.nudgeMinutes,
            skipToday: todayCompleted,
          ),
          title: 'Still time today',
          body:
              'Today\'s reading is still waiting$who. A few minutes is enough.',
        ),
      );
    }
    return out;
  }

  /// The next wall-clock occurrence of [minutesOfDay] strictly after now,
  /// or tomorrow's when [skipToday].
  static DateTime _next(
    DateTime now,
    int minutesOfDay, {
    required bool skipToday,
  }) {
    var t = DateTime(
      now.year,
      now.month,
      now.day,
      minutesOfDay ~/ 60,
      minutesOfDay % 60,
    );
    if (skipToday || !t.isAfter(now)) t = t.add(const Duration(days: 1));
    return t;
  }
}

String formatMinutesOfDay(int minutes, {bool use24h = false}) {
  final h = minutes ~/ 60;
  final m = (minutes % 60).toString().padLeft(2, '0');
  if (use24h) return '${h.toString().padLeft(2, '0')}:$m';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:$m ${h < 12 ? 'AM' : 'PM'}';
}
