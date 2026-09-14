import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: p.fraction,
                          strokeWidth: 9,
                          backgroundColor: AppColors.parchmentDeep,
                          color: AppColors.teal,
                          strokeCap: StrokeCap.round,
                        ),
                        Center(
                          child: Text(p.percentLabel, style: text.titleMedium),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bible Progress', style: text.labelLarge),
                        const SizedBox(height: 4),
                        Text(
                          '${_n(p.completedChapters)} / ${_n(p.totalChapters)}',
                          style: text.headlineSmall,
                        ),
                        Text(
                          'chapters',
                          style: text.bodySmall?.copyWith(
                            color: AppColors.inkSoft,
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
          _TestamentBar(
            title: 'Old Testament',
            done: p.oldTestamentCompleted,
            total: 929,
          ),
          const SizedBox(height: 10),
          _TestamentBar(
            title: 'New Testament',
            done: p.newTestamentCompleted,
            total: 260,
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.9,
            children: [
              _Stat('Chapters completed', _n(p.completedChapters)),
              _Stat('Chapters remaining', _n(p.remainingChapters)),
              _Stat(
                'Days completed',
                plan == null ? '—' : '${p.daysCompleted} / ${p.totalDays}',
              ),
              _Stat('Current streak', '🔥 $shownStreak'),
              _Stat('Longest streak', '${streak?.longest ?? 0} days'),
              _Stat(
                'Estimated finish',
                p.estimatedCompletion == null
                    ? 'Done 🎉'
                    : formatMediumDate(p.estimatedCompletion!),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('By book', style: text.titleMedium),
          const SizedBox(height: 8),
          for (final t in Testament.values) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 6),
              child: Text(
                t.title,
                style: text.labelLarge?.copyWith(color: AppColors.inkSoft),
              ),
            ),
            for (final b in p.books.where((x) => x.book.testament == t))
              _BookRow(b),
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
            Expanded(child: Text(title, style: text.bodyMedium)),
            Text(
              '$done / $total',
              style: text.bodySmall?.copyWith(color: AppColors.inkSoft),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : done / total,
            minHeight: 8,
            backgroundColor: AppColors.parchmentDeep,
            color: done >= total ? AppColors.success : AppColors.teal,
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: text.labelSmall?.copyWith(color: AppColors.inkSoft),
            ),
            const SizedBox(height: 4),
            Text(value, style: text.titleMedium),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 128,
            child: Text(
              p.book.name,
              style: text.bodyMedium?.copyWith(
                color: p.isDone ? AppColors.success : AppColors.ink,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: p.fraction,
                minHeight: 6,
                backgroundColor: AppColors.parchmentDeep,
                color: p.isDone ? AppColors.success : AppColors.teal,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 56,
            child: Text(
              '${p.completed}/${p.book.chapters}',
              textAlign: TextAlign.right,
              style: text.bodySmall?.copyWith(color: AppColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}
