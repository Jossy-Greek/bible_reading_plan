import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../providers/onboarding_controller.dart';

class NameScreen extends ConsumerStatefulWidget {
  const NameScreen({super.key});

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final canContinue = _controller.text.trim().isNotEmpty;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📖', style: text.displayMedium),
              const SizedBox(height: 24),
              Text('What should we call you?', style: text.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Your name stays on this device.',
                style: text.bodyLarge?.copyWith(color: context.colors.inkSoft),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(hintText: 'Your name'),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _next(),
              ),
              const Spacer(),
              FilledButton(
                onPressed: canContinue ? _next : null,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _next() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    ref.read(onboardingControllerProvider.notifier).setName(name);
    context.go('/onboarding/plan');
  }
}
