import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/bible/bible_text.dart';
import '../../../core/bible/chapter_reference.dart';
import '../../../features/settings/providers/settings_providers.dart';
import '../providers/reading_providers.dart';

/// The text of a reading, chapter by chapter.
///
/// Verses run on as paragraphs with inline numbers — the way a printed Bible
/// sets them, and the way continuous reading actually works. One verse per
/// line turns a chapter into a list and invites skimming, which is the one
/// thing a timed reading is trying not to be.
class PassageView extends ConsumerWidget {
  const PassageView({super.key, required this.assignments});

  final List<ReadingAssignment> assignments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.watch(
      passageTextProvider(assignmentsKey(assignments)),
    );
    return chapters.when(
      loading: () => const _Loading(),
      error: (e, _) => _Unavailable(error: e),
      data: (list) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, chapter) in list.indexed) ...[
            if (i > 0) const SizedBox(height: 28),
            _Chapter(chapter: chapter, showBook: _showBook(list, i)),
          ],
        ],
      ),
    );
  }

  /// Name the book on the first chapter, and again whenever it changes —
  /// a day that crosses Genesis 50 into Exodus 1 must say so.
  static bool _showBook(List<ChapterText> list, int i) =>
      i == 0 || list[i].reference.bookId != list[i - 1].reference.bookId;
}

class _Chapter extends ConsumerWidget {
  const _Chapter({required this.chapter, required this.showBook});

  final ChapterText chapter;
  final bool showBook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final c = context.colors;
    ref.watch(settingsRevisionProvider);
    final scale = ref.watch(settingsProvider).scriptureSize.factor;

    final body = text.bodyLarge!.copyWith(
      fontSize: 17 * scale,
      height: 1.75,
      color: c.ink,
    );
    final number = body.copyWith(
      fontSize: 11 * scale,
      fontWeight: FontWeight.w700,
      color: c.teal,
      height: 1.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              showBook
                  ? chapter.reference.toString()
                  : 'Chapter ${chapter.reference.chapter}',
              style: text.titleMedium?.copyWith(color: c.teal),
            ),
            const SizedBox(width: 10),
            Expanded(child: Divider(color: c.parchmentDeep)),
          ],
        ),
        const SizedBox(height: 12),
        // One Text.rich per chapter: the verses must flow as one paragraph,
        // so they cannot be separate widgets.
        Text.rich(
          TextSpan(
            children: [
              for (final (i, verse) in chapter.verses.indexed) ...[
                TextSpan(
                  text: '${i + 1} ',
                  style: number,
                  semanticsLabel: ' verse ${i + 1}, ',
                ),
                TextSpan(text: '$verse '),
              ],
            ],
          ),
          style: body,
        ),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Center(child: CircularProgressIndicator(color: context.colors.teal)),
  );
}

/// The text is a bundled asset, so this should be unreachable. If it ever
/// happens the reading must still be completable — the timer is the contract,
/// not the text.
class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.parchmentDeep.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('The text could not be opened', style: text.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Read this passage from your own Bible — the timer is running '
            'either way.',
            style: text.bodyMedium?.copyWith(color: context.colors.inkSoft),
          ),
        ],
      ),
    );
  }
}
