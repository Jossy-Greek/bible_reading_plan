import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../notifications/reminder_plan.dart';
import '../providers/onboarding_controller.dart';

/// Last onboarding step. Skippable: a reminder is an offer, not a toll.
class ReminderScreen extends ConsumerStatefulWidget {
  const ReminderScreen({super.key});

  @override
  ConsumerState<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends ConsumerState<ReminderScreen> {
  int _minutes = 7 * 60;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('A daily reminder')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('When should we remind you?', style: text.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'One gentle notification a day. You can change or turn it '
                'off any time in Settings.',
                style: text.bodyLarge?.copyWith(color: AppColors.inkSoft),
              ),
              const SizedBox(height: 32),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.alarm),
                  title: const Text('Reminder time'),
                  trailing: Text(
                    formatMinutesOfDay(_minutes),
                    style: text.titleMedium,
                  ),
                  onTap: _pickTime,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _saving ? null : () => _finish(enabled: true),
                child: Text(_saving ? 'Setting up…' : 'Remind me'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _saving ? null : () => _finish(enabled: false),
                child: const Text('Not now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _minutes ~/ 60, minute: _minutes % 60),
    );
    if (t != null) setState(() => _minutes = t.hour * 60 + t.minute);
  }

  Future<void> _finish({required bool enabled}) async {
    setState(() => _saving = true);
    try {
      await ref
          .read(onboardingControllerProvider.notifier)
          .finish(
            reminders: ReminderSettings(
              enabled: enabled,
              reminderMinutes: _minutes,
              nudgeEnabled: false,
              nudgeMinutes: 20 * 60,
            ),
          );
      if (mounted) context.go('/');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
