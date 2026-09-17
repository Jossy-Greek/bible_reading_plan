import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/reading_time/reading_time_service.dart';
import '../../notifications/reminder_plan.dart';

/// The handful of scalars that do not belong in a table.
class SettingsStore {
  SettingsStore(this._prefs);

  final SharedPreferences _prefs;

  static const _kName = 'user_name';
  static const _kOnboardingDone = 'onboarding_done';
  static const _kPace = 'reading_pace';
  static const _kReminderEnabled = 'reminder_enabled';
  static const _kReminderMinutes = 'reminder_minutes_of_day';
  static const _kNudgeEnabled = 'nudge_enabled';
  static const _kNudgeMinutes = 'nudge_minutes_of_day';
  static const _kTimezone = 'last_timezone';
  static const _kThemeMode = 'theme_mode';

  String? get name => _prefs.getString(_kName);
  Future<void> setName(String v) => _prefs.setString(_kName, v.trim());

  bool get onboardingDone => _prefs.getBool(_kOnboardingDone) ?? false;
  Future<void> setOnboardingDone(bool v) => _prefs.setBool(_kOnboardingDone, v);

  ReadingPace get pace => ReadingPace.values.firstWhere(
    (p) => p.name == _prefs.getString(_kPace),
    orElse: () => ReadingPace.normal,
  );
  Future<void> setPace(ReadingPace p) => _prefs.setString(_kPace, p.name);

  ReminderSettings get reminders => ReminderSettings(
    enabled: _prefs.getBool(_kReminderEnabled) ?? false,
    reminderMinutes: _prefs.getInt(_kReminderMinutes) ?? 7 * 60,
    nudgeEnabled: _prefs.getBool(_kNudgeEnabled) ?? false,
    nudgeMinutes: _prefs.getInt(_kNudgeMinutes) ?? 20 * 60,
  );

  Future<void> setReminders(ReminderSettings r) async {
    await _prefs.setBool(_kReminderEnabled, r.enabled);
    await _prefs.setInt(_kReminderMinutes, r.reminderMinutes);
    await _prefs.setBool(_kNudgeEnabled, r.nudgeEnabled);
    await _prefs.setInt(_kNudgeMinutes, r.nudgeMinutes);
  }

  /// Follows the device by default — an app for 5 a.m. and 11 p.m. should
  /// not be the one window that stays bright.
  ThemeMode get themeMode => ThemeMode.values.firstWhere(
    (m) => m.name == _prefs.getString(_kThemeMode),
    orElse: () => ThemeMode.system,
  );
  Future<void> setThemeMode(ThemeMode m) =>
      _prefs.setString(_kThemeMode, m.name);

  String? get lastTimezone => _prefs.getString(_kTimezone);
  Future<void> setLastTimezone(String v) => _prefs.setString(_kTimezone, v);

  Future<void> clearAll() => _prefs.clear();
}
