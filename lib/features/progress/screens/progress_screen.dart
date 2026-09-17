import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/sanctuary.dart';
import '../../../core/bible/books.dart';
import '../../../core/time/format.dart';
import '../../../domain/progress/bible_progress.dart';
import '../../reading/providers/reading_providers.dart';
import '../providers/progress_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final p = ref.watch(bibleProgressProvider);
    final plan = ref.watch(activePlanProvider).value;
    final streak = ref.watch(streakProvider).value;
    final today = ref.watch(clockProvider).today();
    final shownStreak = streak == null
        ? 0
        : ref.watch(streakServiceProvider).displayed(streak, today);

    if (p == null) {
      return const Scaffold(
        appBar: SanctuaryAppBar(title: 'Progress'),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const SanctuaryAppBar(title: 'Progress'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Semantics(
                    label:
                        '${p.percentLabel} of the Bible read, '
                        '${p.completedChapters} of ${p.totalChapters} chapters',
                    excludeSemantics: true,
                    child: SizedBox(
                      width: 112,
                      height: 112,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: p.fraction,
                            strokeWidth: 10,
                            backgroundColor: context.colors.parchmentDeep,
                            color: context.colors.teal,
                            strokeCap: StrokeCap.round,
                          ),
                          Center(
                            child: Text(
                              p.percentLabel,
                              style: text.titleLarge?.copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 18,
                              color: context.colors.teal,
                            ),
                            SizedBox(width: 8),
                            const Overline('Bible progress'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: _n(p.completedChapters),
                                style: text.headlineLarge,
                              ),
                              TextSpan(
                                text: ' /${_n(p.totalChapters)}',
                                style: text.titleMedium?.copyWith(
                                  color: context.colors.inkSoft,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'chapters read',
                          style: text.bodyMedium?.copyWith(
                            color: context.colors.inkSoft,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _TestamentBar(
                    title: 'Old Testament',
                    done: p.oldTestamentCompleted,
                    total: 929,
                  ),
                  const SizedBox(height: 20),
                  _TestamentBar(
                    title: 'New Testament',
                    done: p.newTestamentCompleted,
                    total: 260,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: scaledExtent(context, 108),
            ),
            children: [
              _Stat(
                Icons.menu_book_outlined,
                'Chapters completed',
                _n(p.completedChapters),
              ),
              _Stat(
                Icons.hourglass_empty_rounded,
                'Chapters remaining',
                _n(p.remainingChapters),
              ),
              _Stat(
                Icons.calendar_today_outlined,
                'Days completed',
                plan == null ? '—' : '${p.daysCompleted}',
                suffix: plan == null ? null : '/ ${p.totalDays}',
              ),
              _Stat(
                Icons.local_fire_department_outlined,
                'Current streak',
                '🔥 $shownStreak',
              ),
              _Stat(
                Icons.workspace_premium_outlined,
                'Longest streak',
                '${streak?.longest ?? 0}',
                suffix: 'days',
              ),
              _Stat(
                Icons.flag_outlined,
                'Estimated finish',
                p.estimatedCompletion == null
                    ? 'Done 🎉'
                    : formatMediumDate(p.estimatedCompletion!),
                small: true,
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text('By book', style: text.headlineSmall),
          for (final t in Testament.values) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 10),
              child: Overline(t.title),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: Column(
                  children: [
                    for (final b in p.books.where((x) => x.book.testament == t))
                      _BookRow(b),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _n(int v) => v.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
}

class _TestamentBar extends StatelessWidget {
  const _TestamentBar({
    required this.title,
    required this.done,
    required this.total,
  });
  final String title;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: text.titleMedium)),
            Text(
              '$done / $total',
              style: text.bodyMedium?.copyWith(
                color: context.colors.inkSoft,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ThinBar(total == 0 ? 0 : done / total, height: 8),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(
    this.icon,
    this.label,
    this.value, {
    this.suffix,
    this.small = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final String? suffix;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: context.colors.inkSoft),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: text.bodySmall?.copyWith(
                      color: context.colors.inkSoft,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: (small ? text.titleMedium : text.headlineMedium)
                        ?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ),
                  if (suffix != null)
                    TextSpan(
                      text: ' $suffix',
                      style: text.bodyLarge?.copyWith(
                        color: context.colors.inkSoft,
                      ),
                    ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  const _BookRow(this.p);
  final BookProgress p;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final started = p.completed > 0;
    final (IconData icon, Color iconColor, Color well) = p.isDone
        ? (
            Icons.check_rounded,
            context.colors.onSuccess,
            context.colors.success,
          )
        : started
        ? (
            Icons.play_arrow_rounded,
            context.colors.teal,
            context.colors.parchmentDeep,
          )
        : (
            Icons.circle_outlined,
            context.colors.inkSoft,
            context.colors.parchmentDeep,
          );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(color: well, shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  p.book.name,
                  style: text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: started
                        ? context.colors.ink
                        : context.colors.inkSoft,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${p.completed} / ${p.book.chapters}',
                style: text.bodyMedium?.copyWith(
                  color: context.colors.inkSoft,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ThinBar(p.fraction),
        ],
      ),
    );
  }
}
