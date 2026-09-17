import 'dart:io';

import 'package:bible_reading_plan/data/db/database.dart';
import 'package:bible_reading_plan/data/repositories/progress_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

const _v2Ddl = '''
  CREATE TABLE reading_plans (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    scope_code TEXT NOT NULL, target_days INTEGER NOT NULL,
    start_epoch_day INTEGER NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    created_at INTEGER NOT NULL);
  CREATE TABLE day_completions (plan_id INTEGER NOT NULL, day_index INTEGER NOT NULL,
    completed_on_epoch_day INTEGER NOT NULL, completed_at INTEGER NOT NULL,
    PRIMARY KEY (plan_id, day_index));
  CREATE TABLE chapter_completions (book_id TEXT NOT NULL, chapter INTEGER NOT NULL,
    completed_at INTEGER NOT NULL, plan_id INTEGER, PRIMARY KEY (book_id, chapter));
  CREATE TABLE reading_sessions (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    plan_id INTEGER NOT NULL, day_index INTEGER NOT NULL, started_at INTEGER NOT NULL,
    required_ms INTEGER NOT NULL, foreground_ms INTEGER NOT NULL DEFAULT 0,
    completed_at INTEGER, invalidated_reason TEXT,
    passage_title TEXT, passage_book_id TEXT, passage_from INTEGER, passage_to INTEGER);
  CREATE TABLE streaks (id INTEGER NOT NULL, current INTEGER NOT NULL DEFAULT 0,
    longest INTEGER NOT NULL DEFAULT 0, last_completed_on_epoch_day INTEGER,
    PRIMARY KEY (id));
  CREATE TABLE achievements (badge_id TEXT NOT NULL, unlocked_at INTEGER NOT NULL,
    PRIMARY KEY (badge_id));
''';

/// Upgrades from every schema the owner's phone may actually be holding.
/// It is on schema 2 as of db58141 — a plan in progress, days completed,
/// chapters read, a streak and a badge — and none of that may be lost on the
/// way to the current version.
void main() {
  test('a v2 database upgrades keeping everything it held', () async {
    final dir = await Directory.systemTemp.createTemp('brp_mig23');
    final file = File('${dir.path}/v2.sqlite');

    final raw = sqlite.sqlite3.open(file.path);
    raw.execute('''
      $_v2Ddl
      INSERT INTO reading_plans (scope_code, target_days, start_epoch_day, is_active, created_at)
        VALUES ('mark', 7, 20710, 1, 0);
      INSERT INTO day_completions (plan_id, day_index, completed_on_epoch_day, completed_at)
        VALUES (1, 0, 20710, 0), (1, 1, 20711, 0), (1, 2, 20712, 0);
      INSERT INTO chapter_completions (book_id, chapter, completed_at, plan_id)
        VALUES ('mark', 1, 0, 1), ('mark', 2, 0, 1), ('mark', 3, 0, 1);
      INSERT INTO streaks (id, current, longest, last_completed_on_epoch_day)
        VALUES (1, 3, 3, 20712);
      INSERT INTO achievements (badge_id, unlocked_at) VALUES ('first_reading', 0);
      INSERT INTO reading_sessions (plan_id, day_index, started_at, required_ms, completed_at)
        VALUES (1, 0, 0, 60000, 100);
      INSERT INTO reading_sessions (plan_id, day_index, started_at, required_ms,
        completed_at, passage_title, passage_book_id, passage_from, passage_to)
        VALUES (1, -1, 0, 60000, 200, 'The Shepherd Psalm', 'psalms', 23, 23);
      PRAGMA user_version = 2;
    ''');
    raw.close();

    final db = AppDatabase.withExecutor(NativeDatabase(file));
    final repo = ProgressRepository(db);

    expect(
      (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
        'user_version',
      ),
      db.schemaVersion,
    );

    // Nothing the reader earned was lost.
    expect(await db.select(db.dayCompletions).get(), hasLength(3));
    expect(await db.select(db.chapterCompletions).get(), hasLength(3));
    expect((await db.select(db.streaks).getSingle()).current, 3);
    expect(await db.select(db.achievements).get(), hasLength(1));

    // v2's passage columns still work.
    final sessions = await db.select(db.readingSessions).get();
    expect(sessions, hasLength(2));
    final passage = sessions.firstWhere((s) => s.passageBookId != null);
    expect(ProgressRepository.passageOf(passage)?.reference, 'Psalms 23');

    // The new columns exist, are null for old rows, and round-trip.
    expect(sessions.every((s) => s.note == null), isTrue);
    expect(sessions.every((s) => s.reference == null), isTrue);
    await repo.setNote(passage.id, 'The Lord is my shepherd.');
    final reflections = await repo.watchReflections().first;
    expect(reflections.single.note, 'The Lord is my shepherd.');
    // An old row has no stamped reference; the journal must cope.
    expect(reflections.single.reference, isNull);

    // v4: the streak came across intact and has spent no grace day, so the
    // reader's first missed day this month is still covered.
    final streak = await repo.watchStreak().first;
    expect(streak.current, 3);
    expect(streak.longest, 3);
    expect(streak.graceUsedOn, isNull);

    await db.close();
    await dir.delete(recursive: true);
  });

  test('a v1 database upgrades straight to the current schema', () async {
    final dir = await Directory.systemTemp.createTemp('brp_mig13');
    final file = File('${dir.path}/v1.sqlite');
    final raw = sqlite.sqlite3.open(file.path);
    raw.execute('''
      ${_v2Ddl.replaceAll("    passage_title TEXT, passage_book_id TEXT, passage_from INTEGER, passage_to INTEGER);", "    dummy_never_used INTEGER);")}
      PRAGMA user_version = 1;
    ''');
    raw.close();

    final db = AppDatabase.withExecutor(NativeDatabase(file));
    expect(
      (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
        'user_version',
      ),
      db.schemaVersion,
    );
    // Every migration step ran, in order.
    final cols = await db
        .customSelect("PRAGMA table_info('reading_sessions')")
        .get();
    final names = cols.map((r) => r.read<String>('name')).toSet();
    expect(
      names,
      containsAll(['passage_title', 'passage_to', 'note', 'reference']),
    );
    final streakCols = await db
        .customSelect("PRAGMA table_info('streaks')")
        .get();
    expect(
      streakCols.map((r) => r.read<String>('name')),
      contains('grace_used_on_epoch_day'),
    );

    await db.close();
    await dir.delete(recursive: true);
  });
}
