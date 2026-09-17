import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/sanctuary.dart';
import '../../../core/time/format.dart';
import '../../../core/time/local_date.dart';
import '../../../data/db/database.dart';
import '../../reading/providers/reading_providers.dart';

/// Everything the reader has written, newest first.
///
/// Deliberately not a "notes" feature with folders and tags: it is a record
/// of readings that left something behind, and the only way in is having
/// finished a reading.
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final entries = ref.watch(reflectionsProvider);

    return Scaffold(
      appBar: SanctuaryAppBar(
        title: 'Reflections',
        overline: 'What you wrote',
        showStreak: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(
            backgroundColor: c.parchmentDeep,
            foregroundColor: c.ink,
          ),
        ),
      ),
      body: entries.when(
        loading: () => Center(child: CircularProgressIndicator(color: c.teal)),
        error: (e, _) => Center(child: Text('Could not load reflections: $e')),
        data: (list) => list.isEmpty
            ? const _Empty()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _Entry(session: list[i]),
              ),
      ),
    );
  }
}

class _Entry extends ConsumerWidget {
  const _Entry({required this.session});

  final ReadingSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final c = context.colors;
    final on = LocalDate.fromDateTime(session.completedAt!.toLocal());
    return Card(
      child: InkWell(
        onTap: () => _edit(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.reference ?? 'A reading',
                      style: text.titleSmall?.copyWith(color: c.teal),
                    ),
                  ),
                  Text(
                    formatMediumDate(on),
                    style: text.bodySmall?.copyWith(color: c.inkSoft),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(session.note!, style: text.bodyLarge?.copyWith(height: 1.6)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final updated = await showReflectionEditor(
      context,
      title: session.reference ?? 'A reading',
      initial: session.note ?? '',
    );
    if (updated == null) return;
    await ref.read(progressRepositoryProvider).setNote(session.id, updated);
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_note_rounded, size: 44, color: c.inkSoft),
            const SizedBox(height: 16),
            Text(
              'Nothing written yet',
              style: text.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'After each reading you can write down what stood out. '
              'Whatever you write appears here.',
              style: text.bodyMedium?.copyWith(color: c.inkSoft),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Edit a reflection. Returns the new text, or null if cancelled — an empty
/// string is a real answer, and clears the note.
Future<String?> showReflectionEditor(
  BuildContext context, {
  required String title,
  required String initial,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _ReflectionEditor(title: title, initial: initial),
);

class _ReflectionEditor extends StatefulWidget {
  const _ReflectionEditor({required this.title, required this.initial});

  final String title;
  final String initial;

  @override
  State<_ReflectionEditor> createState() => _ReflectionEditorState();
}

class _ReflectionEditorState extends State<_ReflectionEditor> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: text.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 4,
            maxLines: 12,
            maxLength: 2000,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(counterText: ''),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_controller.text),
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
