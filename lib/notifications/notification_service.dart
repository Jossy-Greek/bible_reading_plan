import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'reminder_plan.dart';

/// Thin wrapper over the plugin. Knows nothing about reading plans; it
/// schedules what [ReminderPlanner] decided.
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  String? _timezone;

  String? get timezone => _timezone;

  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await refreshTimezone();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permission is asked for explicitly at the onboarding reminder
        // step, never as a surprise on first launch.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  /// Re-reads the device zone. Returns true when it changed since last time,
  /// which is the caller's cue to reschedule so 7:00 stays 7:00.
  Future<bool> refreshTimezone() async {
    String id;
    try {
      id = (await FlutterTimezone.getLocalTimezone()).identifier;
    } catch (_) {
      id = 'UTC';
    }
    final changed = id != _timezone;
    _timezone = id;
    try {
      tz.setLocalLocation(tz.getLocation(id));
    } catch (_) {
      // Unknown identifier: instants still schedule correctly through
      // TZDateTime.from; only DST-aware repetition is approximate.
      tz.setLocalLocation(tz.UTC);
    }
    return changed;
  }

  Future<bool> requestPermission() async {
    await init();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(alert: true, sound: true) ?? false;
    }
    return false;
  }

  /// Whether the OS will show anything at all. Null when it cannot tell.
  Future<bool?> areEnabled() async {
    await init();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.areNotificationsEnabled();
    }
    return null;
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders',
      'Reading reminders',
      channelDescription: 'Daily reminder to read today\'s chapters',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
  );

  /// Replace whatever is pending with exactly [reminders].
  Future<void> apply(List<ScheduledReminder> reminders) async {
    await init();
    await _plugin.cancel(id: ScheduledReminder.dailyId);
    await _plugin.cancel(id: ScheduledReminder.nudgeId);
    for (final r in reminders) {
      try {
        await _plugin.zonedSchedule(
          id: r.id,
          title: r.title,
          body: r.body,
          scheduledDate: tz.TZDateTime.from(r.firstFireLocal, tz.local),
          notificationDetails: _details,
          // Inexact: a reminder a few minutes late is fine, and it spares
          // the user Android's separate exact-alarm permission prompt.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (e) {
        // Never block the app on a scheduling failure; the next refresh
        // (launch, resume, completion) tries again.
        debugPrint('reminder $r.id failed to schedule: $e');
      }
    }
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }
}
