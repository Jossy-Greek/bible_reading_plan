import 'package:flutter/material.dart';

import '../../../core/bible/books.dart';

/// Two tabs, one per testament, so a 66-row list is never scrolled blind.
Future<BibleBook?> showBookPicker(
  BuildContext context, {
  Testament initialTestament = Testament.old,
}) => showModalBottomSheet<BibleBook>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (ctx) => SizedBox(
    height: MediaQuery.sizeOf(ctx).height * 0.8,
    child: BookPicker(
      initialTestament: initialTestament,
      onPicked: (b) => Navigator.of(ctx).pop(b),
    ),
  ),
);

class BookPicker extends StatelessWidget {
  const BookPicker({
    super.key,
    required this.initialTestament,
    required this.onPicked,
  });

  final Testament initialTestament;
  final ValueChanged<BibleBook> onPicked;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: Testament.values.length,
      initialIndex: Testament.values.indexOf(initialTestament),
      child: Column(
        children: [
          TabBar(tabs: [for (final t in Testament.values) Tab(text: t.title)]),
          Expanded(
            child: TabBarView(
              children: [
                for (final t in Testament.values)
                  ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: booksIn(t).length,
                    itemBuilder: (_, i) {
                      final b = booksIn(t).elementAt(i);
                      return ListTile(
                        title: Text(b.name),
                        subtitle: Text(
                          '${b.chapters} ${b.chapters == 1 ? 'chapter' : 'chapters'}',
                        ),
                        onTap: () => onPicked(b),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
