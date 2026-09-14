import '../../core/bible/books.dart';
import '../../core/bible/chapter_reference.dart';
import '../../core/time/local_date.dart';

/// WHAT the plan covers.
///
/// Plans are scope × duration (product decision 2026-09-14). "Bible in a
/// year" and "Psalms in a month" are the same machinery with different
/// arguments, which is what lets more plans be added without new code paths.
sealed class PlanScope {
  const PlanScope();

  List<ChapterReference> get chapters;
  String get title;

  /// Storage form. Never change an existing code.
  String get code;

  static PlanScope fromCode(String code) {
    if (code == 'bible') return const WholeBible();
    if (code == 'ot') return const TestamentScope(Testament.old);
    if (code == 'nt') return const TestamentScope(Testament.newT);
    if (code.startsWith('book:')) return BookScope(code.substring(5));
    throw ArgumentError.value(code, 'code', 'unknown plan scope');
  }
}

class WholeBible extends PlanScope {
  const WholeBible();

  @override
  List<ChapterReference> get chapters => kAllChapters;
  @override
  String get title => 'The whole Bible';
  @override
  String get code => 'bible';
}

class TestamentScope extends PlanScope {
  const TestamentScope(this.testament);
  final Testament testament;

  @override
  List<ChapterReference> get chapters =>
      kAllChapters.where((c) => c.book.testament == testament).toList();
  @override
  String get title => testament.title;
  @override
  String get code => testament == Testament.old ? 'ot' : 'nt';
}

class BookScope extends PlanScope {
  const BookScope(this.bookId);
  final String bookId;

  Testament get testament => bookById(bookId).testament;

  @override
  List<ChapterReference> get chapters =>
      kAllChapters.where((c) => c.bookId == bookId).toList();
  @override
  String get title => bookById(bookId).name;
  @override
  String get code => 'book:$bookId';
}

/// HOW LONG. The generator spreads the scope's chapters evenly over this many
/// days; the remainder goes to the earliest days so the plan never ends with a
/// run of light days.
class PlanDuration {
  const PlanDuration(this.days, this.title);
  final int days;
  final String title;

  static const presets = [
    PlanDuration(365, 'One year'),
    PlanDuration(180, 'Six months'),
    PlanDuration(90, 'Three months'),
    PlanDuration(30, 'One month'),
    PlanDuration(7, 'One week'),
  ];
}

/// A reading plan as the user configured it. Persisted; everything else about
/// the plan is regenerated from these four fields.
class PlanDefinition {
  const PlanDefinition({
    required this.id,
    required this.scope,
    required this.targetDays,
    required this.startDate,
  });

  final int id;
  final PlanScope scope;
  final int targetDays;
  final LocalDate startDate;

  String get title => '${scope.title} · ${_durationTitle(targetDays)}';

  static String _durationTitle(int days) {
    for (final p in PlanDuration.presets) {
      if (p.days == days) return p.title;
    }
    return '$days days';
  }
}
