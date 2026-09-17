import 'dart:io';

import 'package:bible_reading_plan/data/db/database.dart';
import 'package:bible_reading_plan/data/repositories/progress_repository.dart';
import 'package:bible_reading_plan/domain/passages/passage.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// Opens a database exactly as drift created it at v1 and proves the passage
/// columns arrive and work. The version it lands on is whatever the app's
/// current schema is — `migration_v2_to_v3_test.dart` covers the later steps
/// and the data they must preserve.
void main() {
  test('a v1 database upgrades to v2 and stores a passage session', () async {
    final dir = await Directory.systemTemp.createTemp('brp_mig');
    final file = File('${dir.path}/v1.sqlite');

    // v1 DDL, as drift generates it (snake_case, dateTime as INTEGER).
    final raw = sqlite.sqlite3.open(file.path);
    raw.execute('''
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
        completed_at INTEGER, invalidated_reason TEXT);
      CREATE TABLE streaks (id INTEGER NOT NULL, current INTEGER NOT NULL DEFAULT 0,
        longest INTEGER NOT NULL DEFAULT 0, last_completed_on_epoch_day INTEGER,
        PRIMARY KEY (id));
      CREATE TABLE achievements (badge_id TEXT NOT NULL, unlocked_at INTEGER NOT NULL,
        PRIMARY KEY (badge_id));
      INSERT INTO reading_plans (scope_code, target_days, start_epoch_day, is_active, created_at)
        VALUES ('bible', 365, 20700, 1, 0);
      INSERT INTO reading_sessions (plan_id, day_index, started_at, required_ms)
        VALUES (1, 0, 0, 60000);
      PRAGMA user_version = 1;
    ''');
    raw.close();

    final db = AppDatabase.withExecutor(NativeDatabase(file));
    final repo = ProgressRepository(db);

    // The pre-existing v1 session row is intact and is a plan day.
    final rows = await db.select(db.readingSessions).get();
    expect(rows.single.dayIndex, 0);
    expect(ProgressRepository.passageOf(rows.single), isNull);

    // The new columns exist and round-trip.
    final s = await repo.startPassageSession(
      passage: passageById('psalm_23'),
      planId: 1,
      required: const Duration(minutes: 2),
      nowUtc: DateTime.utc(2026, 9, 14, 10),
    );
    expect(ProgressRepository.passageOf(s)?.reference, 'Psalms 23');
    expect(
      (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
        'user_version',
      ),
      db.schemaVersion,
    );

    await db.close();
    await dir.delete(recursive: true);
  });
}
