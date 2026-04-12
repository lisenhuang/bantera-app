import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'local_practice_database.g.dart';

class LocalPracticeEntries extends Table {
  @override
  String get tableName => 'local_practice_entries';

  TextColumn get id => text()();
  TextColumn get ownerCacheKey => text()();
  TextColumn get title => text()();
  TextColumn get transcriptPreview => text()();
  TextColumn get description => text()();
  TextColumn get localVideoPath => text()();
  TextColumn get spokenLanguage => text()();
  TextColumn get accent => text()();
  IntColumn get durationMs => integer()();
  IntColumn get cueCount => integer()();
  IntColumn get fileSizeBytes => integer()();
  TextColumn get transcriptionSource => text()();
  TextColumn get translatedLanguage => text().nullable()();
  IntColumn get createdAtMillis => integer()();
  IntColumn get updatedAtMillis => integer()();
  IntColumn get lastOpenedAtMillis => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalPracticeCueEntries extends Table {
  @override
  String get tableName => 'local_practice_cue_entries';

  TextColumn get id => text()();
  TextColumn get itemId => text().references(
    LocalPracticeEntries,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get cueIndex => integer()();
  IntColumn get startTimeMs => integer()();
  IntColumn get endTimeMs => integer()();
  TextColumn get originalText => text()();
  TextColumn get translatedText => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SavedCueEntries extends Table {
  @override
  String get tableName => 'saved_cue_entries';

  TextColumn get id => text()();
  TextColumn get ownerCacheKey => text()();
  TextColumn get mediaItemId => text()();
  TextColumn get cueId => text()();
  IntColumn get cueIndex => integer()();
  TextColumn get cueText => text()();
  TextColumn get mediaItemJson => text()();
  IntColumn get savedAtMillis => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalCueAttemptEntries extends Table {
  @override
  String get tableName => 'local_cue_attempt_entries';

  TextColumn get id => text()();
  TextColumn get ownerCacheKey => text()();
  TextColumn get mediaItemId => text()();
  TextColumn get cueId => text()();
  TextColumn get transcriptText => text()();
  TextColumn get sourceLocaleIdentifier => text()();
  TextColumn get audioPath => text()();
  IntColumn get matchedCount => integer()();
  IntColumn get unexpectedCount => integer()();
  IntColumn get missingCount => integer()();
  IntColumn get recordingDurationMs => integer()();
  IntColumn get createdAtMillis => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'bantera_local_practice.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(
  tables: [LocalPracticeEntries, LocalPracticeCueEntries, LocalCueAttemptEntries, SavedCueEntries],
)
class LocalPracticeDatabase extends _$LocalPracticeDatabase {
  LocalPracticeDatabase._internal() : super(_openConnection());

  static final LocalPracticeDatabase instance =
      LocalPracticeDatabase._internal();

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(localCueAttemptEntries);
      }
      if (from < 3) {
        await migrator.createTable(savedCueEntries);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
