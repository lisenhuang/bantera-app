// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_chat_database.dart';

// ignore_for_file: type=lint
class $ChatThreadEntriesTable extends ChatThreadEntries
    with TableInfo<$ChatThreadEntriesTable, ChatThreadEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatThreadEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerCacheKeyMeta = const VerificationMeta(
    'ownerCacheKey',
  );
  @override
  late final GeneratedColumn<String> ownerCacheKey = GeneratedColumn<String>(
    'owner_cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _threadIdMeta = const VerificationMeta(
    'threadId',
  );
  @override
  late final GeneratedColumn<String> threadId = GeneratedColumn<String>(
    'thread_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _threadTypeMeta = const VerificationMeta(
    'threadType',
  );
  @override
  late final GeneratedColumn<String> threadType = GeneratedColumn<String>(
    'thread_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _learningLanguageMeta = const VerificationMeta(
    'learningLanguage',
  );
  @override
  late final GeneratedColumn<String> learningLanguage = GeneratedColumn<String>(
    'learning_language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _learningLanguageDisplayMeta =
      const VerificationMeta('learningLanguageDisplay');
  @override
  late final GeneratedColumn<String> learningLanguageDisplay =
      GeneratedColumn<String>(
        'learning_language_display',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nativeLanguageMeta = const VerificationMeta(
    'nativeLanguage',
  );
  @override
  late final GeneratedColumn<String> nativeLanguage = GeneratedColumn<String>(
    'native_language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nativeLanguageDisplayMeta =
      const VerificationMeta('nativeLanguageDisplay');
  @override
  late final GeneratedColumn<String> nativeLanguageDisplay =
      GeneratedColumn<String>(
        'native_language_display',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isMutedMeta = const VerificationMeta(
    'isMuted',
  );
  @override
  late final GeneratedColumn<bool> isMuted = GeneratedColumn<bool>(
    'is_muted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_muted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastMessageAtMillisMeta =
      const VerificationMeta('lastMessageAtMillis');
  @override
  late final GeneratedColumn<int> lastMessageAtMillis = GeneratedColumn<int>(
    'last_message_at_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageDurationMsMeta =
      const VerificationMeta('lastMessageDurationMs');
  @override
  late final GeneratedColumn<int> lastMessageDurationMs = GeneratedColumn<int>(
    'last_message_duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _otherUserIdMeta = const VerificationMeta(
    'otherUserId',
  );
  @override
  late final GeneratedColumn<String> otherUserId = GeneratedColumn<String>(
    'other_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleBadgesJsonMeta = const VerificationMeta(
    'roleBadgesJson',
  );
  @override
  late final GeneratedColumn<String> roleBadgesJson = GeneratedColumn<String>(
    'role_badges_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _sectionMeta = const VerificationMeta(
    'section',
  );
  @override
  late final GeneratedColumn<String> section = GeneratedColumn<String>(
    'section',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionOrderMeta = const VerificationMeta(
    'sectionOrder',
  );
  @override
  late final GeneratedColumn<int> sectionOrder = GeneratedColumn<int>(
    'section_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMillisMeta = const VerificationMeta(
    'updatedAtMillis',
  );
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
    'updated_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerCacheKey,
    threadId,
    threadType,
    title,
    avatarUrl,
    learningLanguage,
    learningLanguageDisplay,
    nativeLanguage,
    nativeLanguageDisplay,
    isMuted,
    unreadCount,
    lastMessageAtMillis,
    lastMessageDurationMs,
    otherUserId,
    roleBadgesJson,
    section,
    sectionOrder,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_thread_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatThreadEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_cache_key')) {
      context.handle(
        _ownerCacheKeyMeta,
        ownerCacheKey.isAcceptableOrUnknown(
          data['owner_cache_key']!,
          _ownerCacheKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerCacheKeyMeta);
    }
    if (data.containsKey('thread_id')) {
      context.handle(
        _threadIdMeta,
        threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('thread_type')) {
      context.handle(
        _threadTypeMeta,
        threadType.isAcceptableOrUnknown(data['thread_type']!, _threadTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_threadTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('learning_language')) {
      context.handle(
        _learningLanguageMeta,
        learningLanguage.isAcceptableOrUnknown(
          data['learning_language']!,
          _learningLanguageMeta,
        ),
      );
    }
    if (data.containsKey('learning_language_display')) {
      context.handle(
        _learningLanguageDisplayMeta,
        learningLanguageDisplay.isAcceptableOrUnknown(
          data['learning_language_display']!,
          _learningLanguageDisplayMeta,
        ),
      );
    }
    if (data.containsKey('native_language')) {
      context.handle(
        _nativeLanguageMeta,
        nativeLanguage.isAcceptableOrUnknown(
          data['native_language']!,
          _nativeLanguageMeta,
        ),
      );
    }
    if (data.containsKey('native_language_display')) {
      context.handle(
        _nativeLanguageDisplayMeta,
        nativeLanguageDisplay.isAcceptableOrUnknown(
          data['native_language_display']!,
          _nativeLanguageDisplayMeta,
        ),
      );
    }
    if (data.containsKey('is_muted')) {
      context.handle(
        _isMutedMeta,
        isMuted.isAcceptableOrUnknown(data['is_muted']!, _isMutedMeta),
      );
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('last_message_at_millis')) {
      context.handle(
        _lastMessageAtMillisMeta,
        lastMessageAtMillis.isAcceptableOrUnknown(
          data['last_message_at_millis']!,
          _lastMessageAtMillisMeta,
        ),
      );
    }
    if (data.containsKey('last_message_duration_ms')) {
      context.handle(
        _lastMessageDurationMsMeta,
        lastMessageDurationMs.isAcceptableOrUnknown(
          data['last_message_duration_ms']!,
          _lastMessageDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('other_user_id')) {
      context.handle(
        _otherUserIdMeta,
        otherUserId.isAcceptableOrUnknown(
          data['other_user_id']!,
          _otherUserIdMeta,
        ),
      );
    }
    if (data.containsKey('role_badges_json')) {
      context.handle(
        _roleBadgesJsonMeta,
        roleBadgesJson.isAcceptableOrUnknown(
          data['role_badges_json']!,
          _roleBadgesJsonMeta,
        ),
      );
    }
    if (data.containsKey('section')) {
      context.handle(
        _sectionMeta,
        section.isAcceptableOrUnknown(data['section']!, _sectionMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionMeta);
    }
    if (data.containsKey('section_order')) {
      context.handle(
        _sectionOrderMeta,
        sectionOrder.isAcceptableOrUnknown(
          data['section_order']!,
          _sectionOrderMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_millis')) {
      context.handle(
        _updatedAtMillisMeta,
        updatedAtMillis.isAcceptableOrUnknown(
          data['updated_at_millis']!,
          _updatedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerCacheKey, threadId};
  @override
  ChatThreadEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatThreadEntry(
      ownerCacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_cache_key'],
      )!,
      threadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thread_id'],
      )!,
      threadType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thread_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      learningLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_language'],
      ),
      learningLanguageDisplay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_language_display'],
      ),
      nativeLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}native_language'],
      ),
      nativeLanguageDisplay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}native_language_display'],
      ),
      isMuted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_muted'],
      )!,
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
      lastMessageAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_message_at_millis'],
      ),
      lastMessageDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_message_duration_ms'],
      ),
      otherUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}other_user_id'],
      ),
      roleBadgesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_badges_json'],
      )!,
      section: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section'],
      )!,
      sectionOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}section_order'],
      )!,
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_millis'],
      )!,
    );
  }

  @override
  $ChatThreadEntriesTable createAlias(String alias) {
    return $ChatThreadEntriesTable(attachedDatabase, alias);
  }
}

