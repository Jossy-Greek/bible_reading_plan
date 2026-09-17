import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/sanctuary.dart';
import '../../../core/bible/books.dart';
import '../../../domain/passages/passage.dart';
import '../../onboarding/widgets/book_picker.dart';
import '../../reading/providers/reading_providers.dart';

/// Read something outside the plan, once, timed like any other reading.
/// Curated passages first; any book and chapter range below.
class PassagesScreen extends ConsumerWidget {
  const PassagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final pace = ref.watch(settingsProvider).pace;
    final time = ref.watch(readingTimeServiceProvider);
    final done = ref.watch(completedPassagesProvider).value ?? const [];
    final open = ref.watch(openSessionProvider).value;

    bool isDone(Passage p) => done.any((d) => d.covers(p));

    return Scaffold(
      appBar: SanctuaryAppBar(
        title: 'One-time reading',
        overline: 'Outside your plan',
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(
            backgroundColor: context.colors.parchmentDeep,
            foregroundColor: context.colors.ink,
          ),
        ),
        showStreak: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            'Read a passage on its own. It is timed like a plan day, its '
            'chapters count toward your Bible progress, and some passages '
            'carry a badge. It does not change your streak.',
            style: text.bodyMedium?.copyWith(color: context.colors.inkSoft),
          ),
          if (open != null) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.hourglass_top_rounded,
                  color: context.colors.teal,
                ),
                title: const Text('A reading is already open'),
                subtitle: const Text('Finish it before starting another.'),
                trailing: Icon(Icons.chevron_right),
                onTap: () => context.push('/reading'),
              ),
            ),
          ],
          SizedBox(height: 20),
          const Overline('Well-known passages'),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                for (final (i, p) in kPassages.indexed) ...[
                  if (i > 0) const Divider(height: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDone(p)
                            ? context.colors.success
                            : context.colors.parchmentDeep,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDone(p)
                            ? Icons.check_rounded
                            : Icons.menu_book_outlined,
                        size: 18,
                        color: isDone(p)
                            ? context.colors.onSuccess
                            : context.colors.teal,
                      ),
                    ),
                    title: Text(p.title, style: text.titleSmall),
                    subtitle: Text(
                      '${p.reference} · ${p.verses} verses · '
                      '~${(time.estimate(p.assignment.chapters, pace).inSeconds / 60).round()} min',
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: open != null ? null : () => _start(context, ref, p),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 20),
          const Overline('Any passage'),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 6,
              ),
              leading: const IconWell(Icons.tune_rounded, size: 36),
              title: Text('Choose a book and chapters', style: text.titleSmall),
              subtitle: const Text('e.g. Matthew 5–7, Psalm 23, Romans 8'),
              trailing: const Icon(Icons.chevron_right),
              onTap: open != null ? null : () => _custom(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _custom(BuildContext context, WidgetRef ref) async {
    final book = await showBookPicker(context);
    if (book == null || !context.mounted) return;
    final range = await showDialog<(int, int)>(
      context: context,
      builder: (ctx) => _RangeDialog(book: book),
    );
    if (range == null || !context.mounted) return;
    await _start(context, ref, Passage.custom(book.id, range.$1, range.$2));
  }

  Future<void> _start(BuildContext context, WidgetRef ref, Passage p) async {
    final pace = ref.read(settingsProvider).pace;
    final required = ref
        .read(readingTimeServiceProvider)
        .estimate(p.assignment.chapters, pace);
    await ref
        .read(progressRepositoryProvider)
        .startPassageSession(
          passage: p,
          planId: ref.read(activePlanProvider).value?.id,
          required: required,
          nowUtc: ref.read(clockProvider).nowUtc(),
        );
    if (context.mounted) context.go('/reading');
  }
}

/// From / to chapter, bounded by the book. "To" follows "from" upward.
class _RangeDialog extends StatefulWidget {
  const _RangeDialog({required this.book});
  final BibleBook book;

  @override
  State<_RangeDialog> createState() => _RangeDialogState();
}

class _RangeDialogState extends State<_RangeDialog> {
  int _from = 1;
  int _to = 1;

  @override
  Widget build(BuildContext context) {
    final n = widget.book.chapters;
    return AlertDialog(
      title: Text(widget.book.name),
      content: Row(
        children: [
          Expanded(
            child: _picker(
              'From',
              _from,
              n,
              (v) => setState(() {
                _from = v;
                if (_to < v) _to = v;
              }),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _picker(
              'To',
              _to,
              n,
              (v) => setState(() {
                _to = v;
                if (_from > v) _from = v;
              }),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop((_from, _to)),
          child: Text(
            _from == _to ? 'Read chapter $_from' : 'Read $_from–$_to',
          ),
        ),
      ],
    );
  }

  Widget _picker(
    String label,
    int value,
    int max,
    ValueChanged<int> onChanged,
  ) => DropdownButtonFormField<int>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items: [
      for (var i = 1; i <= max; i++)
        DropdownMenuItem(value: i, child: Text('$i')),
    ],
    onChanged: (v) => v == null ? null : onChanged(v),
  );
}
