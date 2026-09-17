import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../domain/achievements/badges.dart';

class CompletionArgs {
  const CompletionArgs({
    required this.label,
    required this.streak,
    required this.badgeIds,
    this.isPassage = false,
  });
  final String label;
  final int streak;
  final List<String> badgeIds;

  /// A one-time reading: no streak line, different headline.
  final bool isPassage;
}

class CompletionScreen extends StatelessWidget {
  const CompletionScreen({super.key, required this.args});

  final CompletionArgs args;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final badges = [for (final id in args.badgeIds) badgeById(id)];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text('🎉', textAlign: TextAlign.center, style: text.displayLarge),
              const SizedBox(height: 16),
              Text(
                args.isPassage
                    ? 'Reading complete!'
                    : "Today's reading is complete!",
                textAlign: TextAlign.center,
                style: text.headlineMedium,
              ),
              const SizedBox(height: 24),
              if (!args.isPassage)
                Text(
                  '🔥 ${args.streak} day streak',
                  textAlign: TextAlign.center,
                  style: text.titleLarge,
                ),
              const SizedBox(height: 12),
              Text(
                '${args.label} ✓',
                textAlign: TextAlign.center,
                style: text.titleMedium?.copyWith(color: AppColors.success),
              ),
              if (badges.isNotEmpty) ...[
                const SizedBox(height: 32),
                Text(
                  badges.length == 1 ? 'New badge' : 'New badges',
                  textAlign: TextAlign.center,
                  style: text.labelLarge?.copyWith(color: AppColors.inkSoft),
                ),
                const SizedBox(height: 12),
                for (final b in badges)
                  Card(
                    child: ListTile(
                      leading: Text(b.emoji, style: text.headlineSmall),
                      title: Text(b.title),
                      subtitle: Text(b.description),
                    ),
                  ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
