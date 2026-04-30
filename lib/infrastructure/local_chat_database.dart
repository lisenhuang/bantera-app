import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'local_chat_database.g.dart';

class ChatThreadEntries extends Table {
  @override
  String get tableName => 'chat_thread_entries';

  TextColumn get ownerCacheKey => text()();
  TextColumn get threadId => text()();
  TextColumn get threadType => text()();
  TextColumn get title => text()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get learningLanguage => text().nullable()();
  TextColumn get learningLanguageDisplay => text().nullable()();
  TextColumn get nativeLanguage => text().nullable()();
  TextColumn get nativeLanguageDisplay => text().nullable()();
  BoolColumn get isMuted => boolean().withDefault(const Constant(false))();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  IntColumn get lastMessageAtMillis => integer().nullable()();
  IntColumn get lastMessageDurationMs => integer().nullable()();
  TextColumn get otherUserId => text().nullable()();
  TextColumn get roleBadgesJson => text().withDefault(const Constant('[]'))();
  TextColumn get section => text()();
  IntColumn get sectionOrder => integer().withDefault(const Constant(0))();
  IntColumn get updatedAtMillis => integer()();

  @override
  Set<Column<Object>> get primaryKey => {ownerCacheKey, threadId};
}

class ChatUserEntries extends Table {
  @override
  String get tableName => 'chat_user_entries';

  TextColumn get ownerCacheKey => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get learningLanguage => text().nullable()();
  TextColumn get learningLanguageDisplay => text().nullable()();
  TextColumn get nativeLanguage => text().nullable()();
  TextColumn get nativeLanguageDisplay => text().nullable()();
  BoolColumn get isOnline => boolean().withDefault(const Constant(false))();
  IntColumn get updatedAtMillis => integer()();

  @override
  Set<Column<Object>> get primaryKey => {ownerCacheKey, userId};
}

class ChatMessageEntries extends Table {
  @override
  String get tableName => 'chat_message_entries';

  TextColumn get ownerCacheKey => text()();
  TextColumn get messageId => text()();
  TextColumn get threadId => text()();
  TextColumn get threadType => text()();
  TextColumn get senderUserId => text()();
  TextColumn get senderName => text()();
  TextColumn get senderAvatarUrl => text().nullable()();
  TextColumn get senderLearningLanguage => text().nullable()();
  TextColumn get senderLearningLanguageDisplay => text().nullable()();
  TextColumn get senderNativeLanguage => text().nullable()();
  TextColumn get senderNativeLanguageDisplay => text().nullable()();
  BoolColumn get senderIsOnline =>
      boolean().withDefault(const Constant(false))();
  TextColumn get spokenLanguageCode => text()();
  IntColumn get durationMs => integer()();
  IntColumn get createdAtMillis => integer()();
  IntColumn get expiresAtMillis => integer().nullable()();
  BoolColumn get isMine => boolean().withDefault(const Constant(false))();
  TextColumn get audioUrl => text()();
  TextColumn get localAudioPath => text().nullable()();
  TextColumn get localTranscriptText => text().nullable()();
  TextColumn get localTranscriptStatus => text().nullable()();
  TextColumn get localTranscriptLanguage => text().nullable()();
  TextColumn get localTranscriptLanguageCode => text().nullable()();
  BoolColumn get isServerVisible =>
      boolean().withDefault(const Constant(true))();
  IntColumn get updatedAtMillis => integer()();

  @override
  Set<Column<Object>> get primaryKey => {ownerCacheKey, messageId};
}

class ChatBlockEntries extends Table {
  @override
  String get tableName => 'chat_block_entries';

  TextColumn get ownerCacheKey => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get learningLanguage => text().nullable()();
  TextColumn get learningLanguageDisplay => text().nullable()();
  TextColumn get nativeLanguage => text().nullable()();
  TextColumn get nativeLanguageDisplay => text().nullable()();
  BoolColumn get isOnline => boolean().withDefault(const Constant(false))();
  IntColumn get updatedAtMillis => integer()();

  @override
  Set<Column<Object>> get primaryKey => {ownerCacheKey, userId};
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'bantera_local_chat.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(
  tables: [
    ChatThreadEntries,
    ChatUserEntries,
    ChatMessageEntries,
    ChatBlockEntries,
  ],
)
class LocalChatDatabase extends _$LocalChatDatabase {
  LocalChatDatabase._internal() : super(_openConnection());

  static final LocalChatDatabase instance = LocalChatDatabase._internal();

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
