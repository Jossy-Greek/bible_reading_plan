import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/sanctuary.dart';
import '../../../core/time/format.dart';
import '../../../domain/reading_time/reading_time_service.dart';
import '../../../notifications/reminder_coordinator.dart';
import '../../../notifications/reminder_plan.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsRevisionProvider);
    final text = Theme.of(context).textTheme;
    final settings = ref.watch(settingsProvider);
    final actions = ref.read(settingsActionsProvider);
    final plan = ref.watch(activePlanProvider).value;
    final reminders = settings.reminders;

    Widget header(String t) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        t.toUpperCase(),
        style: text.labelSmall?.copyWith(
          color: AppColors.inkSoft,
          letterSpacing: 1.1,
        ),
      ),
    );

    return Scaffold(
      appBar: const SanctuaryAppBar(title: 'Settings', showProfile: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
        children: [
          header('Profile'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Name'),
                  subtitle: Text(settings.name ?? '—'),
                  onTap: () => _editName(context, actions, settings.name ?? ''),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('Reading plan'),
                  subtitle: Text(plan?.title ?? '—'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/plan'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Start date'),
                  subtitle: Text(
                    plan == null ? '—' : formatMediumDate(plan.startDate),
                  ),
                  onTap: plan == null
                      ? null
                      : () => _changeStartDate(context, ref, actions, plan.id),
                ),
              ],
            ),
          ),
          header('Reminders'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Daily reminder'),
                  value: reminders.enabled,
                  onChanged: (v) =>
                      _toggleReminders(ref, actions, reminders, v),
                ),
                if (reminders.enabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const SizedBox(width: 24),
                    title: const Text('Reminder time'),
                    trailing: Text(
                      formatMinutesOfDay(reminders.reminderMinutes),
                      style: text.titleMedium,
                    ),
                    onTap: () async {
                      final m = await _pickMinutes(
                        context,
                        reminders.reminderMinutes,
                      );
                      if (m != null) {
                        await actions.setReminders(
                          reminders.copyWith(reminderMinutes: m),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const SizedBox(width: 24),
                    title: const Text('Evening nudge'),
                    subtitle: const Text('Only if today is not done yet'),
                    value: reminders.nudgeEnabled,
                    onChanged: (v) => actions.setReminders(
                      reminders.copyWith(nudgeEnabled: v),
                    ),
                  ),
                  if (reminders.nudgeEnabled) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const SizedBox(width: 24),
                      title: const Text('Nudge time'),
                      trailing: Text(
                        formatMinutesOfDay(reminders.nudgeMinutes),
                        style: text.titleMedium,
                      ),
                      onTap: () async {
                        final m = await _pickMinutes(
                          context,
                          reminders.nudgeMinutes,
                        );
                        if (m != null) {
                          await actions.setReminders(
                            reminders.copyWith(nudgeMinutes: m),
                          );
                        }
                      },
                    ),
                  ],
                ],
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Send a test notification'),
                  subtitle: const Text(
                    'Appears right away if notifications can reach you',
                  ),
                  onTap: () async {
                    await ref.read(notificationServiceProvider).showTestNow();
                    ref.read(settingsRevisionProvider.notifier).bump();
                  },
                ),
                const Divider(height: 1),
                _ScheduledReadout(),
                _PermissionNote(),
              ],
            ),
          ),
          header('Reading'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reading pace'),
                  const SizedBox(height: 4),
                  Text(
                    'Sets how long each reading must take. Verse counts are '
                    'fixed; this is how fast you read them.',
                    style: text.bodySmall?.copyWith(color: AppColors.inkSoft),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ReadingPace>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: ReadingPace.relaxed,
                        label: Text('Relaxed'),
                      ),
                      ButtonSegment(
                        value: ReadingPace.normal,
                        label: Text('Normal'),
                      ),
                      ButtonSegment(
                        value: ReadingPace.quick,
                        label: Text('Quick'),
                      ),
                    ],
                    selected: {settings.pace},
                    onSelectionChanged: (s) => actions.setPace(s.first),
                  ),
                ],
              ),
            ),
          ),
          header('Data'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.replay_outlined),
                  title: const Text('Restart plan'),
                  subtitle: const Text(
                    'Same plan, from today. Chapters read are kept.',
                  ),
                  onTap: plan == null
                      ? null
                      : () => _confirm(
                          context,
                          title: 'Restart plan?',
                          body:
                              'Your schedule starts again from today. Chapters '
                              'you have read, your streak and badges are kept.',
                          action: 'Restart',
                          onConfirm: () => actions.restartPlan(plan),
                        ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.restart_alt,
                    color: AppColors.missed,
                  ),
                  title: const Text('Reset progress'),
                  subtitle: const Text(
                    'Erase every chapter, day, streak and badge.',
                  ),
                  onTap: () => _confirm(
                    context,
                    title: 'Reset all progress?',
                    body:
                        'Every completed chapter and day, your streak and '
                        'every badge will be erased. Your name and plan stay. '
                        'This cannot be undone.',
                    action: 'Reset',
                    destructive: true,
                    onConfirm: actions.resetProgress,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.delete_forever_outlined,
                    color: AppColors.missed,
                  ),
                  title: const Text('Clear all local data'),
                  subtitle: const Text('Back to the first launch.'),
                  onTap: () => _clearAll(context, actions),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Everything stays on this device.',
              style: text.bodySmall?.copyWith(color: AppColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(
    BuildContext context,
    SettingsActions actions,
    String current,
  ) async {
    final controller = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) await actions.setName(name);
    // Disposed after the route has fully gone, not while its field is
    // animating out.
    Future.delayed(const Duration(seconds: 1), controller.dispose);
  }

  Future<void> _toggleReminders(
    WidgetRef ref,
    SettingsActions actions,
    ReminderSettings r,
    bool on,
  ) async {
    if (on) {
      final granted = await ref
          .read(notificationServiceProvider)
          .requestPermission();
      if (!granted) {
        // Leave it off and let the note below explain.
        ref.read(settingsRevisionProvider.notifier).bump();
        return;
      }
    }
    await actions.setReminders(r.copyWith(enabled: on));
  }

  Future<int?> _pickMinutes(BuildContext context, int current) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    return t == null ? null : t.hour * 60 + t.minute;
  }

  Future<void> _changeStartDate(
    BuildContext context,
    WidgetRef ref,
    SettingsActions actions,
    int planId,
  ) async {
    final today = ref.read(clockProvider).nowLocal();
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today.subtract(const Duration(days: 365 * 3)),
      lastDate: today,
      helpText: 'Plan start date',
    );
    if (picked == null || !context.mounted) return;
    await _confirm(
      context,
      title: 'Move the start date?',
      body:
          'Every day of the plan shifts to a new date. Days you have '
          'completed keep their chapters.',
      action: 'Move',
      onConfirm: () => actions.changeStartDate(planId, picked),
    );
  }

  Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
    required Future<void> Function() onConfirm,
    bool destructive = false,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(backgroundColor: AppColors.missed)
                : null,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );
    if (ok == true) await onConfirm();
  }

  /// The one action that needs a typed word: it ends everything.
  Future<void> _clearAll(BuildContext context, SettingsActions actions) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Clear all local data?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your name, plan, every chapter and day, streak, badges and '
                'reminders will be deleted from this device. Type DELETE to '
                'confirm.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'DELETE'),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.missed),
              onPressed: controller.text.trim() == 'DELETE'
                  ? () => Navigator.of(ctx).pop(true)
                  : null,
              child: const Text('Delete everything'),
            ),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 1), controller.dispose);
    if (ok == true) {
      await actions.clearAllData();
      if (context.mounted) context.go('/onboarding');
    }
  }
}

class _PermissionNote extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsRevisionProvider);
    return FutureBuilder<bool?>(
      future: ref.read(notificationServiceProvider).areEnabled(),
      builder: (context, snap) {
        if (snap.data != false) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Text(
            'Notifications are turned off for this app in your system '
            'settings. Turn them on there to receive reminders.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.missed),
          ),
        );
      },
    );
  }
}

/// What is actually pending on the device, so "nothing arrived" can be told
/// apart from "nothing was ever scheduled".
class _ScheduledReadout extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsRevisionProvider);
    final text = Theme.of(context).textTheme;
    return FutureBuilder(
      future: ref.read(notificationServiceProvider).pending(),
      builder: (context, snap) {
        final pending = snap.data;
        final String line;
        if (pending == null) {
          line = 'Checking scheduled reminders…';
        } else if (pending.isEmpty) {
          line = 'Nothing is scheduled on this device.';
        } else {
          line =
              'Scheduled on this device: ${pending.map((p) => p.title ?? '#${p.id}').join(' · ')}';
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Text(
            line,
            style: text.bodySmall?.copyWith(color: AppColors.inkSoft),
          ),
        );
      },
    );
  }
}
