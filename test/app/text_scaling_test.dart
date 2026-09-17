import 'package:bible_reading_plan/app/widgets/sanctuary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A stat tile's shape: fixed padding, a label, a Spacer, a big number.
Widget _tile() => const Card(
  child: Padding(
    padding: EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chapters completed'),
        Spacer(),
        Text('1,189', style: TextStyle(fontSize: 28, height: 36 / 28)),
      ],
    ),
  ),
);

Future<void> _pumpGrid(WidgetTester tester, double scale, double base) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: Scaffold(
            body: Builder(
              builder: (context) => GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: scaledExtent(context, base),
                ),
                children: List.generate(4, (_) => _tile()),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('stat tiles survive a 200% text scale', (tester) async {
    // A tile sized by childAspectRatio cannot grow with the font; one sized
    // by scaledExtent must, or an older reader sees the yellow bars.
    for (final scale in [1.0, 1.3, 1.6, 2.0]) {
      await _pumpGrid(tester, scale, 108);
      expect(
        tester.takeException(),
        isNull,
        reason: 'overflowed at text scale $scale',
      );
    }
  });

  testWidgets('scaledExtent actually grows with the reader', (tester) async {
    late double small, large;
    for (final (scale, sink) in [(1.0, 0), (2.0, 1)]) {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: Builder(
              builder: (context) {
                final v = scaledExtent(context, 100);
                if (sink == 0) {
                  small = v;
                } else {
                  large = v;
                }
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    }
    expect(large, greaterThan(small));
    expect(large, 200);
  });
}