class ChatThreadEntry extends DataClass implements Insertable<ChatThreadEntry> {
  final String ownerCacheKey;
  final String threadId;
  final String threadType;
  final String title;
  final String? avatarUrl;
  final String? learningLanguage;
  final String? learningLanguageDisplay;
  final String? nativeLanguage;
  final String? nativeLanguageDisplay;
  final bool isMuted;
  final int unreadCount;
  final int? lastMessageAtMillis;
  final int? lastMessageDurationMs;
  final String? otherUserId;
  final String roleBadgesJson;
  final String section;
  final int sectionOrder;
  final int updatedAtMillis;
  const ChatThreadEntry({
    required this.ownerCacheKey,
    required this.threadId,
    required this.threadType,
    required this.title,
    this.avatarUrl,
    this.learningLanguage,
    this.learningLanguageDisplay,
    this.nativeLanguage,
    this.nativeLanguageDisplay,
    required this.isMuted,
    required this.unreadCount,
    this.lastMessageAtMillis,
    this.lastMessageDurationMs,
    this.otherUserId,
    required this.roleBadgesJson,
    required this.section,
    required this.sectionOrder,
    required this.updatedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_cache_key'] = Variable<String>(ownerCacheKey);
    map['thread_id'] = Variable<String>(threadId);
    map['thread_type'] = Variable<String>(threadType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || learningLanguage != null) {
      map['learning_language'] = Variable<String>(learningLanguage);
    }
    if (!nullToAbsent || learningLanguageDisplay != null) {
      map['learning_language_display'] = Variable<String>(
        learningLanguageDisplay,
      );
    }
    if (!nullToAbsent || nativeLanguage != null) {
      map['native_language'] = Variable<String>(nativeLanguage);
    }
    if (!nullToAbsent || nativeLanguageDisplay != null) {
      map['native_language_display'] = Variable<String>(nativeLanguageDisplay);
    }
    map['is_muted'] = Variable<bool>(isMuted);
    map['unread_count'] = Variable<int>(unreadCount);
    if (!nullToAbsent || lastMessageAtMillis != null) {
      map['last_message_at_millis'] = Variable<int>(lastMessageAtMillis);
    }
    if (!nullToAbsent || lastMessageDurationMs != null) {
      map['last_message_duration_ms'] = Variable<int>(lastMessageDurationMs);
    }
    if (!nullToAbsent || otherUserId != null) {
      map['other_user_id'] = Variable<String>(otherUserId);
    }
    map['role_badges_json'] = Variable<String>(roleBadgesJson);
    map['section'] = Variable<String>(section);
    map['section_order'] = Variable<int>(sectionOrder);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  ChatThreadEntriesCompanion toCompanion(bool nullToAbsent) {
    return ChatThreadEntriesCompanion(
      ownerCacheKey: Value(ownerCacheKey),
      threadId: Value(threadId),
      threadType: Value(threadType),
      title: Value(title),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      learningLanguage: learningLanguage == null && nullToAbsent
          ? const Value.absent()
          : Value(learningLanguage),
      learningLanguageDisplay: learningLanguageDisplay == null && nullToAbsent
          ? const Value.absent()
          : Value(learningLanguageDisplay),
      nativeLanguage: nativeLanguage == null && nullToAbsent
          ? const Value.absent()
          : Value(nativeLanguage),
      nativeLanguageDisplay: nativeLanguageDisplay == null && nullToAbsent
          ? const Value.absent()
          : Value(nativeLanguageDisplay),
      isMuted: Value(isMuted),
      unreadCount: Value(unreadCount),
      lastMessageAtMillis: lastMessageAtMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAtMillis),
      lastMessageDurationMs: lastMessageDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageDurationMs),
      otherUserId: otherUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(otherUserId),
      roleBadgesJson: Value(roleBadgesJson),
      section: Value(section),
      sectionOrder: Value(sectionOrder),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory ChatThreadEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatThreadEntry(
      ownerCacheKey: serializer.fromJson<String>(json['ownerCacheKey']),
      threadId: serializer.fromJson<String>(json['threadId']),
      threadType: serializer.fromJson<String>(json['threadType']),
      title: serializer.fromJson<String>(json['title']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      learningLanguage: serializer.fromJson<String?>(json['learningLanguage']),
      learningLanguageDisplay: serializer.fromJson<String?>(
        json['learningLanguageDisplay'],
      ),
      nativeLanguage: serializer.fromJson<String?>(json['nativeLanguage']),
      nativeLanguageDisplay: serializer.fromJson<String?>(
        json['nativeLanguageDisplay'],
      ),
      isMuted: serializer.fromJson<bool>(json['isMuted']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      lastMessageAtMillis: serializer.fromJson<int?>(
        json['lastMessageAtMillis'],
      ),
      lastMessageDurationMs: serializer.fromJson<int?>(
        json['lastMessageDurationMs'],
      ),
      otherUserId: serializer.fromJson<String?>(json['otherUserId']),
      roleBadgesJson: serializer.fromJson<String>(json['roleBadgesJson']),
      section: serializer.fromJson<String>(json['section']),
      sectionOrder: serializer.fromJson<int>(json['sectionOrder']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerCacheKey': serializer.toJson<String>(ownerCacheKey),
      'threadId': serializer.toJson<String>(threadId),
      'threadType': serializer.toJson<String>(threadType),
      'title': serializer.toJson<String>(title),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'learningLanguage': serializer.toJson<String?>(learningLanguage),
      'learningLanguageDisplay': serializer.toJson<String?>(
        learningLanguageDisplay,
      ),
      'nativeLanguage': serializer.toJson<String?>(nativeLanguage),
      'nativeLanguageDisplay': serializer.toJson<String?>(
        nativeLanguageDisplay,
      ),
      'isMuted': serializer.toJson<bool>(isMuted),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'lastMessageAtMillis': serializer.toJson<int?>(lastMessageAtMillis),
      'lastMessageDurationMs': serializer.toJson<int?>(lastMessageDurationMs),
      'otherUserId': serializer.toJson<String?>(otherUserId),
      'roleBadgesJson': serializer.toJson<String>(roleBadgesJson),
      'section': serializer.toJson<String>(section),
      'sectionOrder': serializer.toJson<int>(sectionOrder),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  ChatThreadEntry copyWith({
    String? ownerCacheKey,
    String? threadId,
    String? threadType,
    String? title,
    Value<String?> avatarUrl = const Value.absent(),
    Value<String?> learningLanguage = const Value.absent(),
    Value<String?> learningLanguageDisplay = const Value.absent(),
    Value<String?> nativeLanguage = const Value.absent(),
    Value<String?> nativeLanguageDisplay = const Value.absent(),
    bool? isMuted,
    int? unreadCount,
    Value<int?> lastMessageAtMillis = const Value.absent(),
    Value<int?> lastMessageDurationMs = const Value.absent(),
    Value<String?> otherUserId = const Value.absent(),
    String? roleBadgesJson,
    String? section,
    int? sectionOrder,
    int? updatedAtMillis,
  }) => ChatThreadEntry(
    ownerCacheKey: ownerCacheKey ?? this.ownerCacheKey,
    threadId: threadId ?? this.threadId,
    threadType: threadType ?? this.threadType,
    title: title ?? this.title,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    learningLanguage: learningLanguage.present
        ? learningLanguage.value
        : this.learningLanguage,
    learningLanguageDisplay: learningLanguageDisplay.present
        ? learningLanguageDisplay.value
        : this.learningLanguageDisplay,
    nativeLanguage: nativeLanguage.present
        ? nativeLanguage.value
        : this.nativeLanguage,
    nativeLanguageDisplay: nativeLanguageDisplay.present
        ? nativeLanguageDisplay.value
        : this.nativeLanguageDisplay,
    isMuted: isMuted ?? this.isMuted,
    unreadCount: unreadCount ?? this.unreadCount,
    lastMessageAtMillis: lastMessageAtMillis.present
        ? lastMessageAtMillis.value
        : this.lastMessageAtMillis,
    lastMessageDurationMs: lastMessageDurationMs.present
        ? lastMessageDurationMs.value
        : this.lastMessageDurationMs,
    otherUserId: otherUserId.present ? otherUserId.value : this.otherUserId,
    roleBadgesJson: roleBadgesJson ?? this.roleBadgesJson,
    section: section ?? this.section,
    sectionOrder: sectionOrder ?? this.sectionOrder,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  ChatThreadEntry copyWithCompanion(ChatThreadEntriesCompanion data) {
    return ChatThreadEntry(
      ownerCacheKey: data.ownerCacheKey.present
          ? data.ownerCacheKey.value
          : this.ownerCacheKey,
      threadId: data.threadId.present ? data.threadId.value : this.threadId,
      threadType: data.threadType.present
          ? data.threadType.value
          : this.threadType,
      title: data.title.present ? data.title.value : this.title,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      learningLanguage: data.learningLanguage.present
          ? data.learningLanguage.value
          : this.learningLanguage,
      learningLanguageDisplay: data.learningLanguageDisplay.present
          ? data.learningLanguageDisplay.value
          : this.learningLanguageDisplay,
      nativeLanguage: data.nativeLanguage.present
          ? data.nativeLanguage.value
          : this.nativeLanguage,
      nativeLanguageDisplay: data.nativeLanguageDisplay.present
          ? data.nativeLanguageDisplay.value
          : this.nativeLanguageDisplay,
      isMuted: data.isMuted.present ? data.isMuted.value : this.isMuted,
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
      lastMessageAtMillis: data.lastMessageAtMillis.present
          ? data.lastMessageAtMillis.value
          : this.lastMessageAtMillis,
      lastMessageDurationMs: data.lastMessageDurationMs.present
          ? data.lastMessageDurationMs.value
          : this.lastMessageDurationMs,
      otherUserId: data.otherUserId.present
          ? data.otherUserId.value
          : this.otherUserId,
      roleBadgesJson: data.roleBadgesJson.present
          ? data.roleBadgesJson.value
          : this.roleBadgesJson,
      section: data.section.present ? data.section.value : this.section,
      sectionOrder: data.sectionOrder.present
          ? data.sectionOrder.value
          : this.sectionOrder,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatThreadEntry(')
          ..write('ownerCacheKey: $ownerCacheKey, ')
          ..write('threadId: $threadId, ')
          ..write('threadType: $threadType, ')
          ..write('title: $title, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('learningLanguage: $learningLanguage, ')
          ..write('learningLanguageDisplay: $learningLanguageDisplay, ')
          ..write('nativeLanguage: $nativeLanguage, ')
          ..write('nativeLanguageDisplay: $nativeLanguageDisplay, ')
          ..write('isMuted: $isMuted, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('lastMessageAtMillis: $lastMessageAtMillis, ')
          ..write('lastMessageDurationMs: $lastMessageDurationMs, ')
          ..write('otherUserId: $otherUserId, ')
          ..write('roleBadgesJson: $roleBadgesJson, ')
          ..write('section: $section, ')
          ..write('sectionOrder: $sectionOrder, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerCacheKey,
    threadId,
    threadType,
    title,
    avatarUrl,
    learningLanguage,
    learningLanguageDisplay,
    nativeLanguage,
    nativeLanguageDisplay,
    isMuted,
    unreadCount,
    lastMessageAtMillis,
    lastMessageDurationMs,
    otherUserId,
    roleBadgesJson,
    section,
    sectionOrder,
    updatedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatThreadEntry &&
          other.ownerCacheKey == this.ownerCacheKey &&
          other.threadId == this.threadId &&
          other.threadType == this.threadType &&
          other.title == this.title &&
          other.avatarUrl == this.avatarUrl &&
          other.learningLanguage == this.learningLanguage &&
          other.learningLanguageDisplay == this.learningLanguageDisplay &&
          other.nativeLanguage == this.nativeLanguage &&
          other.nativeLanguageDisplay == this.nativeLanguageDisplay &&
          other.isMuted == this.isMuted &&
          other.unreadCount == this.unreadCount &&
          other.lastMessageAtMillis == this.lastMessageAtMillis &&
          other.lastMessageDurationMs == this.lastMessageDurationMs &&
          other.otherUserId == this.otherUserId &&
          other.roleBadgesJson == this.roleBadgesJson &&
          other.section == this.section &&
          other.sectionOrder == this.sectionOrder &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class ChatThreadEntriesCompanion extends UpdateCompanion<ChatThreadEntry> {
  final Value<String> ownerCacheKey;
  final Value<String> threadId;
  final Value<String> threadType;
  final Value<String> title;
  final Value<String?> avatarUrl;
  final Value<String?> learningLanguage;
  final Value<String?> learningLanguageDisplay;
  final Value<String?> nativeLanguage;
  final Value<String?> nativeLanguageDisplay;
  final Value<bool> isMuted;
  final Value<int> unreadCount;
  final Value<int?> lastMessageAtMillis;
  final Value<int?> lastMessageDurationMs;
  final Value<String?> otherUserId;
  final Value<String> roleBadgesJson;
  final Value<String> section;
  final Value<int> sectionOrder;
  final Value<int> updatedAtMillis;
  final Value<int> rowid;
  const ChatThreadEntriesCompanion({
    this.ownerCacheKey = const Value.absent(),
    this.threadId = const Value.absent(),
    this.threadType = const Value.absent(),
    this.title = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.learningLanguage = const Value.absent(),
    this.learningLanguageDisplay = const Value.absent(),
    this.nativeLanguage = const Value.absent(),
    this.nativeLanguageDisplay = const Value.absent(),
    this.isMuted = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.lastMessageAtMillis = const Value.absent(),
    this.lastMessageDurationMs = const Value.absent(),
    this.otherUserId = const Value.absent(),
    this.roleBadgesJson = const Value.absent(),
    this.section = const Value.absent(),
    this.sectionOrder = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatThreadEntriesCompanion.insert({
    required String ownerCacheKey,
    required String threadId,
    required String threadType,
    required String title,
    this.avatarUrl = const Value.absent(),
    this.learningLanguage = const Value.absent(),
    this.learningLanguageDisplay = const Value.absent(),
    this.nativeLanguage = const Value.absent(),
    this.nativeLanguageDisplay = const Value.absent(),
    this.isMuted = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.lastMessageAtMillis = const Value.absent(),
    this.lastMessageDurationMs = const Value.absent(),
    this.otherUserId = const Value.absent(),
    this.roleBadgesJson = const Value.absent(),
    required String section,
    this.sectionOrder = const Value.absent(),
    required int updatedAtMillis,
    this.rowid = const Value.absent(),
  }) : ownerCacheKey = Value(ownerCacheKey),
       threadId = Value(threadId),
       threadType = Value(threadType),
       title = Value(title),
       section = Value(section),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<ChatThreadEntry> custom({
    Expression<String>? ownerCacheKey,
    Expression<String>? threadId,
    Expression<String>? threadType,
    Expression<String>? title,
    Expression<String>? avatarUrl,
    Expression<String>? learningLanguage,
    Expression<String>? learningLanguageDisplay,
    Expression<String>? nativeLanguage,
    Expression<String>? nativeLanguageDisplay,
    Expression<bool>? isMuted,
    Expression<int>? unreadCount,
    Expression<int>? lastMessageAtMillis,
    Expression<int>? lastMessageDurationMs,
    Expression<String>? otherUserId,
    Expression<String>? roleBadgesJson,
    Expression<String>? section,
    Expression<int>? sectionOrder,
    Expression<int>? updatedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerCacheKey != null) 'owner_cache_key': ownerCacheKey,
      if (threadId != null) 'thread_id': threadId,
      if (threadType != null) 'thread_type': threadType,
      if (title != null) 'title': title,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (learningLanguage != null) 'learning_language': learningLanguage,
      if (learningLanguageDisplay != null)
        'learning_language_display': learningLanguageDisplay,
      if (nativeLanguage != null) 'native_language': nativeLanguage,
      if (nativeLanguageDisplay != null)
        'native_language_display': nativeLanguageDisplay,
      if (isMuted != null) 'is_muted': isMuted,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (lastMessageAtMillis != null)
        'last_message_at_millis': lastMessageAtMillis,
      if (lastMessageDurationMs != null)
        'last_message_duration_ms': lastMessageDurationMs,
      if (otherUserId != null) 'other_user_id': otherUserId,
      if (roleBadgesJson != null) 'role_badges_json': roleBadgesJson,
      if (section != null) 'section': section,
      if (sectionOrder != null) 'section_order': sectionOrder,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatThreadEntriesCompanion copyWith({
    Value<String>? ownerCacheKey,
    Value<String>? threadId,
    Value<String>? threadType,
    Value<String>? title,
    Value<String?>? avatarUrl,
    Value<String?>? learningLanguage,
    Value<String?>? learningLanguageDisplay,
    Value<String?>? nativeLanguage,
    Value<String?>? nativeLanguageDisplay,
    Value<bool>? isMuted,
    Value<int>? unreadCount,
    Value<int?>? lastMessageAtMillis,
    Value<int?>? lastMessageDurationMs,
    Value<String?>? otherUserId,
    Value<String>? roleBadgesJson,
    Value<String>? section,
    Value<int>? sectionOrder,
    Value<int>? updatedAtMillis,
    Value<int>? rowid,
  }) {
    return ChatThreadEntriesCompanion(
      ownerCacheKey: ownerCacheKey ?? this.ownerCacheKey,
      threadId: threadId ?? this.threadId,
      threadType: threadType ?? this.threadType,
      title: title ?? this.title,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      learningLanguage: learningLanguage ?? this.learningLanguage,
      learningLanguageDisplay:
          learningLanguageDisplay ?? this.learningLanguageDisplay,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      nativeLanguageDisplay:
          nativeLanguageDisplay ?? this.nativeLanguageDisplay,
      isMuted: isMuted ?? this.isMuted,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageAtMillis: lastMessageAtMillis ?? this.lastMessageAtMillis,
      lastMessageDurationMs:
          lastMessageDurationMs ?? this.lastMessageDurationMs,
      otherUserId: otherUserId ?? this.otherUserId,
      roleBadgesJson: roleBadgesJson ?? this.roleBadgesJson,
      section: section ?? this.section,
      sectionOrder: sectionOrder ?? this.sectionOrder,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerCacheKey.present) {
      map['owner_cache_key'] = Variable<String>(ownerCacheKey.value);
    }
    if (threadId.present) {
      map['thread_id'] = Variable<String>(threadId.value);
    }
    if (threadType.present) {
      map['thread_type'] = Variable<String>(threadType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (learningLanguage.present) {
      map['learning_language'] = Variable<String>(learningLanguage.value);
    }
    if (learningLanguageDisplay.present) {
      map['learning_language_display'] = Variable<String>(
        learningLanguageDisplay.value,
      );
    }
    if (nativeLanguage.present) {
      map['native_language'] = Variable<String>(nativeLanguage.value);
    }
    if (nativeLanguageDisplay.present) {
      map['native_language_display'] = Variable<String>(
        nativeLanguageDisplay.value,
      );
    }
    if (isMuted.present) {
      map['is_muted'] = Variable<bool>(isMuted.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (lastMessageAtMillis.present) {
      map['last_message_at_millis'] = Variable<int>(lastMessageAtMillis.value);
    }
    if (lastMessageDurationMs.present) {
      map['last_message_duration_ms'] = Variable<int>(
        lastMessageDurationMs.value,
      );
    }
    if (otherUserId.present) {
      map['other_user_id'] = Variable<String>(otherUserId.value);
    }
    if (roleBadgesJson.present) {
      map['role_badges_json'] = Variable<String>(roleBadgesJson.value);
    }
    if (section.present) {
      map['section'] = Variable<String>(section.value);
    }
    if (sectionOrder.present) {
      map['section_order'] = Variable<int>(sectionOrder.value);
    }
    if (updatedAtMillis.present) {
      map['updated_at_millis'] = Variable<int>(updatedAtMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatThreadEntriesCompanion(')
          ..write('ownerCacheKey: $ownerCacheKey, ')
          ..write('threadId: $threadId, ')
          ..write('threadType: $threadType, ')
          ..write('title: $title, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('learningLanguage: $learningLanguage, ')
          ..write('learningLanguageDisplay: $learningLanguageDisplay, ')
          ..write('nativeLanguage: $nativeLanguage, ')
          ..write('nativeLanguageDisplay: $nativeLanguageDisplay, ')
          ..write('isMuted: $isMuted, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('lastMessageAtMillis: $lastMessageAtMillis, ')
          ..write('lastMessageDurationMs: $lastMessageDurationMs, ')
          ..write('otherUserId: $otherUserId, ')
          ..write('roleBadgesJson: $roleBadgesJson, ')
          ..write('section: $section, ')
          ..write('sectionOrder: $sectionOrder, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatUserEntriesTable extends ChatUserEntries
    with TableInfo<$ChatUserEntriesTable, ChatUserEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatUserEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerCacheKeyMeta = const VerificationMeta(
    'ownerCacheKey',
  );
  @override
  late final GeneratedColumn<String> ownerCacheKey = GeneratedColumn<String>(
    'owner_cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _learningLanguageMeta = const VerificationMeta(
    'learningLanguage',
  );
  @override
  late final GeneratedColumn<String> learningLanguage = GeneratedColumn<String>(
    'learning_language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _learningLanguageDisplayMeta =
      const VerificationMeta('learningLanguageDisplay');
  @override
  late final GeneratedColumn<String> learningLanguageDisplay =
      GeneratedColumn<String>(
        'learning_language_display',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nativeLanguageMeta = const VerificationMeta(
    'nativeLanguage',
  );
  @override
  late final GeneratedColumn<String> nativeLanguage = GeneratedColumn<String>(
    'native_language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nativeLanguageDisplayMeta =
      const VerificationMeta('nativeLanguageDisplay');
  @override
  late final GeneratedColumn<String> nativeLanguageDisplay =
      GeneratedColumn<String>(
        'native_language_display',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isOnlineMeta = const VerificationMeta(
    'isOnline',
  );
  @override
  late final GeneratedColumn<bool> isOnline = GeneratedColumn<bool>(
    'is_online',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_online" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMillisMeta = const VerificationMeta(
    'updatedAtMillis',
  );
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
    'updated_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerCacheKey,
    userId,
    name,
    avatarUrl,
    learningLanguage,
    learningLanguageDisplay,
    nativeLanguage,
    nativeLanguageDisplay,
    isOnline,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_user_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatUserEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_cache_key')) {
      context.handle(
        _ownerCacheKeyMeta,
        ownerCacheKey.isAcceptableOrUnknown(
          data['owner_cache_key']!,
          _ownerCacheKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerCacheKeyMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('learning_language')) {
      context.handle(
        _learningLanguageMeta,
        learningLanguage.isAcceptableOrUnknown(
          data['learning_language']!,
          _learningLanguageMeta,
        ),
      );
    }
    if (data.containsKey('learning_language_display')) {
      context.handle(
        _learningLanguageDisplayMeta,
        learningLanguageDisplay.isAcceptableOrUnknown(
          data['learning_language_display']!,
          _learningLanguageDisplayMeta,
        ),
      );
    }
    if (data.containsKey('native_language')) {
      context.handle(
        _nativeLanguageMeta,
        nativeLanguage.isAcceptableOrUnknown(
          data['native_language']!,
          _nativeLanguageMeta,
        ),
      );
    }
    if (data.containsKey('native_language_display')) {
      context.handle(
        _nativeLanguageDisplayMeta,
        nativeLanguageDisplay.isAcceptableOrUnknown(
          data['native_language_display']!,
          _nativeLanguageDisplayMeta,
        ),
      );
    }
    if (data.containsKey('is_online')) {
      context.handle(
        _isOnlineMeta,
        isOnline.isAcceptableOrUnknown(data['is_online']!, _isOnlineMeta),
      );
    }
    if (data.containsKey('updated_at_millis')) {
      context.handle(
        _updatedAtMillisMeta,
        updatedAtMillis.isAcceptableOrUnknown(
          data['updated_at_millis']!,
          _updatedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerCacheKey, userId};
  @override
  ChatUserEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatUserEntry(
      ownerCacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_cache_key'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      learningLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_language'],
      ),
      learningLanguageDisplay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_language_display'],
      ),
      nativeLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}native_language'],
      ),
      nativeLanguageDisplay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}native_language_display'],
      ),
      isOnline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_online'],
      )!,
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_millis'],
      )!,
    );
  }

  @override
  $ChatUserEntriesTable createAlias(String alias) {
    return $ChatUserEntriesTable(attachedDatabase, alias);
  }
}

class ChatUserEntry extends DataClass implements Insertable<ChatUserEntry> {
  final String ownerCacheKey;
  final String userId;
  final String name;
  final String? avatarUrl;
  final String? learningLanguage;
  final String? learningLanguageDisplay;
  final String? nativeLanguage;
  final String? nativeLanguageDisplay;
  final bool isOnline;
  final int updatedAtMillis;
  const ChatUserEntry({
    required this.ownerCacheKey,
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.learningLanguage,
    this.learningLanguageDisplay,
    this.nativeLanguage,
    this.nativeLanguageDisplay,
    required this.isOnline,
    required this.updatedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_cache_key'] = Variable<String>(ownerCacheKey);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || learningLanguage != null) {
      map['learning_language'] = Variable<String>(learningLanguage);
    }
    if (!nullToAbsent || learningLanguageDisplay != null) {
      map['learning_language_display'] = Variable<String>(
        learningLanguageDisplay,
      );
    }
    if (!nullToAbsent || nativeLanguage != null) {
      map['native_language'] = Variable<String>(nativeLanguage);
    }
    if (!nullToAbsent || nativeLanguageDisplay != null) {
      map['native_language_display'] = Variable<String>(nativeLanguageDisplay);
    }
    map['is_online'] = Variable<bool>(isOnline);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  ChatUserEntriesCompanion toCompanion(bool nullToAbsent) {
    return ChatUserEntriesCompanion(
      ownerCacheKey: Value(ownerCacheKey),
      userId: Value(userId),
      name: Value(name),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      learningLanguage: learningLanguage == null && nullToAbsent
          ? const Value.absent()
          : Value(learningLanguage),
      learningLanguageDisplay: learningLanguageDisplay == null && nullToAbsent
          ? const Value.absent()
          : Value(learningLanguageDisplay),
      nativeLanguage: nativeLanguage == null && nullToAbsent
          ? const Value.absent()
          : Value(nativeLanguage),
      nativeLanguageDisplay: nativeLanguageDisplay == null && nullToAbsent
          ? const Value.absent()
          : Value(nativeLanguageDisplay),
      isOnline: Value(isOnline),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory ChatUserEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatUserEntry(
      ownerCacheKey: serializer.fromJson<String>(json['ownerCacheKey']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      learningLanguage: serializer.fromJson<String?>(json['learningLanguage']),
      learningLanguageDisplay: serializer.fromJson<String?>(
        json['learningLanguageDisplay'],
      ),
      nativeLanguage: serializer.fromJson<String?>(json['nativeLanguage']),
      nativeLanguageDisplay: serializer.fromJson<String?>(
        json['nativeLanguageDisplay'],
      ),
      isOnline: serializer.fromJson<bool>(json['isOnline']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerCacheKey': serializer.toJson<String>(ownerCacheKey),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'learningLanguage': serializer.toJson<String?>(learningLanguage),
      'learningLanguageDisplay': serializer.toJson<String?>(
        learningLanguageDisplay,
      ),
      'nativeLanguage': serializer.toJson<String?>(nativeLanguage),
      'nativeLanguageDisplay': serializer.toJson<String?>(
        nativeLanguageDisplay,
      ),
      'isOnline': serializer.toJson<bool>(isOnline),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  ChatUserEntry copyWith({
    String? ownerCacheKey,
    String? userId,
    String? name,
    Value<String?> avatarUrl = const Value.absent(),
    Value<String?> learningLanguage = const Value.absent(),
    Value<String?> learningLanguageDisplay = const Value.absent(),
    Value<String?> nativeLanguage = const Value.absent(),
    Value<String?> nativeLanguageDisplay = const Value.absent(),
    bool? isOnline,
    int? updatedAtMillis,
  }) => ChatUserEntry(
    ownerCacheKey: ownerCacheKey ?? this.ownerCacheKey,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    learningLanguage: learningLanguage.present
        ? learningLanguage.value
        : this.learningLanguage,
    learningLanguageDisplay: learningLanguageDisplay.present
        ? learningLanguageDisplay.value
        : this.learningLanguageDisplay,
    nativeLanguage: nativeLanguage.present
        ? nativeLanguage.value
        : this.nativeLanguage,
    nativeLanguageDisplay: nativeLanguageDisplay.present
        ? nativeLanguageDisplay.value
        : this.nativeLanguageDisplay,
    isOnline: isOnline ?? this.isOnline,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  ChatUserEntry copyWithCompanion(ChatUserEntriesCompanion data) {
    return ChatUserEntry(
      ownerCacheKey: data.ownerCacheKey.present
          ? data.ownerCacheKey.value
          : this.ownerCacheKey,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      learningLanguage: data.learningLanguage.present
          ? data.learningLanguage.value
          : this.learningLanguage,
      learningLanguageDisplay: data.learningLanguageDisplay.present
          ? data.learningLanguageDisplay.value
          : this.learningLanguageDisplay,
      nativeLanguage: data.nativeLanguage.present
          ? data.nativeLanguage.value
          : this.nativeLanguage,
      nativeLanguageDisplay: data.nativeLanguageDisplay.present
          ? data.nativeLanguageDisplay.value
          : this.nativeLanguageDisplay,
      isOnline: data.isOnline.present ? data.isOnline.value : this.isOnline,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatUserEntry(')
          ..write('ownerCacheKey: $ownerCacheKey, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('learningLanguage: $learningLanguage, ')
          ..write('learningLanguageDisplay: $learningLanguageDisplay, ')
          ..write('nativeLanguage: $nativeLanguage, ')
          ..write('nativeLanguageDisplay: $nativeLanguageDisplay, ')
          ..write('isOnline: $isOnline, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerCacheKey,
    userId,
    name,
    avatarUrl,
    learningLanguage,
    learningLanguageDisplay,
    nativeLanguage,
    nativeLanguageDisplay,
    isOnline,
    updatedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatUserEntry &&
          other.ownerCacheKey == this.ownerCacheKey &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.avatarUrl == this.avatarUrl &&
          other.learningLanguage == this.learningLanguage &&
          other.learningLanguageDisplay == this.learningLanguageDisplay &&
          other.nativeLanguage == this.nativeLanguage &&
          other.nativeLanguageDisplay == this.nativeLanguageDisplay &&
          other.isOnline == this.isOnline &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class ChatUserEntriesCompanion extends UpdateCompanion<ChatUserEntry> {
  final Value<String> ownerCacheKey;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> avatarUrl;
  final Value<String?> learningLanguage;
  final Value<String?> learningLanguageDisplay;
  final Value<String?> nativeLanguage;
  final Value<String?> nativeLanguageDisplay;
  final Value<bool> isOnline;
  final Value<int> updatedAtMillis;
  final Value<int> rowid;
  const ChatUserEntriesCompanion({
    this.ownerCacheKey = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.learningLanguage = const Value.absent(),
    this.learningLanguageDisplay = const Value.absent(),
    this.nativeLanguage = const Value.absent(),
    this.nativeLanguageDisplay = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatUserEntriesCompanion.insert({
    required String ownerCacheKey,
    required String userId,
    required String name,
    this.avatarUrl = const Value.absent(),
    this.learningLanguage = const Value.absent(),
    this.learningLanguageDisplay = const Value.absent(),
    this.nativeLanguage = const Value.absent(),
    this.nativeLanguageDisplay = const Value.absent(),
    this.isOnline = const Value.absent(),
    required int updatedAtMillis,
    this.rowid = const Value.absent(),
  }) : ownerCacheKey = Value(ownerCacheKey),
       userId = Value(userId),
       name = Value(name),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<ChatUserEntry> custom({
    Expression<String>? ownerCacheKey,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? avatarUrl,
    Expression<String>? learningLanguage,
    Expression<String>? learningLanguageDisplay,
    Expression<String>? nativeLanguage,
    Expression<String>? nativeLanguageDisplay,
    Expression<bool>? isOnline,
    Expression<int>? updatedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerCacheKey != null) 'owner_cache_key': ownerCacheKey,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (learningLanguage != null) 'learning_language': learningLanguage,
      if (learningLanguageDisplay != null)
        'learning_language_display': learningLanguageDisplay,
      if (nativeLanguage != null) 'native_language': nativeLanguage,
      if (nativeLanguageDisplay != null)
        'native_language_display': nativeLanguageDisplay,
      if (isOnline != null) 'is_online': isOnline,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatUserEntriesCompanion copyWith({
    Value<String>? ownerCacheKey,
    Value<String>? userId,
    Value<String>? name,
    Value<String?>? avatarUrl,
    Value<String?>? learningLanguage,
    Value<String?>? learningLanguageDisplay,
    Value<String?>? nativeLanguage,
    Value<String?>? nativeLanguageDisplay,
    Value<bool>? isOnline,
    Value<int>? updatedAtMillis,
    Value<int>? rowid,
  }) {
    return ChatUserEntriesCompanion(
      ownerCacheKey: ownerCacheKey ?? this.ownerCacheKey,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      learningLanguage: learningLanguage ?? this.learningLanguage,
      learningLanguageDisplay:
          learningLanguageDisplay ?? this.learningLanguageDisplay,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      nativeLanguageDisplay:
          nativeLanguageDisplay ?? this.nativeLanguageDisplay,
      isOnline: isOnline ?? this.isOnline,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerCacheKey.present) {
      map['owner_cache_key'] = Variable<String>(ownerCacheKey.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (learningLanguage.present) {
      map['learning_language'] = Variable<String>(learningLanguage.value);
    }
    if (learningLanguageDisplay.present) {
      map['learning_language_display'] = Variable<String>(
        learningLanguageDisplay.value,
      );
    }
    if (nativeLanguage.present) {
      map['native_language'] = Variable<String>(nativeLanguage.value);
    }
    if (nativeLanguageDisplay.present) {
      map['native_language_display'] = Variable<String>(
        nativeLanguageDisplay.value,
      );
    }
    if (isOnline.present) {
      map['is_online'] = Variable<bool>(isOnline.value);
    }
    if (updatedAtMillis.present) {
      map['updated_at_millis'] = Variable<int>(updatedAtMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatUserEntriesCompanion(')
          ..write('ownerCacheKey: $ownerCacheKey, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('learningLanguage: $learningLanguage, ')
          ..write('learningLanguageDisplay: $learningLanguageDisplay, ')
          ..write('nativeLanguage: $nativeLanguage, ')
          ..write('nativeLanguageDisplay: $nativeLanguageDisplay, ')
          ..write('isOnline: $isOnline, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessageEntriesTable extends ChatMessageEntries
    with TableInfo<$ChatMessageEntriesTable, ChatMessageEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessageEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerCacheKeyMeta = const VerificationMeta(
    'ownerCacheKey',
  );
  @override
  late final GeneratedColumn<String> ownerCacheKey = GeneratedColumn<String>(
    'owner_cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _threadIdMeta = const VerificationMeta(
    'threadId',
  );
  @override
  late final GeneratedColumn<String> threadId = GeneratedColumn<String>(
    'thread_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _threadTypeMeta = const VerificationMeta(
    'threadType',
  );
  @override
  late final GeneratedColumn<String> threadType = GeneratedColumn<String>(
    'thread_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderUserIdMeta = const VerificationMeta(
    'senderUserId',
  );
  @override
  late final GeneratedColumn<String> senderUserId = GeneratedColumn<String>(
    'sender_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderNameMeta = const VerificationMeta(
    'senderName',
  );
  @override
  late final GeneratedColumn<String> senderName = GeneratedColumn<String>(
    'sender_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderAvatarUrlMeta = const VerificationMeta(
    'senderAvatarUrl',
  );
  @override
  late final GeneratedColumn<String> senderAvatarUrl = GeneratedColumn<String>(
    'sender_avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _senderLearningLanguageMeta =
      const VerificationMeta('senderLearningLanguage');
  @override
  late final GeneratedColumn<String> senderLearningLanguage =
      GeneratedColumn<String>(
        'sender_learning_language',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _senderLearningLanguageDisplayMeta =
      const VerificationMeta('senderLearningLanguageDisplay');
  @override
  late final GeneratedColumn<String> senderLearningLanguageDisplay =
      GeneratedColumn<String>(
        'sender_learning_language_display',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _senderNativeLanguageMeta =
      const VerificationMeta('senderNativeLanguage');
  @override
  late final GeneratedColumn<String> senderNativeLanguage =
      GeneratedColumn<String>(
        'sender_native_language',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _senderNativeLanguageDisplayMeta =
      const VerificationMeta('senderNativeLanguageDisplay');
  @override
  late final GeneratedColumn<String> senderNativeLanguageDisplay =
      GeneratedColumn<String>(
        'sender_native_language_display',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _senderIsOnlineMeta = const VerificationMeta(
    'senderIsOnline',
  );
  @override
  late final GeneratedColumn<bool> senderIsOnline = GeneratedColumn<bool>(
    'sender_is_online',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sender_is_online" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _spokenLanguageCodeMeta =
      const VerificationMeta('spokenLanguageCode');
  @override
  late final GeneratedColumn<String> spokenLanguageCode =
      GeneratedColumn<String>(
        'spoken_language_code',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMillisMeta = const VerificationMeta(
    'createdAtMillis',
  );
  @override
  late final GeneratedColumn<int> createdAtMillis = GeneratedColumn<int>(
    'created_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMillisMeta = const VerificationMeta(
    'expiresAtMillis',
  );
  @override
  late final GeneratedColumn<int> expiresAtMillis = GeneratedColumn<int>(
    'expires_at_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isMineMeta = const VerificationMeta('isMine');
  @override
  late final GeneratedColumn<bool> isMine = GeneratedColumn<bool>(
    'is_mine',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_mine" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _audioUrlMeta = const VerificationMeta(
    'audioUrl',
  );
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
    'audio_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localAudioPathMeta = const VerificationMeta(
    'localAudioPath',
  );
  @override
  late final GeneratedColumn<String> localAudioPath = GeneratedColumn<String>(
    'local_audio_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localTranscriptTextMeta =
      const VerificationMeta('localTranscriptText');
  @override
  late final GeneratedColumn<String> localTranscriptText =
      GeneratedColumn<String>(
        'local_transcript_text',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _localTranscriptStatusMeta =
      const VerificationMeta('localTranscriptStatus');
  @override
  late final GeneratedColumn<String> localTranscriptStatus =
      GeneratedColumn<String>(
        'local_transcript_status',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _localTranscriptLanguageMeta =
      const VerificationMeta('localTranscriptLanguage');
  @override
  late final GeneratedColumn<String> localTranscriptLanguage =
      GeneratedColumn<String>(
        'local_transcript_language',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _localTranscriptLanguageCodeMeta =
      const VerificationMeta('localTranscriptLanguageCode');
  @override
  late final GeneratedColumn<String> localTranscriptLanguageCode =
      GeneratedColumn<String>(
        'local_transcript_language_code',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isServerVisibleMeta = const VerificationMeta(
    'isServerVisible',
  );
  @override
  late final GeneratedColumn<bool> isServerVisible = GeneratedColumn<bool>(
    'is_server_visible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_server_visible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMillisMeta = const VerificationMeta(
    'updatedAtMillis',
  );
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
    'updated_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerCacheKey,
    messageId,
    threadId,
    threadType,
    senderUserId,
    senderName,
    senderAvatarUrl,
    senderLearningLanguage,
    senderLearningLanguageDisplay,
    senderNativeLanguage,
    senderNativeLanguageDisplay,
    senderIsOnline,
    spokenLanguageCode,
    durationMs,
    createdAtMillis,
    expiresAtMillis,
    isMine,
    audioUrl,
    localAudioPath,
    localTranscriptText,
    localTranscriptStatus,
    localTranscriptLanguage,
    localTranscriptLanguageCode,
    isServerVisible,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_message_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessageEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_cache_key')) {
      context.handle(
        _ownerCacheKeyMeta,
        ownerCacheKey.isAcceptableOrUnknown(
          data['owner_cache_key']!,
          _ownerCacheKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerCacheKeyMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('thread_id')) {
      context.handle(
        _threadIdMeta,
        threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('thread_type')) {
      context.handle(
        _threadTypeMeta,
        threadType.isAcceptableOrUnknown(data['thread_type']!, _threadTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_threadTypeMeta);
    }
    if (data.containsKey('sender_user_id')) {
      context.handle(
        _senderUserIdMeta,
        senderUserId.isAcceptableOrUnknown(
          data['sender_user_id']!,
          _senderUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_senderUserIdMeta);
    }
    if (data.containsKey('sender_name')) {
      context.handle(
        _senderNameMeta,
        senderName.isAcceptableOrUnknown(data['sender_name']!, _senderNameMeta),
      );
    } else if (isInserting) {
      context.missing(_senderNameMeta);
    }
    if (data.containsKey('sender_avatar_url')) {
      context.handle(
        _senderAvatarUrlMeta,
        senderAvatarUrl.isAcceptableOrUnknown(
          data['sender_avatar_url']!,
          _senderAvatarUrlMeta,
        ),
      );
    }
    if (data.containsKey('sender_learning_language')) {
      context.handle(
        _senderLearningLanguageMeta,
        senderLearningLanguage.isAcceptableOrUnknown(
          data['sender_learning_language']!,
          _senderLearningLanguageMeta,
        ),
      );
    }
    if (data.containsKey('sender_learning_language_display')) {
      context.handle(
        _senderLearningLanguageDisplayMeta,
        senderLearningLanguageDisplay.isAcceptableOrUnknown(
          data['sender_learning_language_display']!,
          _senderLearningLanguageDisplayMeta,
        ),
      );
    }
    if (data.containsKey('sender_native_language')) {
      context.handle(
        _senderNativeLanguageMeta,
        senderNativeLanguage.isAcceptableOrUnknown(
          data['sender_native_language']!,
          _senderNativeLanguageMeta,
        ),
      );
    }
    if (data.containsKey('sender_native_language_display')) {
      context.handle(
        _senderNativeLanguageDisplayMeta,
        senderNativeLanguageDisplay.isAcceptableOrUnknown(
          data['sender_native_language_display']!,
          _senderNativeLanguageDisplayMeta,
        ),
      );
    }
    if (data.containsKey('sender_is_online')) {
      context.handle(
        _senderIsOnlineMeta,
        senderIsOnline.isAcceptableOrUnknown(
          data['sender_is_online']!,
          _senderIsOnlineMeta,
        ),
      );
    }
    if (data.containsKey('spoken_language_code')) {
      context.handle(
        _spokenLanguageCodeMeta,
        spokenLanguageCode.isAcceptableOrUnknown(
          data['spoken_language_code']!,
          _spokenLanguageCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_spokenLanguageCodeMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('created_at_millis')) {
      context.handle(
        _createdAtMillisMeta,
        createdAtMillis.isAcceptableOrUnknown(
          data['created_at_millis']!,
          _createdAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMillisMeta);
    }
    if (data.containsKey('expires_at_millis')) {
      context.handle(
        _expiresAtMillisMeta,
        expiresAtMillis.isAcceptableOrUnknown(
          data['expires_at_millis']!,
          _expiresAtMillisMeta,
        ),
      );
    }
    if (data.containsKey('is_mine')) {
      context.handle(
        _isMineMeta,
        isMine.isAcceptableOrUnknown(data['is_mine']!, _isMineMeta),
      );
    }
    if (data.containsKey('audio_url')) {
      context.handle(
        _audioUrlMeta,
        audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_audioUrlMeta);
    }
    if (data.containsKey('local_audio_path')) {
      context.handle(
        _localAudioPathMeta,
        localAudioPath.isAcceptableOrUnknown(
          data['local_audio_path']!,
          _localAudioPathMeta,
        ),
      );
    }
    if (data.containsKey('local_transcript_text')) {
      context.handle(
        _localTranscriptTextMeta,
        localTranscriptText.isAcceptableOrUnknown(
          data['local_transcript_text']!,
          _localTranscriptTextMeta,
        ),
      );
    }
    if (data.containsKey('local_transcript_status')) {
      context.handle(
        _localTranscriptStatusMeta,
        localTranscriptStatus.isAcceptableOrUnknown(
          data['local_transcript_status']!,
          _localTranscriptStatusMeta,
        ),
      );
    }
    if (data.containsKey('local_transcript_language')) {
      context.handle(
        _localTranscriptLanguageMeta,
        localTranscriptLanguage.isAcceptableOrUnknown(
          data['local_transcript_language']!,
          _localTranscriptLanguageMeta,
        ),
      );
    }
    if (data.containsKey('local_transcript_language_code')) {
      context.handle(
        _localTranscriptLanguageCodeMeta,
        localTranscriptLanguageCode.isAcceptableOrUnknown(
          data['local_transcript_language_code']!,
          _localTranscriptLanguageCodeMeta,
        ),
      );
    }
    if (data.containsKey('is_server_visible')) {
      context.handle(
        _isServerVisibleMeta,
        isServerVisible.isAcceptableOrUnknown(
          data['is_server_visible']!,
          _isServerVisibleMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_millis')) {
      context.handle(
        _updatedAtMillisMeta,
        updatedAtMillis.isAcceptableOrUnknown(
          data['updated_at_millis']!,
          _updatedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerCacheKey, messageId};
  @override
  ChatMessageEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessageEntry(
      ownerCacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_cache_key'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      threadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thread_id'],
      )!,
      threadType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thread_type'],
      )!,
      senderUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_user_id'],
      )!,
      senderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_name'],
      )!,
      senderAvatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_avatar_url'],
      ),
      senderLearningLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_learning_language'],
      ),
      senderLearningLanguageDisplay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_learning_language_display'],
      ),
      senderNativeLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_native_language'],
      ),
      senderNativeLanguageDisplay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_native_language_display'],
      ),
      senderIsOnline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sender_is_online'],
      )!,
      spokenLanguageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spoken_language_code'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      createdAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_millis'],
      )!,
      expiresAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expires_at_millis'],
      ),
      isMine: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_mine'],
      )!,
      audioUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_url'],
      )!,
      localAudioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_audio_path'],
      ),
      localTranscriptText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_transcript_text'],
      ),
      localTranscriptStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_transcript_status'],
      ),
      localTranscriptLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_transcript_language'],
      ),
      localTranscriptLanguageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_transcript_language_code'],
      ),
      isServerVisible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_server_visible'],
      )!,
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_millis'],
      )!,
    );
  }

  @override
  $ChatMessageEntriesTable createAlias(String alias) {
    return $ChatMessageEntriesTable(attachedDatabase, alias);
  }
}

class ChatMessageEntry extends DataClass
    implements Insertable<ChatMessageEntry> {
  final String ownerCacheKey;
  final String messageId;
  final String threadId;
  final String threadType;
  final String senderUserId;
  final String senderName;
  final String? senderAvatarUrl;
  final String? senderLearningLanguage;
  final String? senderLearningLanguageDisplay;
  final String? senderNativeLanguage;
  final String? senderNativeLanguageDisplay;
  final bool senderIsOnline;
  final String spokenLanguageCode;
  final int durationMs;
  final int createdAtMillis;
  final int? expiresAtMillis;
  final bool isMine;
  final String audioUrl;
  final String? localAudioPath;
  final String? localTranscriptText;
  final String? localTranscriptStatus;
  final String? localTranscriptLanguage;
  final String? localTranscriptLanguageCode;
  final bool isServerVisible;
  final int updatedAtMillis;
  const ChatMessageEntry({
    required this.ownerCacheKey,
    required this.messageId,
    required this.threadId,
    required this.threadType,
    required this.senderUserId,
    required this.senderName,
    this.senderAvatarUrl,
    this.senderLearningLanguage,
    this.senderLearningLanguageDisplay,
    this.senderNativeLanguage,
    this.senderNativeLanguageDisplay,
    required this.senderIsOnline,
    required this.spokenLanguageCode,
    required this.durationMs,
    required this.createdAtMillis,
    this.expiresAtMillis,
    required this.isMine,
    required this.audioUrl,
    this.localAudioPath,
    this.localTranscriptText,
    this.localTranscriptStatus,
    this.localTranscriptLanguage,
    this.localTranscriptLanguageCode,
    required this.isServerVisible,
    required this.updatedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_cache_key'] = Variable<String>(ownerCacheKey);
    map['message_id'] = Variable<String>(messageId);
    map['thread_id'] = Variable<String>(threadId);
    map['thread_type'] = Variable<String>(threadType);
    map['sender_user_id'] = Variable<String>(senderUserId);
    map['sender_name'] = Variable<String>(senderName);
    if (!nullToAbsent || senderAvatarUrl != null) {
      map['sender_avatar_url'] = Variable<String>(senderAvatarUrl);
    }
    if (!nullToAbsent || senderLearningLanguage != null) {
      map['sender_learning_language'] = Variable<String>(
        senderLearningLanguage,
      );
    }
    if (!nullToAbsent || senderLearningLanguageDisplay != null) {
      map['sender_learning_language_display'] = Variable<String>(
        senderLearningLanguageDisplay,
      );
    }
    if (!nullToAbsent || senderNativeLanguage != null) {
      map['sender_native_language'] = Variable<String>(senderNativeLanguage);
    }
    if (!nullToAbsent || senderNativeLanguageDisplay != null) {
      map['sender_native_language_display'] = Variable<String>(
        senderNativeLanguageDisplay,
      );
    }
    map['sender_is_online'] = Variable<bool>(senderIsOnline);
    map['spoken_language_code'] = Variable<String>(spokenLanguageCode);
    map['duration_ms'] = Variable<int>(durationMs);
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    if (!nullToAbsent || expiresAtMillis != null) {
      map['expires_at_millis'] = Variable<int>(expiresAtMillis);
    }
    map['is_mine'] = Variable<bool>(isMine);
    map['audio_url'] = Variable<String>(audioUrl);
    if (!nullToAbsent || localAudioPath != null) {
      map['local_audio_path'] = Variable<String>(localAudioPath);
    }
    if (!nullToAbsent || localTranscriptText != null) {
      map['local_transcript_text'] = Variable<String>(localTranscriptText);
    }
    if (!nullToAbsent || localTranscriptStatus != null) {
      map['local_transcript_status'] = Variable<String>(localTranscriptStatus);
    }
    if (!nullToAbsent || localTranscriptLanguage != null) {
      map['local_transcript_language'] = Variable<String>(
        localTranscriptLanguage,
      );
    }
    if (!nullToAbsent || localTranscriptLanguageCode != null) {
      map['local_transcript_language_code'] = Variable<String>(
        localTranscriptLanguageCode,
      );
    }
    map['is_server_visible'] = Variable<bool>(isServerVisible);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  ChatMessageEntriesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessageEntriesCompanion(
      ownerCacheKey: Value(ownerCacheKey),
      messageId: Value(messageId),
      threadId: Value(threadId),
      threadType: Value(threadType),
      senderUserId: Value(senderUserId),
      senderName: Value(senderName),
      senderAvatarUrl: senderAvatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(senderAvatarUrl),
      senderLearningLanguage: senderLearningLanguage == null && nullToAbsent
          ? const Value.absent()
          : Value(senderLearningLanguage),
      senderLearningLanguageDisplay:
          senderLearningLanguageDisplay == null && nullToAbsent
          ? const Value.absent()
          : Value(senderLearningLanguageDisplay),
      senderNativeLanguage: senderNativeLanguage == null && nullToAbsent
          ? const Value.absent()
          : Value(senderNativeLanguage),
      senderNativeLanguageDisplay:
          senderNativeLanguageDisplay == null && nullToAbsent
          ? const Value.absent()
          : Value(senderNativeLanguageDisplay),
      senderIsOnline: Value(senderIsOnline),
      spokenLanguageCode: Value(spokenLanguageCode),
      durationMs: Value(durationMs),
      createdAtMillis: Value(createdAtMillis),
      expiresAtMillis: expiresAtMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAtMillis),
      isMine: Value(isMine),
      audioUrl: Value(audioUrl),
      localAudioPath: localAudioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localAudioPath),
      localTranscriptText: localTranscriptText == null && nullToAbsent
          ? const Value.absent()
          : Value(localTranscriptText),
      localTranscriptStatus: localTranscriptStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(localTranscriptStatus),
      localTranscriptLanguage: localTranscriptLanguage == null && nullToAbsent
          ? const Value.absent()
          : Value(localTranscriptLanguage),
      localTranscriptLanguageCode:
          localTranscriptLanguageCode == null && nullToAbsent
          ? const Value.absent()
          : Value(localTranscriptLanguageCode),
      isServerVisible: Value(isServerVisible),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory ChatMessageEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessageEntry(
      ownerCacheKey: serializer.fromJson<String>(json['ownerCacheKey']),
      messageId: serializer.fromJson<String>(json['messageId']),
      threadId: serializer.fromJson<String>(json['threadId']),
      threadType: serializer.fromJson<String>(json['threadType']),
      senderUserId: serializer.fromJson<String>(json['senderUserId']),
      senderName: serializer.fromJson<String>(json['senderName']),
      senderAvatarUrl: serializer.fromJson<String?>(json['senderAvatarUrl']),
      senderLearningLanguage: serializer.fromJson<String?>(
        json['senderLearningLanguage'],
      ),
      senderLearningLanguageDisplay: serializer.fromJson<String?>(
        json['senderLearningLanguageDisplay'],
      ),
      senderNativeLanguage: serializer.fromJson<String?>(
        json['senderNativeLanguage'],
      ),
      senderNativeLanguageDisplay: serializer.fromJson<String?>(
        json['senderNativeLanguageDisplay'],
      ),
      senderIsOnline: serializer.fromJson<bool>(json['senderIsOnline']),
      spokenLanguageCode: serializer.fromJson<String>(
        json['spokenLanguageCode'],
      ),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      createdAtMillis: serializer.fromJson<int>(json['createdAtMillis']),
      expiresAtMillis: serializer.fromJson<int?>(json['expiresAtMillis']),
      isMine: serializer.fromJson<bool>(json['isMine']),
      audioUrl: serializer.fromJson<String>(json['audioUrl']),
      localAudioPath: serializer.fromJson<String?>(json['localAudioPath']),
      localTranscriptText: serializer.fromJson<String?>(
        json['localTranscriptText'],
      ),
      localTranscriptStatus: serializer.fromJson<String?>(
        json['localTranscriptStatus'],
      ),
      localTranscriptLanguage: serializer.fromJson<String?>(
        json['localTranscriptLanguage'],
      ),
      localTranscriptLanguageCode: serializer.fromJson<String?>(
        json['localTranscriptLanguageCode'],
      ),
      isServerVisible: serializer.fromJson<bool>(json['isServerVisible']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerCacheKey': serializer.toJson<String>(ownerCacheKey),
      'messageId': serializer.toJson<String>(messageId),
      'threadId': serializer.toJson<String>(threadId),
      'threadType': serializer.toJson<String>(threadType),
      'senderUserId': serializer.toJson<String>(senderUserId),
      'senderName': serializer.toJson<String>(senderName),
      'senderAvatarUrl': serializer.toJson<String?>(senderAvatarUrl),
      'senderLearningLanguage': serializer.toJson<String?>(
        senderLearningLanguage,
      ),
      'senderLearningLanguageDisplay': serializer.toJson<String?>(
        senderLearningLanguageDisplay,
      ),
      'senderNativeLanguage': serializer.toJson<String?>(senderNativeLanguage),
      'senderNativeLanguageDisplay': serializer.toJson<String?>(
        senderNativeLanguageDisplay,
      ),
      'senderIsOnline': serializer.toJson<bool>(senderIsOnline),
      'spokenLanguageCode': serializer.toJson<String>(spokenLanguageCode),
      'durationMs': serializer.toJson<int>(durationMs),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
      'expiresAtMillis': serializer.toJson<int?>(expiresAtMillis),
      'isMine': serializer.toJson<bool>(isMine),
      'audioUrl': serializer.toJson<String>(audioUrl),
      'localAudioPath': serializer.toJson<String?>(localAudioPath),
      'localTranscriptText': serializer.toJson<String?>(localTranscriptText),
      'localTranscriptStatus': serializer.toJson<String?>(
        localTranscriptStatus,
      ),
      'localTranscriptLanguage': serializer.toJson<String?>(
        localTranscriptLanguage,
      ),
      'localTranscriptLanguageCode': serializer.toJson<String?>(
        localTranscriptLanguageCode,
      ),
      'isServerVisible': serializer.toJson<bool>(isServerVisible),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  ChatMessageEntry copyWith({
    String? ownerCacheKey,
    String? messageId,
    String? threadId,
    String? threadType,
    String? senderUserId,
    String? senderName,
    Value<String?> senderAvatarUrl = const Value.absent(),
    Value<String?> senderLearningLanguage = const Value.absent(),
    Value<String?> senderLearningLanguageDisplay = const Value.absent(),
    Value<String?> senderNativeLanguage = const Value.absent(),
    Value<String?> senderNativeLanguageDisplay = const Value.absent(),
    bool? senderIsOnline,
    String? spokenLanguageCode,
    int? durationMs,
    int? createdAtMillis,
    Value<int?> expiresAtMillis = const Value.absent(),
    bool? isMine,
    String? audioUrl,
    Value<String?> localAudioPath = const Value.absent(),
    Value<String?> localTranscriptText = const Value.absent(),
    Value<String?> localTranscriptStatus = const Value.absent(),
    Value<String?> localTranscriptLanguage = const Value.absent(),
    Value<String?> localTranscriptLanguageCode = const Value.absent(),
    bool? isServerVisible,
    int? updatedAtMillis,
  }) => ChatMessageEntry(
    ownerCacheKey: ownerCacheKey ?? this.ownerCacheKey,
    messageId: messageId ?? this.messageId,
    threadId: threadId ?? this.threadId,
    threadType: threadType ?? this.threadType,
    senderUserId: senderUserId ?? this.senderUserId,
    senderName: senderName ?? this.senderName,
    senderAvatarUrl: senderAvatarUrl.present
        ? senderAvatarUrl.value
        : this.senderAvatarUrl,
    senderLearningLanguage: senderLearningLanguage.present
        ? senderLearningLanguage.value
        : this.senderLearningLanguage,
    senderLearningLanguageDisplay: senderLearningLanguageDisplay.present
        ? senderLearningLanguageDisplay.value
        : this.senderLearningLanguageDisplay,
    senderNativeLanguage: senderNativeLanguage.present
        ? senderNativeLanguage.value
        : this.senderNativeLanguage,
    senderNativeLanguageDisplay: senderNativeLanguageDisplay.present
        ? senderNativeLanguageDisplay.value
        : this.senderNativeLanguageDisplay,
    senderIsOnline: senderIsOnline ?? this.senderIsOnline,
    spokenLanguageCode: spokenLanguageCode ?? this.spokenLanguageCode,
    durationMs: durationMs ?? this.durationMs,
    createdAtMillis: createdAtMillis ?? this.createdAtMillis,
    expiresAtMillis: expiresAtMillis.present
        ? expiresAtMillis.value
        : this.expiresAtMillis,
    isMine: isMine ?? this.isMine,
    audioUrl: audioUrl ?? this.audioUrl,
    localAudioPath: localAudioPath.present
        ? localAudioPath.value
        : this.localAudioPath,
    localTranscriptText: localTranscriptText.present
        ? localTranscriptText.value
        : this.localTranscriptText,
    localTranscriptStatus: localTranscriptStatus.present
        ? localTranscriptStatus.value
        : this.localTranscriptStatus,
    localTranscriptLanguage: localTranscriptLanguage.present
        ? localTranscriptLanguage.value
        : this.localTranscriptLanguage,
    localTranscriptLanguageCode: localTranscriptLanguageCode.present
        ? localTranscriptLanguageCode.value
        : this.localTranscriptLanguageCode,
    isServerVisible: isServerVisible ?? this.isServerVisible,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  ChatMessageEntry copyWithCompanion(ChatMessageEntriesCompanion data) {
    return ChatMessageEntry(
      ownerCacheKey: data.ownerCacheKey.present
          ? data.ownerCacheKey.value
          : this.ownerCacheKey,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      threadId: data.threadId.present ? data.threadId.value : this.threadId,
      threadType: data.threadType.present
          ? data.threadType.value
          : this.threadType,
      senderUserId: data.senderUserId.present
          ? data.senderUserId.value
          : this.senderUserId,
      senderName: data.senderName.present
          ? data.senderName.value
          : this.senderName,
      senderAvatarUrl: data.senderAvatarUrl.present
          ? data.senderAvatarUrl.value
          : this.senderAvatarUrl,
      senderLearningLanguage: data.senderLearningLanguage.present
          ? data.senderLearningLanguage.value
          : this.senderLearningLanguage,
      senderLearningLanguageDisplay: data.senderLearningLanguageDisplay.present
          ? data.senderLearningLanguageDisplay.value
          : this.senderLearningLanguageDisplay,
      senderNativeLanguage: data.senderNativeLanguage.present
          ? data.senderNativeLanguage.value
          : this.senderNativeLanguage,
      senderNativeLanguageDisplay: data.senderNativeLanguageDisplay.present
          ? data.senderNativeLanguageDisplay.value
          : this.senderNativeLanguageDisplay,
      senderIsOnline: data.senderIsOnline.present
          ? data.senderIsOnline.value
          : this.senderIsOnline,
      spokenLanguageCode: data.spokenLanguageCode.present
          ? data.spokenLanguageCode.value
          : this.spokenLanguageCode,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      createdAtMillis: data.createdAtMillis.present
          ? data.createdAtMillis.value
          : this.createdAtMillis,
      expiresAtMillis: data.expiresAtMillis.present
          ? data.expiresAtMillis.value
          : this.expiresAtMillis,
      isMine: data.isMine.present ? data.isMine.value : this.isMine,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      localAudioPath: data.localAudioPath.present
          ? data.localAudioPath.value
          : this.localAudioPath,
      localTranscriptText: data.localTranscriptText.present
          ? data.localTranscriptText.value
          : this.localTranscriptText,
      localTranscriptStatus: data.localTranscriptStatus.present
          ? data.localTranscriptStatus.value
          : this.localTranscriptStatus,
      localTranscriptLanguage: data.localTranscriptLanguage.present
          ? data.localTranscriptLanguage.value
          : this.localTranscriptLanguage,
      localTranscriptLanguageCode: data.localTranscriptLanguageCode.present
          ? data.localTranscriptLanguageCode.value
          : this.localTranscriptLanguageCode,
      isServerVisible: data.isServerVisible.present
          ? data.isServerVisible.value
          : this.isServerVisible,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageEntry(')
          ..write('ownerCacheKey: $ownerCacheKey, ')
          ..write('messageId: $messageId, ')
          ..write('threadId: $threadId, ')
          ..write('threadType: $threadType, ')
          ..write('senderUserId: $senderUserId, ')
          ..write('senderName: $senderName, ')
          ..write('senderAvatarUrl: $senderAvatarUrl, ')
          ..write('senderLearningLanguage: $senderLearningLanguage, ')
          ..write(
            'senderLearningLanguageDisplay: $senderLearningLanguageDisplay, ',
          )
          ..write('senderNativeLanguage: $senderNativeLanguage, ')
          ..write('senderNativeLanguageDisplay: $senderNativeLanguageDisplay, ')
          ..write('senderIsOnline: $senderIsOnline, ')
          ..write('spokenLanguageCode: $spokenLanguageCode, ')
          ..write('durationMs: $durationMs, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('expiresAtMillis: $expiresAtMillis, ')
          ..write('isMine: $isMine, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('localAudioPath: $localAudioPath, ')
          ..write('localTranscriptText: $localTranscriptText, ')
          ..write('localTranscriptStatus: $localTranscriptStatus, ')
          ..write('localTranscriptLanguage: $localTranscriptLanguage, ')
          ..write('localTranscriptLanguageCode: $localTranscriptLanguageCode, ')
          ..write('isServerVisible: $isServerVisible, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    ownerCacheKey,
    messageId,
    threadId,
    threadType,
    senderUserId,
    senderName,
    senderAvatarUrl,
    senderLearningLanguage,
    senderLearningLanguageDisplay,
    senderNativeLanguage,
    senderNativeLanguageDisplay,
    senderIsOnline,
    spokenLanguageCode,
    durationMs,
    createdAtMillis,
    expiresAtMillis,
    isMine,
    audioUrl,
    localAudioPath,
    localTranscriptText,
    localTranscriptStatus,
    localTranscriptLanguage,
    localTranscriptLanguageCode,
    isServerVisible,
    updatedAtMillis,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageEntry &&
          other.ownerCacheKey == this.ownerCacheKey &&
          other.messageId == this.messageId &&
          other.threadId == this.threadId &&
          other.threadType == this.threadType &&
          other.senderUserId == this.senderUserId &&
          other.senderName == this.senderName &&
          other.senderAvatarUrl == this.senderAvatarUrl &&
          other.senderLearningLanguage == this.senderLearningLanguage &&
          other.senderLearningLanguageDisplay ==
              this.senderLearningLanguageDisplay &&
          other.senderNativeLanguage == this.senderNativeLanguage &&
          other.senderNativeLanguageDisplay ==
              this.senderNativeLanguageDisplay &&
          other.senderIsOnline == this.senderIsOnline &&
          other.spokenLanguageCode == this.spokenLanguageCode &&
          other.durationMs == this.durationMs &&
          other.createdAtMillis == this.createdAtMillis &&
          other.expiresAtMillis == this.expiresAtMillis &&
          other.isMine == this.isMine &&
          other.audioUrl == this.audioUrl &&
          other.localAudioPath == this.localAudioPath &&
          other.localTranscriptText == this.localTranscriptText &&
          other.localTranscriptStatus == this.localTranscriptStatus &&
          other.localTranscriptLanguage == this.localTranscriptLanguage &&
          other.localTranscriptLanguageCode ==
              this.localTranscriptLanguageCode &&
          other.isServerVisible == this.isServerVisible &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class ChatMessageEntriesCompanion extends UpdateCompanion<ChatMessageEntry> {
  final Value<String> ownerCacheKey;
  final Value<String> messageId;
  final Value<String> threadId;
  final Value<String> threadType;
  final Value<String> senderUserId;
  final Value<String> senderName;
  final Value<String?> senderAvatarUrl;
  final Value<String?> senderLearningLanguage;
  final Value<String?> senderLearningLanguageDisplay;
  final Value<String?> senderNativeLanguage;
  final Value<String?> senderNativeLanguageDisplay;
  final Value<bool> senderIsOnline;
  final Value<String> spokenLanguageCode;
  final Value<int> durationMs;
  final Value<int> createdAtMillis;
  final Value<int?> expiresAtMillis;
  final Value<bool> isMine;
  final Value<String> audioUrl;
  final Value<String?> localAudioPath;
  final Value<String?> localTranscriptText;
  final Value<String?> localTranscriptStatus;
  final Value<String?> localTranscriptLanguage;
  final Value<String?> localTranscriptLanguageCode;
  final Value<bool> isServerVisible;
  final Value<int> updatedAtMillis;
  final Value<int> rowid;
  const ChatMessageEntriesCompanion({
    this.ownerCacheKey = const Value.absent(),
    this.messageId = const Value.absent(),
    this.threadId = const Value.absent(),
    this.threadType = const Value.absent(),
    this.senderUserId = const Value.absent(),
    this.senderName = const Value.absent(),
    this.senderAvatarUrl = const Value.absent(),
    this.senderLearningLanguage = const Value.absent(),
    this.senderLearningLanguageDisplay = const Value.absent(),
    this.senderNativeLanguage = const Value.absent(),
    this.senderNativeLanguageDisplay = const Value.absent(),
    this.senderIsOnline = const Value.absent(),
    this.spokenLanguageCode = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
    this.expiresAtMillis = const Value.absent(),
    this.isMine = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.localAudioPath = const Value.absent(),
    this.localTranscriptText = const Value.absent(),
    this.localTranscriptStatus = const Value.absent(),
    this.localTranscriptLanguage = const Value.absent(),
    this.localTranscriptLanguageCode = const Value.absent(),
    this.isServerVisible = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessageEntriesCompanion.insert({
    required String ownerCacheKey,
    required String messageId,
    required String threadId,
    required String threadType,
    required String senderUserId,
    required String senderName,
    this.senderAvatarUrl = const Value.absent(),
    this.senderLearningLanguage = const Value.absent(),
    this.senderLearningLanguageDisplay = const Value.absent(),
    this.senderNativeLanguage = const Value.absent(),
    this.senderNativeLanguageDisplay = const Value.absent(),
    this.senderIsOnline = const Value.absent(),
    required String spokenLanguageCode,
    required int durationMs,
    required int createdAtMillis,
    this.expiresAtMillis = const Value.absent(),
    this.isMine = const Value.absent(),
    required String audioUrl,
    this.localAudioPath = const Value.absent(),
    this.localTranscriptText = const Value.absent(),
    this.localTranscriptStatus = const Value.absent(),
    this.localTranscriptLanguage = const Value.absent(),
    this.localTranscriptLanguageCode = const Value.absent(),
    this.isServerVisible = const Value.absent(),
    required int updatedAtMillis,
    this.rowid = const Value.absent(),
  }) : ownerCacheKey = Value(ownerCacheKey),
       messageId = Value(messageId),
       threadId = Value(threadId),
       threadType = Value(threadType),
       senderUserId = Value(senderUserId),
       senderName = Value(senderName),
       spokenLanguageCode = Value(spokenLanguageCode),
       durationMs = Value(durationMs),
       createdAtMillis = Value(createdAtMillis),
       audioUrl = Value(audioUrl),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<ChatMessageEntry> custom({
    Expression<String>? ownerCacheKey,
    Expression<String>? messageId,
    Expression<String>? threadId,
    Expression<String>? threadType,
    Expression<String>? senderUserId,
    Expression<String>? senderName,
    Expression<String>? senderAvatarUrl,
    Expression<String>? senderLearningLanguage,
    Expression<String>? senderLearningLanguageDisplay,
    Expression<String>? senderNativeLanguage,
    Expression<String>? senderNativeLanguageDisplay,
    Expression<bool>? senderIsOnline,
    Expression<String>? spokenLanguageCode,
    Expression<int>? durationMs,
    Expression<int>? createdAtMillis,
    Expression<int>? expiresAtMillis,
    Expression<bool>? isMine,
    Expression<String>? audioUrl,
    Expression<String>? localAudioPath,
    Expression<String>? localTranscriptText,
    Expression<String>? localTranscriptStatus,
    Expression<String>? localTranscriptLanguage,
    Expression<String>? localTranscriptLanguageCode,
    Expression<bool>? isServerVisible,
    Expression<int>? updatedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerCacheKey != null) 'owner_cache_key': ownerCacheKey,
      if (messageId != null) 'message_id': messageId,
      if (threadId != null) 'thread_id': threadId,
      if (threadType != null) 'thread_type': threadType,
      if (senderUserId != null) 'sender_user_id': senderUserId,
      if (senderName != null) 'sender_name': senderName,
      if (senderAvatarUrl != null) 'sender_avatar_url': senderAvatarUrl,
      if (senderLearningLanguage != null)
        'sender_learning_language': senderLearningLanguage,
      if (senderLearningLanguageDisplay != null)
        'sender_learning_language_display': senderLearningLanguageDisplay,
      if (senderNativeLanguage != null)
        'sender_native_language': senderNativeLanguage,
      if (senderNativeLanguageDisplay != null)
        'sender_native_language_display': senderNativeLanguageDisplay,
      if (senderIsOnline != null) 'sender_is_online': senderIsOnline,
      if (spokenLanguageCode != null)
        'spoken_language_code': spokenLanguageCode,
      if (durationMs != null) 'duration_ms': durationMs,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
      if (expiresAtMillis != null) 'expires_at_millis': expiresAtMillis,
      if (isMine != null) 'is_mine': isMine,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (localAudioPath != null) 'local_audio_path': localAudioPath,
      if (localTranscriptText != null)
        'local_transcript_text': localTranscriptText,
      if (localTranscriptStatus != null)
        'local_transcript_status': localTranscriptStatus,
      if (localTranscriptLanguage != null)
        'local_transcript_language': localTranscriptLanguage,
      if (localTranscriptLanguageCode != null)
        'local_transcript_language_code': localTranscriptLanguageCode,
      if (isServerVisible != null) 'is_server_visible': isServerVisible,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessageEntriesCompanion copyWith({
    Value<String>? ownerCacheKey,
    Value<String>? messageId,
    Value<String>? threadId,
    Value<String>? threadType,
    Value<String>? senderUserId,
    Value<String>? senderName,
    Value<String?>? senderAvatarUrl,
    Value<String?>? senderLearningLanguage,
    Value<String?>? senderLearningLanguageDisplay,
    Value<String?>? senderNativeLanguage,
    Value<String?>? senderNativeLanguageDisplay,
    Value<bool>? senderIsOnline,
    Value<String>? spokenLanguageCode,
    Value<int>? durationMs,
    Value<int>? createdAtMillis,
    Value<int?>? expiresAtMillis,
    Value<bool>? isMine,
    Value<String>? audioUrl,
    Value<String?>? localAudioPath,
    Value<String?>? localTranscriptText,
    Value<String?>? localTranscriptStatus,
    Value<String?>? localTranscriptLanguage,
    Value<String?>? localTranscriptLanguageCode,
    Value<bool>? isServerVisible,
    Value<int>? updatedAtMillis,
    Value<int>? rowid,
  }) {
    return ChatMessageEntriesCompanion(
      ownerCacheKey: ownerCacheKey ?? this.ownerCacheKey,
      messageId: messageId ?? this.messageId,
      threadId: threadId ?? this.threadId,
      threadType: threadType ?? this.threadType,
      senderUserId: senderUserId ?? this.senderUserId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      senderLearningLanguage:
          senderLearningLanguage ?? this.senderLearningLanguage,
      senderLearningLanguageDisplay:
          senderLearningLanguageDisplay ?? this.senderLearningLanguageDisplay,
      senderNativeLanguage: senderNativeLanguage ?? this.senderNativeLanguage,
      senderNativeLanguageDisplay:
          senderNativeLanguageDisplay ?? this.senderNativeLanguageDisplay,
      senderIsOnline: senderIsOnline ?? this.senderIsOnline,
      spokenLanguageCode: spokenLanguageCode ?? this.spokenLanguageCode,
      durationMs: durationMs ?? this.durationMs,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      expiresAtMillis: expiresAtMillis ?? this.expiresAtMillis,
      isMine: isMine ?? this.isMine,
      audioUrl: audioUrl ?? this.audioUrl,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      localTranscriptText: localTranscriptText ?? this.localTranscriptText,
      localTranscriptStatus:
          localTranscriptStatus ?? this.localTranscriptStatus,
      localTranscriptLanguage:
          localTranscriptLanguage ?? this.localTranscriptLanguage,
      localTranscriptLanguageCode:
          localTranscriptLanguageCode ?? this.localTranscriptLanguageCode,
      isServerVisible: isServerVisible ?? this.isServerVisible,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerCacheKey.present) {
      map['owner_cache_key'] = Variable<String>(ownerCacheKey.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (threadId.present) {
      map['thread_id'] = Variable<String>(threadId.value);
    }
    if (threadType.present) {
      map['thread_type'] = Variable<String>(threadType.value);
    }
    if (senderUserId.present) {
      map['sender_user_id'] = Variable<String>(senderUserId.value);
    }
    if (senderName.present) {
      map['sender_name'] = Variable<String>(senderName.value);
    }
    if (senderAvatarUrl.present) {
      map['sender_avatar_url'] = Variable<String>(senderAvatarUrl.value);
    }
    if (senderLearningLanguage.present) {
      map['sender_learning_language'] = Variable<String>(
        senderLearningLanguage.value,
      );
    }
    if (senderLearningLanguageDisplay.present) {
      map['sender_learning_language_display'] = Variable<String>(
        senderLearningLanguageDisplay.value,
      );
    }
    if (senderNativeLanguage.present) {
      map['sender_native_language'] = Variable<String>(
        senderNativeLanguage.value,
      );
    }
    if (senderNativeLanguageDisplay.present) {
      map['sender_native_language_display'] = Variable<String>(
        senderNativeLanguageDisplay.value,
      );
    }
    if (senderIsOnline.present) {
      map['sender_is_online'] = Variable<bool>(senderIsOnline.value);
    }
    if (spokenLanguageCode.present) {
      map['spoken_language_code'] = Variable<String>(spokenLanguageCode.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (createdAtMillis.present) {
      map['created_at_millis'] = Variable<int>(createdAtMillis.value);
    }
    if (expiresAtMillis.present) {
      map['expires_at_millis'] = Variable<int>(expiresAtMillis.value);
    }
    if (isMine.present) {
      map['is_mine'] = Variable<bool>(isMine.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (localAudioPath.present) {
      map['local_audio_path'] = Variable<String>(localAudioPath.value);
    }
    if (localTranscriptText.present) {
      map['local_transcript_text'] = Variable<String>(
        localTranscriptText.value,
      );
    }
    if (localTranscriptStatus.present) {
      map['local_transcript_status'] = Variable<String>(
        localTranscriptStatus.value,
      );
    }
    if (localTranscriptLanguage.present) {
      map['local_transcript_language'] = Variable<String>(
        localTranscriptLanguage.value,
      );
    }
    if (localTranscriptLanguageCode.present) {
      map['local_transcript_language_code'] = Variable<String>(
        localTranscriptLanguageCode.value,
      );
    }
    if (isServerVisible.present) {
      map['is_server_visible'] = Variable<bool>(isServerVisible.value);
    }
    if (updatedAtMillis.present) {
      map['updated_at_millis'] = Variable<int>(updatedAtMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageEntriesCompanion(')
          ..write('ownerCacheKey: $ownerCacheKey, ')
          ..write('messageId: $messageId, ')
          ..write('threadId: $threadId, ')
          ..write('threadType: $threadType, ')
          ..write('senderUserId: $senderUserId, ')
          ..write('senderName: $senderName, ')
          ..write('senderAvatarUrl: $senderAvatarUrl, ')
          ..write('senderLearningLanguage: $senderLearningLanguage, ')
          ..write(
            'senderLearningLanguageDisplay: $senderLearningLanguageDisplay, ',
          )
          ..write('senderNativeLanguage: $senderNativeLanguage, ')
          ..write('senderNativeLanguageDisplay: $senderNativeLanguageDisplay, ')
          ..write('senderIsOnline: $senderIsOnline, ')
          ..write('spokenLanguageCode: $spokenLanguageCode, ')
          ..write('durationMs: $durationMs, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('expiresAtMillis: $expiresAtMillis, ')
          ..write('isMine: $isMine, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('localAudioPath: $localAudioPath, ')
          ..write('localTranscriptText: $localTranscriptText, ')
          ..write('localTranscriptStatus: $localTranscriptStatus, ')
          ..write('localTranscriptLanguage: $localTranscriptLanguage, ')
          ..write('localTranscriptLanguageCode: $localTranscriptLanguageCode, ')
          ..write('isServerVisible: $isServerVisible, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatBlockEntriesTable extends ChatBlockEntries
    with TableInfo<$ChatBlockEntriesTable, ChatBlockEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatBlockEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerCacheKeyMeta = const VerificationMeta(
    'ownerCacheKey',
  );
  @override
  late final GeneratedColumn<String> ownerCacheKey = GeneratedColumn<String>(
    'owner_cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _learningLanguageMeta = const VerificationMeta(
    'learningLanguage',
  );
  @override
  late final GeneratedColumn<String> learningLanguage = GeneratedColumn<String>(
    'learning_language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _learningLanguageDisplayMeta =
      const VerificationMeta('learningLanguageDisplay');
  @override
  late final GeneratedColumn<String> learningLanguageDisplay =
      GeneratedColumn<String>(
        'learning_language_display',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nativeLanguageMeta = const VerificationMeta(
    'nativeLanguage',
  );
  @override
  late final GeneratedColumn<String> nativeLanguage = GeneratedColumn<String>(
    'native_language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nativeLanguageDisplayMeta =
      const VerificationMeta('nativeLanguageDisplay');
  @override
  late final GeneratedColumn<String> nativeLanguageDisplay =
      GeneratedColumn<String>(
        'native_language_display',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isOnlineMeta = const VerificationMeta(
    'isOnline',
  );
  @override
  late final GeneratedColumn<bool> isOnline = GeneratedColumn<bool>(
    'is_online',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_online" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMillisMeta = const VerificationMeta(
    'updatedAtMillis',
  );
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
    'updated_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerCacheKey,
    userId,
    name,
    avatarUrl,
    learningLanguage,
    learningLanguageDisplay,
    nativeLanguage,
    nativeLanguageDisplay,
    isOnline,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_block_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatBlockEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_cache_key')) {
      context.handle(
        _ownerCacheKeyMeta,
        ownerCacheKey.isAcceptableOrUnknown(
          data['owner_cache_key']!,
          _ownerCacheKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerCacheKeyMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('learning_language')) {
      context.handle(
        _learningLanguageMeta,
        learningLanguage.isAcceptableOrUnknown(
          data['learning_language']!,
          _learningLanguageMeta,
        ),
      );
    }
    if (data.containsKey('learning_language_display')) {
      context.handle(
        _learningLanguageDisplayMeta,
        learningLanguageDisplay.isAcceptableOrUnknown(
          data['learning_language_display']!,
          _learningLanguageDisplayMeta,
        ),
      );
    }
    if (data.containsKey('native_language')) {
      context.handle(
        _nativeLanguageMeta,
        nativeLanguage.isAcceptableOrUnknown(
          data['native_language']!,
          _nativeLanguageMeta,
        ),
      );
    }
    if (data.containsKey('native_language_display')) {
      context.handle(
        _nativeLanguageDisplayMeta,
        nativeLanguageDisplay.isAcceptableOrUnknown(
          data['native_language_display']!,
          _nativeLanguageDisplayMeta,
        ),
      );
    }
    if (data.containsKey('is_online')) {
      context.handle(
        _isOnlineMeta,
        isOnline.isAcceptableOrUnknown(data['is_online']!, _isOnlineMeta),
      );
    }
    if (data.containsKey('updated_at_millis')) {
      context.handle(
        _updatedAtMillisMeta,
        updatedAtMillis.isAcceptableOrUnknown(
          data['updated_at_millis']!,
          _updatedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerCacheKey, userId};
  @override
  ChatBlockEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatBlockEntry(
      ownerCacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_cache_key'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      learningLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_language'],
      ),
      learningLanguageDisplay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_language_display'],
      ),
      nativeLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}native_language'],
      ),
      nativeLanguageDisplay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}native_language_display'],
      ),
      isOnline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_online'],
      )!,
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_millis'],
      )!,
    );
  }

  @override
  $ChatBlockEntriesTable createAlias(String alias) {
    return $ChatBlockEntriesTable(attachedDatabase, alias);
  }
}

class ChatBlockEntry extends DataClass implements Insertable<ChatBlockEntry> {
  final String ownerCacheKey;
  final String userId;
  final String name;
  final String? avatarUrl;
  final String? learningLanguage;
  final String? learningLanguageDisplay;
  final String? nativeLanguage;
  final String? nativeLanguageDisplay;
  final bool isOnline;
  final int updatedAtMillis;
  const ChatBlockEntry({
    required this.ownerCacheKey,
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.learningLanguage,
    this.learningLanguageDisplay,
    this.nativeLanguage,
    this.nativeLanguageDisplay,
    required this.isOnline,
    required this.updatedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_cache_key'] = Variable<String>(ownerCacheKey);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || learningLanguage != null) {
      map['learning_language'] = Variable<String>(learningLanguage);
    }
    if (!nullToAbsent || learningLanguageDisplay != null) {
      map['learning_language_display'] = Variable<String>(
        learningLanguageDisplay,
      );
    }
    if (!nullToAbsent || nativeLanguage != null) {
      map['native_language'] = Variable<String>(nativeLanguage);
    }
    if (!nullToAbsent || nativeLanguageDisplay != null) {
      map['native_language_display'] = Variable<String>(nativeLanguageDisplay);
    }
    map['is_online'] = Variable<bool>(isOnline);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  ChatBlockEntriesCompanion toCompanion(bool nullToAbsent) {
    return ChatBlockEntriesCompanion(
      ownerCacheKey: Value(ownerCacheKey),
      userId: Value(userId),
      name: Value(name),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      learningLanguage: learningLanguage == null && nullToAbsent
          ? const Value.absent()
          : Value(learningLanguage),
      learningLanguageDisplay: learningLanguageDisplay == null && nullToAbsent
          ? const Value.absent()
          : Value(learningLanguageDisplay),
      nativeLanguage: nativeLanguage == null && nullToAbsent
          ? const Value.absent()
          : Value(nativeLanguage),
      nativeLanguageDisplay: nativeLanguageDisplay == null && nullToAbsent
          ? const Value.absent()
          : Value(nativeLanguageDisplay),
      isOnline: Value(isOnline),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory ChatBlockEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatBlockEntry(
      ownerCacheKey: serializer.fromJson<String>(json['ownerCacheKey']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      learningLanguage: serializer.fromJson<String?>(json['learningLanguage']),
      learningLanguageDisplay: serializer.fromJson<String?>(
        json['learningLanguageDisplay'],
      ),
      nativeLanguage: serializer.fromJson<String?>(json['nativeLanguage']),
      nativeLanguageDisplay: serializer.fromJson<String?>(
        json['nativeLanguageDisplay'],
      ),
      isOnline: serializer.fromJson<bool>(json['isOnline']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerCacheKey': serializer.toJson<String>(ownerCacheKey),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'learningLanguage': serializer.toJson<String?>(learningLanguage),
      'learningLanguageDisplay': serializer.toJson<String?>(
        learningLanguageDisplay,
      ),
      'nativeLanguage': serializer.toJson<String?>(nativeLanguage),
      'nativeLanguageDisplay': serializer.toJson<String?>(
        nativeLanguageDisplay,
      ),
      'isOnline': serializer.toJson<bool>(isOnline),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  ChatBlockEntry copyWith({
    String? ownerCacheKey,
    String? userId,
    String? name,
    Value<String?> avatarUrl = const Value.absent(),
    Value<String?> learningLanguage = const Value.absent(),
    Value<String?> learningLanguageDisplay = const Value.absent(),
    Value<String?> nativeLanguage = const Value.absent(),
    Value<String?> nativeLanguageDisplay = const Value.absent(),
    bool? isOnline,
    int? updatedAtMillis,
  }) => ChatBlockEntry(
    ownerCacheKey: ownerCacheKey ?? this.ownerCacheKey,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    learningLanguage: learningLanguage.present
        ? learningLanguage.value
        : this.learningLanguage,
    learningLanguageDisplay: learningLanguageDisplay.present
        ? learningLanguageDisplay.value
        : this.learningLanguageDisplay,
    nativeLanguage: nativeLanguage.present
        ? nativeLanguage.value
        : this.nativeLanguage,
    nativeLanguageDisplay: nativeLanguageDisplay.present
        ? nativeLanguageDisplay.value
        : this.nativeLanguageDisplay,
    isOnline: isOnline ?? this.isOnline,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  ChatBlockEntry copyWithCompanion(ChatBlockEntriesCompanion data) {
    return ChatBlockEntry(
      ownerCacheKey: data.ownerCacheKey.present
          ? data.ownerCacheKey.value
          : this.ownerCacheKey,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      learningLanguage: data.learningLanguage.present
          ? data.learningLanguage.value
          : this.learningLanguage,
      learningLanguageDisplay: data.learningLanguageDisplay.present
          ? data.learningLanguageDisplay.value
          : this.learningLanguageDisplay,
      nativeLanguage: data.nativeLanguage.present
          ? data.nativeLanguage.value
          : this.nativeLanguage,
      nativeLanguageDisplay: data.nativeLanguageDisplay.present
          ? data.nativeLanguageDisplay.value
          : this.nativeLanguageDisplay,
      isOnline: data.isOnline.present ? data.isOnline.value : this.isOnline,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatBlockEntry(')
          ..write('ownerCacheKey: $ownerCacheKey, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('learningLanguage: $learningLanguage, ')
          ..write('learningLanguageDisplay: $learningLanguageDisplay, ')
          ..write('nativeLanguage: $nativeLanguage, ')
          ..write('nativeLanguageDisplay: $nativeLanguageDisplay, ')
          ..write('isOnline: $isOnline, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerCacheKey,
    userId,
    name,
    avatarUrl,
    learningLanguage,
    learningLanguageDisplay,
    nativeLanguage,
    nativeLanguageDisplay,
    isOnline,
    updatedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatBlockEntry &&
          other.ownerCacheKey == this.ownerCacheKey &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.avatarUrl == this.avatarUrl &&
          other.learningLanguage == this.learningLanguage &&
          other.learningLanguageDisplay == this.learningLanguageDisplay &&
          other.nativeLanguage == this.nativeLanguage &&
          other.nativeLanguageDisplay == this.nativeLanguageDisplay &&
          other.isOnline == this.isOnline &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class ChatBlockEntriesCompanion extends UpdateCompanion<ChatBlockEntry> {
  final Value<String> ownerCacheKey;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> avatarUrl;
  final Value<String?> learningLanguage;
  final Value<String?> learningLanguageDisplay;
  final Value<String?> nativeLanguage;
  final Value<String?> nativeLanguageDisplay;
  final Value<bool> isOnline;
  final Value<int> updatedAtMillis;
  final Value<int> rowid;
  const ChatBlockEntriesCompanion({
    this.ownerCacheKey = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.learningLanguage = const Value.absent(),
    this.learningLanguageDisplay = const Value.absent(),
    this.nativeLanguage = const Value.absent(),
    this.nativeLanguageDisplay = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatBlockEntriesCompanion.insert({
    required String ownerCacheKey,
    required String userId,
    required String name,
    this.avatarUrl = const Value.absent(),
    this.learningLanguage = const Value.absent(),
    this.learningLanguageDisplay = const Value.absent(),
    this.nativeLanguage = const Value.absent(),
    this.nativeLanguageDisplay = const Value.absent(),
    this.isOnline = const Value.absent(),
    required int updatedAtMillis,
    this.rowid = const Value.absent(),
  }) : ownerCacheKey = Value(ownerCacheKey),
       userId = Value(userId),
       name = Value(name),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<ChatBlockEntry> custom({
    Expression<String>? ownerCacheKey,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? avatarUrl,
    Expression<String>? learningLanguage,
    Expression<String>? learningLanguageDisplay,
    Expression<String>? nativeLanguage,
    Expression<String>? nativeLanguageDisplay,
    Expression<bool>? isOnline,
    Expression<int>? updatedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerCacheKey != null) 'owner_cache_key': ownerCacheKey,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (learningLanguage != null) 'learning_language': learningLanguage,
      if (learningLanguageDisplay != null)
        'learning_language_display': learningLanguageDisplay,
      if (nativeLanguage != null) 'native_language': nativeLanguage,
      if (nativeLanguageDisplay != null)
        'native_language_display': nativeLanguageDisplay,
      if (isOnline != null) 'is_online': isOnline,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatBlockEntriesCompanion copyWith({
    Value<String>? ownerCacheKey,
    Value<String>? userId,
    Value<String>? name,
    Value<String?>? avatarUrl,
    Value<String?>? learningLanguage,
    Value<String?>? learningLanguageDisplay,
    Value<String?>? nativeLanguage,
    Value<String?>? nativeLanguageDisplay,
    Value<bool>? isOnline,
    Value<int>? updatedAtMillis,
    Value<int>? rowid,
  }) {
    return ChatBlockEntriesCompanion(
      ownerCacheKey: ownerCacheKey ?? this.ownerCacheKey,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      learningLanguage: learningLanguage ?? this.learningLanguage,
      learningLanguageDisplay:
          learningLanguageDisplay ?? this.learningLanguageDisplay,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      nativeLanguageDisplay:
          nativeLanguageDisplay ?? this.nativeLanguageDisplay,
      isOnline: isOnline ?? this.isOnline,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerCacheKey.present) {
      map['owner_cache_key'] = Variable<String>(ownerCacheKey.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (learningLanguage.present) {
      map['learning_language'] = Variable<String>(learningLanguage.value);
    }
    if (learningLanguageDisplay.present) {
      map['learning_language_display'] = Variable<String>(
        learningLanguageDisplay.value,
      );
    }
    if (nativeLanguage.present) {
      map['native_language'] = Variable<String>(nativeLanguage.value);
    }
    if (nativeLanguageDisplay.present) {
      map['native_language_display'] = Variable<String>(
        nativeLanguageDisplay.value,
      );
    }
    if (isOnline.present) {
      map['is_online'] = Variable<bool>(isOnline.value);
    }
    if (updatedAtMillis.present) {
      map['updated_at_millis'] = Variable<int>(updatedAtMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatBlockEntriesCompanion(')
          ..write('ownerCacheKey: $ownerCacheKey, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('learningLanguage: $learningLanguage, ')
          ..write('learningLanguageDisplay: $learningLanguageDisplay, ')
          ..write('nativeLanguage: $nativeLanguage, ')
          ..write('nativeLanguageDisplay: $nativeLanguageDisplay, ')
          ..write('isOnline: $isOnline, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalChatDatabase extends GeneratedDatabase {
  _$LocalChatDatabase(QueryExecutor e) : super(e);
  $LocalChatDatabaseManager get managers => $LocalChatDatabaseManager(this);
  late final $ChatThreadEntriesTable chatThreadEntries =
      $ChatThreadEntriesTable(this);
  late final $ChatUserEntriesTable chatUserEntries = $ChatUserEntriesTable(
    this,
  );
  late final $ChatMessageEntriesTable chatMessageEntries =
      $ChatMessageEntriesTable(this);
  late final $ChatBlockEntriesTable chatBlockEntries = $ChatBlockEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    chatThreadEntries,
    chatUserEntries,
    chatMessageEntries,
    chatBlockEntries,
  ];
}

typedef $$ChatThreadEntriesTableCreateCompanionBuilder =
    ChatThreadEntriesCompanion Function({
      required String ownerCacheKey,
      required String threadId,
      required String threadType,
      required String title,
      Value<String?> avatarUrl,
      Value<String?> learningLanguage,
      Value<String?> learningLanguageDisplay,
      Value<String?> nativeLanguage,
      Value<String?> nativeLanguageDisplay,
      Value<bool> isMuted,
      Value<int> unreadCount,
      Value<int?> lastMessageAtMillis,
      Value<int?> lastMessageDurationMs,
      Value<String?> otherUserId,
      Value<String> roleBadgesJson,
      required String section,
      Value<int> sectionOrder,
      required int updatedAtMillis,
      Value<int> rowid,
    });
typedef $$ChatThreadEntriesTableUpdateCompanionBuilder =
    ChatThreadEntriesCompanion Function({
      Value<String> ownerCacheKey,
      Value<String> threadId,
      Value<String> threadType,
      Value<String> title,
      Value<String?> avatarUrl,
      Value<String?> learningLanguage,
      Value<String?> learningLanguageDisplay,
      Value<String?> nativeLanguage,
      Value<String?> nativeLanguageDisplay,
      Value<bool> isMuted,
      Value<int> unreadCount,
      Value<int?> lastMessageAtMillis,
      Value<int?> lastMessageDurationMs,
      Value<String?> otherUserId,
      Value<String> roleBadgesJson,
      Value<String> section,
      Value<int> sectionOrder,
      Value<int> updatedAtMillis,
      Value<int> rowid,
    });

class $$ChatThreadEntriesTableFilterComposer
    extends Composer<_$LocalChatDatabase, $ChatThreadEntriesTable> {
  $$ChatThreadEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerCacheKey => $composableBuilder(
    column: $table.ownerCacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get threadId => $composableBuilder(
    column: $table.threadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get threadType => $composableBuilder(
    column: $table.threadType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learningLanguage => $composableBuilder(
    column: $table.learningLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learningLanguageDisplay => $composableBuilder(
    column: $table.learningLanguageDisplay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nativeLanguage => $composableBuilder(
    column: $table.nativeLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nativeLanguageDisplay => $composableBuilder(
    column: $table.nativeLanguageDisplay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMuted => $composableBuilder(
    column: $table.isMuted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessageAtMillis => $composableBuilder(
    column: $table.lastMessageAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessageDurationMs => $composableBuilder(
    column: $table.lastMessageDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get otherUserId => $composableBuilder(
    column: $table.otherUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roleBadgesJson => $composableBuilder(
    column: $table.roleBadgesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sectionOrder => $composableBuilder(
    column: $table.sectionOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatThreadEntriesTableOrderingComposer
    extends Composer<_$LocalChatDatabase, $ChatThreadEntriesTable> {
  $$ChatThreadEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerCacheKey => $composableBuilder(
    column: $table.ownerCacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get threadId => $composableBuilder(
    column: $table.threadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get threadType => $composableBuilder(
    column: $table.threadType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learningLanguage => $composableBuilder(
    column: $table.learningLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learningLanguageDisplay => $composableBuilder(
    column: $table.learningLanguageDisplay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nativeLanguage => $composableBuilder(
    column: $table.nativeLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nativeLanguageDisplay => $composableBuilder(
    column: $table.nativeLanguageDisplay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMuted => $composableBuilder(
    column: $table.isMuted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessageAtMillis => $composableBuilder(
    column: $table.lastMessageAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessageDurationMs => $composableBuilder(
    column: $table.lastMessageDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get otherUserId => $composableBuilder(
    column: $table.otherUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roleBadgesJson => $composableBuilder(
    column: $table.roleBadgesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sectionOrder => $composableBuilder(
    column: $table.sectionOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatThreadEntriesTableAnnotationComposer
    extends Composer<_$LocalChatDatabase, $ChatThreadEntriesTable> {
  $$ChatThreadEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerCacheKey => $composableBuilder(
    column: $table.ownerCacheKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get threadId =>
      $composableBuilder(column: $table.threadId, builder: (column) => column);

  GeneratedColumn<String> get threadType => $composableBuilder(
    column: $table.threadType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get learningLanguage => $composableBuilder(
    column: $table.learningLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get learningLanguageDisplay => $composableBuilder(
    column: $table.learningLanguageDisplay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nativeLanguage => $composableBuilder(
    column: $table.nativeLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nativeLanguageDisplay => $composableBuilder(
    column: $table.nativeLanguageDisplay,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isMuted =>
      $composableBuilder(column: $table.isMuted, builder: (column) => column);

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastMessageAtMillis => $composableBuilder(
    column: $table.lastMessageAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastMessageDurationMs => $composableBuilder(
    column: $table.lastMessageDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get otherUserId => $composableBuilder(
    column: $table.otherUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get roleBadgesJson => $composableBuilder(
    column: $table.roleBadgesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get section =>
      $composableBuilder(column: $table.section, builder: (column) => column);

  GeneratedColumn<int> get sectionOrder => $composableBuilder(
    column: $table.sectionOrder,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );
}

class $$ChatThreadEntriesTableTableManager
    extends
        RootTableManager<
          _$LocalChatDatabase,
          $ChatThreadEntriesTable,
          ChatThreadEntry,
          $$ChatThreadEntriesTableFilterComposer,
          $$ChatThreadEntriesTableOrderingComposer,
          $$ChatThreadEntriesTableAnnotationComposer,
          $$ChatThreadEntriesTableCreateCompanionBuilder,
          $$ChatThreadEntriesTableUpdateCompanionBuilder,
          (
            ChatThreadEntry,
            BaseReferences<
              _$LocalChatDatabase,
              $ChatThreadEntriesTable,
              ChatThreadEntry
            >,
          ),
          ChatThreadEntry,
          PrefetchHooks Function()
        > {
  $$ChatThreadEntriesTableTableManager(
    _$LocalChatDatabase db,
    $ChatThreadEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatThreadEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatThreadEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatThreadEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> ownerCacheKey = const Value.absent(),
                Value<String> threadId = const Value.absent(),
                Value<String> threadType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> learningLanguage = const Value.absent(),
                Value<String?> learningLanguageDisplay = const Value.absent(),
                Value<String?> nativeLanguage = const Value.absent(),
                Value<String?> nativeLanguageDisplay = const Value.absent(),
                Value<bool> isMuted = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<int?> lastMessageAtMillis = const Value.absent(),
                Value<int?> lastMessageDurationMs = const Value.absent(),
                Value<String?> otherUserId = const Value.absent(),
                Value<String> roleBadgesJson = const Value.absent(),
                Value<String> section = const Value.absent(),
                Value<int> sectionOrder = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatThreadEntriesCompanion(
                ownerCacheKey: ownerCacheKey,
                threadId: threadId,
                threadType: threadType,
                title: title,
                avatarUrl: avatarUrl,
                learningLanguage: learningLanguage,
                learningLanguageDisplay: learningLanguageDisplay,
                nativeLanguage: nativeLanguage,
                nativeLanguageDisplay: nativeLanguageDisplay,
                isMuted: isMuted,
                unreadCount: unreadCount,
                lastMessageAtMillis: lastMessageAtMillis,
                lastMessageDurationMs: lastMessageDurationMs,
                otherUserId: otherUserId,
                roleBadgesJson: roleBadgesJson,
                section: section,
                sectionOrder: sectionOrder,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerCacheKey,
                required String threadId,
                required String threadType,
                required String title,
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> learningLanguage = const Value.absent(),
                Value<String?> learningLanguageDisplay = const Value.absent(),
                Value<String?> nativeLanguage = const Value.absent(),
                Value<String?> nativeLanguageDisplay = const Value.absent(),
                Value<bool> isMuted = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<int?> lastMessageAtMillis = const Value.absent(),
                Value<int?> lastMessageDurationMs = const Value.absent(),
                Value<String?> otherUserId = const Value.absent(),
                Value<String> roleBadgesJson = const Value.absent(),
                required String section,
                Value<int> sectionOrder = const Value.absent(),
                required int updatedAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => ChatThreadEntriesCompanion.insert(
                ownerCacheKey: ownerCacheKey,
                threadId: threadId,
                threadType: threadType,
                title: title,
                avatarUrl: avatarUrl,
                learningLanguage: learningLanguage,
                learningLanguageDisplay: learningLanguageDisplay,
                nativeLanguage: nativeLanguage,
                nativeLanguageDisplay: nativeLanguageDisplay,
                isMuted: isMuted,
                unreadCount: unreadCount,
                lastMessageAtMillis: lastMessageAtMillis,
                lastMessageDurationMs: lastMessageDurationMs,
                otherUserId: otherUserId,
                roleBadgesJson: roleBadgesJson,
                section: section,
                sectionOrder: sectionOrder,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatThreadEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalChatDatabase,
      $ChatThreadEntriesTable,
      ChatThreadEntry,
      $$ChatThreadEntriesTableFilterComposer,
      $$ChatThreadEntriesTableOrderingComposer,
      $$ChatThreadEntriesTableAnnotationComposer,
      $$ChatThreadEntriesTableCreateCompanionBuilder,
      $$ChatThreadEntriesTableUpdateCompanionBuilder,
      (
        ChatThreadEntry,
        BaseReferences<
          _$LocalChatDatabase,
          $ChatThreadEntriesTable,
          ChatThreadEntry
        >,
      ),
      ChatThreadEntry,
      PrefetchHooks Function()
    >;
typedef $$ChatUserEntriesTableCreateCompanionBuilder =
    ChatUserEntriesCompanion Function({
      required String ownerCacheKey,
      required String userId,
      required String name,
      Value<String?> avatarUrl,
      Value<String?> learningLanguage,
      Value<String?> learningLanguageDisplay,
      Value<String?> nativeLanguage,
      Value<String?> nativeLanguageDisplay,
      Value<bool> isOnline,
      required int updatedAtMillis,
      Value<int> rowid,
    });
typedef $$ChatUserEntriesTableUpdateCompanionBuilder =
    ChatUserEntriesCompanion Function({
      Value<String> ownerCacheKey,
      Value<String> userId,
      Value<String> name,
      Value<String?> avatarUrl,
      Value<String?> learningLanguage,
      Value<String?> learningLanguageDisplay,
      Value<String?> nativeLanguage,
      Value<String?> nativeLanguageDisplay,
      Value<bool> isOnline,
      Value<int> updatedAtMillis,
      Value<int> rowid,
    });

class $$ChatUserEntriesTableFilterComposer
    extends Composer<_$LocalChatDatabase, $ChatUserEntriesTable> {
  $$ChatUserEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerCacheKey => $composableBuilder(
    column: $table.ownerCacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learningLanguage => $composableBuilder(
    column: $table.learningLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learningLanguageDisplay => $composableBuilder(
    column: $table.learningLanguageDisplay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nativeLanguage => $composableBuilder(
    column: $table.nativeLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nativeLanguageDisplay => $composableBuilder(
    column: $table.nativeLanguageDisplay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOnline => $composableBuilder(
    column: $table.isOnline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatUserEntriesTableOrderingComposer
    extends Composer<_$LocalChatDatabase, $ChatUserEntriesTable> {
  $$ChatUserEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerCacheKey => $composableBuilder(
    column: $table.ownerCacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learningLanguage => $composableBuilder(
    column: $table.learningLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learningLanguageDisplay => $composableBuilder(
    column: $table.learningLanguageDisplay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nativeLanguage => $composableBuilder(
    column: $table.nativeLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nativeLanguageDisplay => $composableBuilder(
    column: $table.nativeLanguageDisplay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOnline => $composableBuilder(
    column: $table.isOnline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatUserEntriesTableAnnotationComposer
    extends Composer<_$LocalChatDatabase, $ChatUserEntriesTable> {
  $$ChatUserEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerCacheKey => $composableBuilder(
    column: $table.ownerCacheKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get learningLanguage => $composableBuilder(
    column: $table.learningLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get learningLanguageDisplay => $composableBuilder(
    column: $table.learningLanguageDisplay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nativeLanguage => $composableBuilder(
    column: $table.nativeLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nativeLanguageDisplay => $composableBuilder(
    column: $table.nativeLanguageDisplay,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOnline =>
      $composableBuilder(column: $table.isOnline, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );
}

class $$ChatUserEntriesTableTableManager
    extends
        RootTableManager<
          _$LocalChatDatabase,
          $ChatUserEntriesTable,
          ChatUserEntry,
          $$ChatUserEntriesTableFilterComposer,
          $$ChatUserEntriesTableOrderingComposer,
          $$ChatUserEntriesTableAnnotationComposer,
          $$ChatUserEntriesTableCreateCompanionBuilder,
          $$ChatUserEntriesTableUpdateCompanionBuilder,
          (
            ChatUserEntry,
            BaseReferences<
              _$LocalChatDatabase,
              $ChatUserEntriesTable,
              ChatUserEntry
            >,
          ),
          ChatUserEntry,
          PrefetchHooks Function()
        > {
  $$ChatUserEntriesTableTableManager(
    _$LocalChatDatabase db,
    $ChatUserEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatUserEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatUserEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatUserEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerCacheKey = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> learningLanguage = const Value.absent(),
                Value<String?> learningLanguageDisplay = const Value.absent(),
                Value<String?> nativeLanguage = const Value.absent(),
                Value<String?> nativeLanguageDisplay = const Value.absent(),
                Value<bool> isOnline = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatUserEntriesCompanion(
                ownerCacheKey: ownerCacheKey,
                userId: userId,
                name: name,
                avatarUrl: avatarUrl,
                learningLanguage: learningLanguage,
                learningLanguageDisplay: learningLanguageDisplay,
                nativeLanguage: nativeLanguage,
                nativeLanguageDisplay: nativeLanguageDisplay,
                isOnline: isOnline,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerCacheKey,
                required String userId,
                required String name,
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> learningLanguage = const Value.absent(),
                Value<String?> learningLanguageDisplay = const Value.absent(),
                Value<String?> nativeLanguage = const Value.absent(),
                Value<String?> nativeLanguageDisplay = const Value.absent(),
                Value<bool> isOnline = const Value.absent(),
                required int updatedAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => ChatUserEntriesCompanion.insert(
                ownerCacheKey: ownerCacheKey,
                userId: userId,
                name: name,
                avatarUrl: avatarUrl,
                learningLanguage: learningLanguage,
                learningLanguageDisplay: learningLanguageDisplay,
                nativeLanguage: nativeLanguage,
                nativeLanguageDisplay: nativeLanguageDisplay,
                isOnline: isOnline,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatUserEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalChatDatabase,
      $ChatUserEntriesTable,
      ChatUserEntry,
      $$ChatUserEntriesTableFilterComposer,
      $$ChatUserEntriesTableOrderingComposer,
      $$ChatUserEntriesTableAnnotationComposer,
      $$ChatUserEntriesTableCreateCompanionBuilder,
      $$ChatUserEntriesTableUpdateCompanionBuilder,
      (
        ChatUserEntry,
        BaseReferences<
          _$LocalChatDatabase,
          $ChatUserEntriesTable,
          ChatUserEntry
        >,
      ),
      ChatUserEntry,
      PrefetchHooks Function()
    >;
typedef $$ChatMessageEntriesTableCreateCompanionBuilder =
    ChatMessageEntriesCompanion Function({
      required String ownerCacheKey,
      required String messageId,
      required String threadId,
      required String threadType,
      required String senderUserId,
      required String senderName,
      Value<String?> senderAvatarUrl,
      Value<String?> senderLearningLanguage,
      Value<String?> senderLearningLanguageDisplay,
      Value<String?> senderNativeLanguage,
      Value<String?> senderNativeLanguageDisplay,
      Value<bool> senderIsOnline,
      required String spokenLanguageCode,
      required int durationMs,
      required int createdAtMillis,
      Value<int?> expiresAtMillis,
      Value<bool> isMine,
      required String audioUrl,
      Value<String?> localAudioPath,
      Value<String?> localTranscriptText,
      Value<String?> localTranscriptStatus,
      Value<String?> localTranscriptLanguage,
      Value<String?> localTranscriptLanguageCode,
      Value<bool> isServerVisible,
      required int updatedAtMillis,
      Value<int> rowid,
    });
typedef $$ChatMessageEntriesTableUpdateCompanionBuilder =
    ChatMessageEntriesCompanion Function({
      Value<String> ownerCacheKey,
      Value<String> messageId,
      Value<String> threadId,
      Value<String> threadType,
      Value<String> senderUserId,
      Value<String> senderName,
      Value<String?> senderAvatarUrl,
      Value<String?> senderLearningLanguage,
      Value<String?> senderLearningLanguageDisplay,
      Value<String?> senderNativeLanguage,
      Value<String?> senderNativeLanguageDisplay,
      Value<bool> senderIsOnline,
      Value<String> spokenLanguageCode,
      Value<int> durationMs,
      Value<int> createdAtMillis,
      Value<int?> expiresAtMillis,
      Value<bool> isMine,
      Value<String> audioUrl,
      Value<String?> localAudioPath,
      Value<String?> localTranscriptText,
      Value<String?> localTranscriptStatus,
      Value<String?> localTranscriptLanguage,
      Value<String?> localTranscriptLanguageCode,
      Value<bool> isServerVisible,
      Value<int> updatedAtMillis,
      Value<int> rowid,
    });

class $$ChatMessageEntriesTableFilterComposer
    extends Composer<_$LocalChatDatabase, $ChatMessageEntriesTable> {
  $$ChatMessageEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerCacheKey => $composableBuilder(
    column: $table.ownerCacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get threadId => $composableBuilder(
    column: $table.threadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get threadType => $composableBuilder(
    column: $table.threadType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderUserId => $composableBuilder(
    column: $table.senderUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderAvatarUrl => $composableBuilder(
    column: $table.senderAvatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderLearningLanguage => $composableBuilder(
    column: $table.senderLearningLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderLearningLanguageDisplay => $composableBuilder(
    column: $table.senderLearningLanguageDisplay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderNativeLanguage => $composableBuilder(
    column: $table.senderNativeLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderNativeLanguageDisplay => $composableBuilder(
    column: $table.senderNativeLanguageDisplay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get senderIsOnline => $composableBuilder(
    column: $table.senderIsOnline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spokenLanguageCode => $composableBuilder(
    column: $table.spokenLanguageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiresAtMillis => $composableBuilder(
    column: $table.expiresAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMine => $composableBuilder(
    column: $table.isMine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localAudioPath => $composableBuilder(
    column: $table.localAudioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localTranscriptText => $composableBuilder(
    column: $table.localTranscriptText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localTranscriptStatus => $composableBuilder(
    column: $table.localTranscriptStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localTranscriptLanguage => $composableBuilder(
    column: $table.localTranscriptLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localTranscriptLanguageCode => $composableBuilder(
    column: $table.localTranscriptLanguageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isServerVisible => $composableBuilder(
    column: $table.isServerVisible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMessageEntriesTableOrderingComposer
    extends Composer<_$LocalChatDatabase, $ChatMessageEntriesTable> {
  $$ChatMessageEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerCacheKey => $composableBuilder(
    column: $table.ownerCacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get threadId => $composableBuilder(
    column: $table.threadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get threadType => $composableBuilder(
    column: $table.threadType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderUserId => $composableBuilder(
    column: $table.senderUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderAvatarUrl => $composableBuilder(
    column: $table.senderAvatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderLearningLanguage => $composableBuilder(
    column: $table.senderLearningLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderLearningLanguageDisplay =>
      $composableBuilder(
        column: $table.senderLearningLanguageDisplay,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get senderNativeLanguage => $composableBuilder(
    column: $table.senderNativeLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderNativeLanguageDisplay => $composableBuilder(
    column: $table.senderNativeLanguageDisplay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get senderIsOnline => $composableBuilder(
    column: $table.senderIsOnline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spokenLanguageCode => $composableBuilder(
    column: $table.spokenLanguageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiresAtMillis => $composableBuilder(
    column: $table.expiresAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMine => $composableBuilder(
    column: $table.isMine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localAudioPath => $composableBuilder(
    column: $table.localAudioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localTranscriptText => $composableBuilder(
    column: $table.localTranscriptText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localTranscriptStatus => $composableBuilder(
    column: $table.localTranscriptStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localTranscriptLanguage => $composableBuilder(
    column: $table.localTranscriptLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localTranscriptLanguageCode => $composableBuilder(
    column: $table.localTranscriptLanguageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isServerVisible => $composableBuilder(
    column: $table.isServerVisible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMessageEntriesTableAnnotationComposer
    extends Composer<_$LocalChatDatabase, $ChatMessageEntriesTable> {
  $$ChatMessageEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerCacheKey => $composableBuilder(
    column: $table.ownerCacheKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get threadId =>
      $composableBuilder(column: $table.threadId, builder: (column) => column);

  GeneratedColumn<String> get threadType => $composableBuilder(
    column: $table.threadType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderUserId => $composableBuilder(
    column: $table.senderUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderAvatarUrl => $composableBuilder(
    column: $table.senderAvatarUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderLearningLanguage => $composableBuilder(
    column: $table.senderLearningLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderLearningLanguageDisplay =>
      $composableBuilder(
        column: $table.senderLearningLanguageDisplay,
        builder: (column) => column,
      );

  GeneratedColumn<String> get senderNativeLanguage => $composableBuilder(
    column: $table.senderNativeLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderNativeLanguageDisplay => $composableBuilder(
    column: $table.senderNativeLanguageDisplay,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get senderIsOnline => $composableBuilder(
    column: $table.senderIsOnline,
    builder: (column) => column,
  );

  GeneratedColumn<String> get spokenLanguageCode => $composableBuilder(
    column: $table.spokenLanguageCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expiresAtMillis => $composableBuilder(
    column: $table.expiresAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isMine =>
      $composableBuilder(column: $table.isMine, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<String> get localAudioPath => $composableBuilder(
    column: $table.localAudioPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localTranscriptText => $composableBuilder(
    column: $table.localTranscriptText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localTranscriptStatus => $composableBuilder(
    column: $table.localTranscriptStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localTranscriptLanguage => $composableBuilder(
    column: $table.localTranscriptLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localTranscriptLanguageCode => $composableBuilder(
    column: $table.localTranscriptLanguageCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isServerVisible => $composableBuilder(
    column: $table.isServerVisible,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );
}

class $$ChatMessageEntriesTableTableManager
    extends
        RootTableManager<
          _$LocalChatDatabase,
          $ChatMessageEntriesTable,
          ChatMessageEntry,
          $$ChatMessageEntriesTableFilterComposer,
          $$ChatMessageEntriesTableOrderingComposer,
          $$ChatMessageEntriesTableAnnotationComposer,
          $$ChatMessageEntriesTableCreateCompanionBuilder,
          $$ChatMessageEntriesTableUpdateCompanionBuilder,
          (
            ChatMessageEntry,
            BaseReferences<
              _$LocalChatDatabase,
              $ChatMessageEntriesTable,
              ChatMessageEntry
            >,
          ),
          ChatMessageEntry,
          PrefetchHooks Function()
        > {
  $$ChatMessageEntriesTableTableManager(
    _$LocalChatDatabase db,
    $ChatMessageEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessageEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessageEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessageEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> ownerCacheKey = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<String> threadId = const Value.absent(),
                Value<String> threadType = const Value.absent(),
                Value<String> senderUserId = const Value.absent(),
                Value<String> senderName = const Value.absent(),
                Value<String?> senderAvatarUrl = const Value.absent(),
                Value<String?> senderLearningLanguage = const Value.absent(),
                Value<String?> senderLearningLanguageDisplay =
                    const Value.absent(),
                Value<String?> senderNativeLanguage = const Value.absent(),
                Value<String?> senderNativeLanguageDisplay =
                    const Value.absent(),
                Value<bool> senderIsOnline = const Value.absent(),
                Value<String> spokenLanguageCode = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> createdAtMillis = const Value.absent(),
                Value<int?> expiresAtMillis = const Value.absent(),
                Value<bool> isMine = const Value.absent(),
                Value<String> audioUrl = const Value.absent(),
                Value<String?> localAudioPath = const Value.absent(),
                Value<String?> localTranscriptText = const Value.absent(),
                Value<String?> localTranscriptStatus = const Value.absent(),
                Value<String?> localTranscriptLanguage = const Value.absent(),
                Value<String?> localTranscriptLanguageCode =
                    const Value.absent(),
                Value<bool> isServerVisible = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessageEntriesCompanion(
                ownerCacheKey: ownerCacheKey,
                messageId: messageId,
                threadId: threadId,
                threadType: threadType,
                senderUserId: senderUserId,
                senderName: senderName,
                senderAvatarUrl: senderAvatarUrl,
                senderLearningLanguage: senderLearningLanguage,
                senderLearningLanguageDisplay: senderLearningLanguageDisplay,
                senderNativeLanguage: senderNativeLanguage,
                senderNativeLanguageDisplay: senderNativeLanguageDisplay,
                senderIsOnline: senderIsOnline,
                spokenLanguageCode: spokenLanguageCode,
                durationMs: durationMs,
                createdAtMillis: createdAtMillis,
                expiresAtMillis: expiresAtMillis,
                isMine: isMine,
                audioUrl: audioUrl,
                localAudioPath: localAudioPath,
                localTranscriptText: localTranscriptText,
                localTranscriptStatus: localTranscriptStatus,
                localTranscriptLanguage: localTranscriptLanguage,
                localTranscriptLanguageCode: localTranscriptLanguageCode,
                isServerVisible: isServerVisible,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerCacheKey,
                required String messageId,
                required String threadId,
                required String threadType,
                required String senderUserId,
                required String senderName,
                Value<String?> senderAvatarUrl = const Value.absent(),
                Value<String?> senderLearningLanguage = const Value.absent(),
                Value<String?> senderLearningLanguageDisplay =
                    const Value.absent(),
                Value<String?> senderNativeLanguage = const Value.absent(),
                Value<String?> senderNativeLanguageDisplay =
                    const Value.absent(),
                Value<bool> senderIsOnline = const Value.absent(),
                required String spokenLanguageCode,
                required int durationMs,
                required int createdAtMillis,
                Value<int?> expiresAtMillis = const Value.absent(),
                Value<bool> isMine = const Value.absent(),
                required String audioUrl,
                Value<String?> localAudioPath = const Value.absent(),
                Value<String?> localTranscriptText = const Value.absent(),
                Value<String?> localTranscriptStatus = const Value.absent(),
                Value<String?> localTranscriptLanguage = const Value.absent(),
                Value<String?> localTranscriptLanguageCode =
                    const Value.absent(),
                Value<bool> isServerVisible = const Value.absent(),
                required int updatedAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => ChatMessageEntriesCompanion.insert(
                ownerCacheKey: ownerCacheKey,
                messageId: messageId,
                threadId: threadId,
                threadType: threadType,
                senderUserId: senderUserId,
                senderName: senderName,
                senderAvatarUrl: senderAvatarUrl,
                senderLearningLanguage: senderLearningLanguage,
                senderLearningLanguageDisplay: senderLearningLanguageDisplay,
                senderNativeLanguage: senderNativeLanguage,
                senderNativeLanguageDisplay: senderNativeLanguageDisplay,
                senderIsOnline: senderIsOnline,
                spokenLanguageCode: spokenLanguageCode,
                durationMs: durationMs,
                createdAtMillis: createdAtMillis,
                expiresAtMillis: expiresAtMillis,
                isMine: isMine,
                audioUrl: audioUrl,
                localAudioPath: localAudioPath,
                localTranscriptText: localTranscriptText,
                localTranscriptStatus: localTranscriptStatus,
                localTranscriptLanguage: localTranscriptLanguage,
                localTranscriptLanguageCode: localTranscriptLanguageCode,
                isServerVisible: isServerVisible,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessageEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalChatDatabase,
      $ChatMessageEntriesTable,
      ChatMessageEntry,
      $$ChatMessageEntriesTableFilterComposer,
      $$ChatMessageEntriesTableOrderingComposer,
      $$ChatMessageEntriesTableAnnotationComposer,
      $$ChatMessageEntriesTableCreateCompanionBuilder,
      $$ChatMessageEntriesTableUpdateCompanionBuilder,
      (
        ChatMessageEntry,
        BaseReferences<
          _$LocalChatDatabase,
          $ChatMessageEntriesTable,
          ChatMessageEntry
        >,
      ),
      ChatMessageEntry,
      PrefetchHooks Function()
    >;
typedef $$ChatBlockEntriesTableCreateCompanionBuilder =
    ChatBlockEntriesCompanion Function({
      required String ownerCacheKey,
      required String userId,
      required String name,
      Value<String?> avatarUrl,
      Value<String?> learningLanguage,
      Value<String?> learningLanguageDisplay,
      Value<String?> nativeLanguage,
      Value<String?> nativeLanguageDisplay,
      Value<bool> isOnline,
      required int updatedAtMillis,
      Value<int> rowid,
    });
typedef $$ChatBlockEntriesTableUpdateCompanionBuilder =
    ChatBlockEntriesCompanion Function({
      Value<String> ownerCacheKey,
      Value<String> userId,
      Value<String> name,
      Value<String?> avatarUrl,
      Value<String?> learningLanguage,
      Value<String?> learningLanguageDisplay,
      Value<String?> nativeLanguage,
      Value<String?> nativeLanguageDisplay,
      Value<bool> isOnline,
      Value<int> updatedAtMillis,
      Value<int> rowid,
    });

class $$ChatBlockEntriesTableFilterComposer
    extends Composer<_$LocalChatDatabase, $ChatBlockEntriesTable> {
  $$ChatBlockEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerCacheKey => $composableBuilder(
    column: $table.ownerCacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learningLanguage => $composableBuilder(
    column: $table.learningLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learningLanguageDisplay => $composableBuilder(
    column: $table.learningLanguageDisplay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nativeLanguage => $composableBuilder(
    column: $table.nativeLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nativeLanguageDisplay => $composableBuilder(
    column: $table.nativeLanguageDisplay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOnline => $composableBuilder(
    column: $table.isOnline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatBlockEntriesTableOrderingComposer
    extends Composer<_$LocalChatDatabase, $ChatBlockEntriesTable> {
  $$ChatBlockEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerCacheKey => $composableBuilder(
    column: $table.ownerCacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learningLanguage => $composableBuilder(
    column: $table.learningLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learningLanguageDisplay => $composableBuilder(
    column: $table.learningLanguageDisplay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nativeLanguage => $composableBuilder(
    column: $table.nativeLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nativeLanguageDisplay => $composableBuilder(
    column: $table.nativeLanguageDisplay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOnline => $composableBuilder(
    column: $table.isOnline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatBlockEntriesTableAnnotationComposer
    extends Composer<_$LocalChatDatabase, $ChatBlockEntriesTable> {
  $$ChatBlockEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerCacheKey => $composableBuilder(
    column: $table.ownerCacheKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get learningLanguage => $composableBuilder(
    column: $table.learningLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get learningLanguageDisplay => $composableBuilder(
    column: $table.learningLanguageDisplay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nativeLanguage => $composableBuilder(
    column: $table.nativeLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nativeLanguageDisplay => $composableBuilder(
    column: $table.nativeLanguageDisplay,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOnline =>
      $composableBuilder(column: $table.isOnline, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );
}

class $$ChatBlockEntriesTableTableManager
    extends
        RootTableManager<
          _$LocalChatDatabase,
          $ChatBlockEntriesTable,
          ChatBlockEntry,
          $$ChatBlockEntriesTableFilterComposer,
          $$ChatBlockEntriesTableOrderingComposer,
          $$ChatBlockEntriesTableAnnotationComposer,
          $$ChatBlockEntriesTableCreateCompanionBuilder,
          $$ChatBlockEntriesTableUpdateCompanionBuilder,
          (
            ChatBlockEntry,
            BaseReferences<
              _$LocalChatDatabase,
              $ChatBlockEntriesTable,
              ChatBlockEntry
            >,
          ),
          ChatBlockEntry,
          PrefetchHooks Function()
        > {
  $$ChatBlockEntriesTableTableManager(
    _$LocalChatDatabase db,
    $ChatBlockEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatBlockEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatBlockEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatBlockEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerCacheKey = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> learningLanguage = const Value.absent(),
                Value<String?> learningLanguageDisplay = const Value.absent(),
                Value<String?> nativeLanguage = const Value.absent(),
                Value<String?> nativeLanguageDisplay = const Value.absent(),
                Value<bool> isOnline = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatBlockEntriesCompanion(
                ownerCacheKey: ownerCacheKey,
                userId: userId,
                name: name,
                avatarUrl: avatarUrl,
                learningLanguage: learningLanguage,
                learningLanguageDisplay: learningLanguageDisplay,
                nativeLanguage: nativeLanguage,
                nativeLanguageDisplay: nativeLanguageDisplay,
                isOnline: isOnline,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerCacheKey,
                required String userId,
                required String name,
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> learningLanguage = const Value.absent(),
                Value<String?> learningLanguageDisplay = const Value.absent(),
                Value<String?> nativeLanguage = const Value.absent(),
                Value<String?> nativeLanguageDisplay = const Value.absent(),
                Value<bool> isOnline = const Value.absent(),
                required int updatedAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => ChatBlockEntriesCompanion.insert(
                ownerCacheKey: ownerCacheKey,
                userId: userId,
                name: name,
                avatarUrl: avatarUrl,
                learningLanguage: learningLanguage,
                learningLanguageDisplay: learningLanguageDisplay,
                nativeLanguage: nativeLanguage,
                nativeLanguageDisplay: nativeLanguageDisplay,
                isOnline: isOnline,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatBlockEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalChatDatabase,
      $ChatBlockEntriesTable,
      ChatBlockEntry,
      $$ChatBlockEntriesTableFilterComposer,
      $$ChatBlockEntriesTableOrderingComposer,
      $$ChatBlockEntriesTableAnnotationComposer,
      $$ChatBlockEntriesTableCreateCompanionBuilder,
      $$ChatBlockEntriesTableUpdateCompanionBuilder,
      (
        ChatBlockEntry,
        BaseReferences<
          _$LocalChatDatabase,
          $ChatBlockEntriesTable,
          ChatBlockEntry
        >,
      ),
      ChatBlockEntry,
      PrefetchHooks Function()
    >;

class $LocalChatDatabaseManager {
  final _$LocalChatDatabase _db;
  $LocalChatDatabaseManager(this._db);
  $$ChatThreadEntriesTableTableManager get chatThreadEntries =>
      $$ChatThreadEntriesTableTableManager(_db, _db.chatThreadEntries);
  $$ChatUserEntriesTableTableManager get chatUserEntries =>
      $$ChatUserEntriesTableTableManager(_db, _db.chatUserEntries);
  $$ChatMessageEntriesTableTableManager get chatMessageEntries =>
      $$ChatMessageEntriesTableTableManager(_db, _db.chatMessageEntries);
  $$ChatBlockEntriesTableTableManager get chatBlockEntries =>
      $$ChatBlockEntriesTableTableManager(_db, _db.chatBlockEntries);
}
