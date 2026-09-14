/// The arithmetic of a timed reading. Pure; the repository stores the facts,
/// the UI repaints once a second, and this decides what they mean.
///
/// The requirement is measured between two instants — `startedAt` and now —
/// never by counting ticks. Closing the app, rebuilding the screen or
/// restarting the phone cannot change either instant, so none of them can
/// shorten the reading.
class SessionTiming {
  const SessionTiming({
    required this.required,
    required this.elapsed,
    required this.clockMovedBack,
  });

  final Duration required;
  final Duration elapsed;

  /// `now` is earlier than `startedAt`. A wall clock only runs backwards when
  /// someone moves it, and a session measured across that is meaningless.
  final bool clockMovedBack;

  Duration get remaining =>
      elapsed >= required ? Duration.zero : required - elapsed;
  bool get isComplete => !clockMovedBack && remaining == Duration.zero;
  double get progress => required == Duration.zero
      ? 1
      : (elapsed.inMilliseconds / required.inMilliseconds).clamp(0.0, 1.0);
}

class ReadingSessionService {
  const ReadingSessionService();

  SessionTiming timing({
    required DateTime startedAtUtc,
    required Duration required,
    required DateTime nowUtc,
  }) {
    final elapsed = nowUtc.difference(startedAtUtc);
    if (elapsed.isNegative) {
      return SessionTiming(
        required: required,
        elapsed: Duration.zero,
        clockMovedBack: true,
      );
    }
    return SessionTiming(
      required: required,
      elapsed: elapsed,
      clockMovedBack: false,
    );
  }
}

/// "11:59", "1:04:09".
String formatCountdown(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  final mm = h > 0 ? m.toString().padLeft(2, '0') : m.toString();
  return '${h > 0 ? '$h:' : ''}$mm:${s.toString().padLeft(2, '0')}';
}
