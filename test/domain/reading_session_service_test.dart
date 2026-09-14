import 'package:bible_reading_plan/domain/session/reading_session_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const svc = ReadingSessionService();
  final started = DateTime.utc(2026, 9, 14, 10, 0);
  const required = Duration(minutes: 12);

  test('remaining is required minus elapsed, from timestamps alone', () {
    final t = svc.timing(
      startedAtUtc: started,
      required: required,
      nowUtc: started.add(const Duration(minutes: 8)),
    );
    expect(t.remaining, const Duration(minutes: 4));
    expect(t.isComplete, isFalse);
    expect(t.progress, closeTo(8 / 12, 1e-9));
  });

  test(
    'restarting the app cannot shorten it: same timestamps, same answer',
    () {
      final a = svc.timing(
        startedAtUtc: started,
        required: required,
        nowUtc: started.add(const Duration(minutes: 3)),
      );
      final b = svc.timing(
        startedAtUtc: started,
        required: required,
        nowUtc: started.add(const Duration(minutes: 3)),
      );
      expect(a.remaining, b.remaining);
    },
  );

  test('complete exactly at, and after, the requirement', () {
    expect(
      svc
          .timing(
            startedAtUtc: started,
            required: required,
            nowUtc: started.add(required),
          )
          .isComplete,
      isTrue,
    );
    final late = svc.timing(
      startedAtUtc: started,
      required: required,
      nowUtc: started.add(const Duration(hours: 2)),
    );
    expect(late.isComplete, isTrue);
    expect(late.remaining, Duration.zero);
  });

  test('a clock moved backwards is detected and never completes', () {
    final t = svc.timing(
      startedAtUtc: started,
      required: required,
      nowUtc: started.subtract(const Duration(minutes: 1)),
    );
    expect(t.clockMovedBack, isTrue);
    expect(t.isComplete, isFalse);
  });

  test('countdown formatting', () {
    expect(formatCountdown(const Duration(minutes: 11, seconds: 59)), '11:59');
    expect(formatCountdown(const Duration(seconds: 7)), '0:07');
    expect(
      formatCountdown(const Duration(hours: 1, minutes: 4, seconds: 9)),
      '1:04:09',
    );
  });
}
