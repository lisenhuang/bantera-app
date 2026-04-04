// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_practice_database.dart';

// ignore_for_file: type=lint
class $LocalPracticeEntriesTable extends LocalPracticeEntries
    with TableInfo<$LocalPracticeEntriesTable, LocalPracticeEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPracticeEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transcriptPreviewMeta = const VerificationMeta(
    'transcriptPreview',
  );
  @override
  late final GeneratedColumn<String> transcriptPreview =
      GeneratedColumn<String>(
        'transcript_preview',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localVideoPathMeta = const VerificationMeta(
    'localVideoPath',
  );
  @override
  late final GeneratedColumn<String> localVideoPath = GeneratedColumn<String>(
    'local_video_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spokenLanguageMeta = const VerificationMeta(
    'spokenLanguage',
  );
  @override
  late final GeneratedColumn<String> spokenLanguage = GeneratedColumn<String>(
    'spoken_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accentMeta = const VerificationMeta('accent');
  @override
  late final GeneratedColumn<String> accent = GeneratedColumn<String>(
    'accent',
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
  static const VerificationMeta _cueCountMeta = const VerificationMeta(
    'cueCount',
  );
  @override
  late final GeneratedColumn<int> cueCount = GeneratedColumn<int>(
    'cue_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
    'file_size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transcriptionSourceMeta =
      const VerificationMeta('transcriptionSource');
  @override
  late final GeneratedColumn<String> transcriptionSource =
      GeneratedColumn<String>(
        'transcription_source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _translatedLanguageMeta =
      const VerificationMeta('translatedLanguage');
  @override
  late final GeneratedColumn<String> translatedLanguage =
      GeneratedColumn<String>(
        'translated_language',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
  static const VerificationMeta _lastOpenedAtMillisMeta =
      const VerificationMeta('lastOpenedAtMillis');
  @override
  late final GeneratedColumn<int> lastOpenedAtMillis = GeneratedColumn<int>(
    'last_opened_at_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerCacheKey,
    title,
    transcriptPreview,
    description,
    localVideoPath,
    spokenLanguage,
    accent,
    durationMs,
    cueCount,
    fileSizeBytes,
    transcriptionSource,
    translatedLanguage,
    createdAtMillis,
    updatedAtMillis,
    lastOpenedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_practice_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPracticeEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
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
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('transcript_preview')) {
      context.handle(
        _transcriptPreviewMeta,
        transcriptPreview.isAcceptableOrUnknown(
          data['transcript_preview']!,
          _transcriptPreviewMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transcriptPreviewMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('local_video_path')) {
      context.handle(
        _localVideoPathMeta,
        localVideoPath.isAcceptableOrUnknown(
          data['local_video_path']!,
          _localVideoPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localVideoPathMeta);
    }
    if (data.containsKey('spoken_language')) {
      context.handle(
        _spokenLanguageMeta,
        spokenLanguage.isAcceptableOrUnknown(
          data['spoken_language']!,
          _spokenLanguageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_spokenLanguageMeta);
    }
    if (data.containsKey('accent')) {
      context.handle(
        _accentMeta,
        accent.isAcceptableOrUnknown(data['accent']!, _accentMeta),
      );
    } else if (isInserting) {
      context.missing(_accentMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('cue_count')) {
      context.handle(
        _cueCountMeta,
        cueCount.isAcceptableOrUnknown(data['cue_count']!, _cueCountMeta),
      );
    } else if (isInserting) {
      context.missing(_cueCountMeta);
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fileSizeBytesMeta);
    }
    if (data.containsKey('transcription_source')) {
      context.handle(
        _transcriptionSourceMeta,
        transcriptionSource.isAcceptableOrUnknown(
          data['transcription_source']!,
          _transcriptionSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transcriptionSourceMeta);
    }
    if (data.containsKey('translated_language')) {
      context.handle(
        _translatedLanguageMeta,
        translatedLanguage.isAcceptableOrUnknown(
          data['translated_language']!,
          _translatedLanguageMeta,
        ),
      );
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
    if (data.containsKey('last_opened_at_millis')) {
      context.handle(
        _lastOpenedAtMillisMeta,
        lastOpenedAtMillis.isAcceptableOrUnknown(
          data['last_opened_at_millis']!,
          _lastOpenedAtMillisMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPracticeEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPracticeEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerCacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_cache_key'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      transcriptPreview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript_preview'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      localVideoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_video_path'],
      )!,
      spokenLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spoken_language'],
      )!,
      accent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accent'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      cueCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cue_count'],
      )!,
      fileSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size_bytes'],
      )!,
      transcriptionSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcription_source'],
      )!,
      translatedLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translated_language'],
      ),
      createdAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_millis'],
      )!,
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_millis'],
      )!,
      lastOpenedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_opened_at_millis'],
      ),
    );
  }

  @override
  $LocalPracticeEntriesTable createAlias(String alias) {
    return $LocalPracticeEntriesTable(attachedDatabase, alias);
  }
}

class LocalPracticeEntry extends DataClass
    implements Insertable<LocalPracticeEntry> {
  final String id;
  final String ownerCacheKey;
  final String title;
  final String transcriptPreview;
  final String description;
  final String localVideoPath;
  final String spokenLanguage;
  final String accent;
  final int durationMs;
  final int cueCount;
  final int fileSizeBytes;
  final String transcriptionSource;
  final String? translatedLanguage;
  final int createdAtMillis;
  final int updatedAtMillis;
  final int? lastOpenedAtMillis;
  const LocalPracticeEntry({
    required this.id,
    required this.ownerCacheKey,
    required this.title,
    required this.transcriptPreview,
    required this.description,
    required this.localVideoPath,
    required this.spokenLanguage,
    required this.accent,
    required this.durationMs,
    required this.cueCount,
    required this.fileSizeBytes,
    required this.transcriptionSource,
    this.translatedLanguage,
    required this.createdAtMillis,
    required this.updatedAtMillis,
    this.lastOpenedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_cache_key'] = Variable<String>(ownerCacheKey);
    map['title'] = Variable<String>(title);
    map['transcript_preview'] = Variable<String>(transcriptPreview);
    map['description'] = Variable<String>(description);
    map['local_video_path'] = Variable<String>(localVideoPath);
    map['spoken_language'] = Variable<String>(spokenLanguage);
    map['accent'] = Variable<String>(accent);
    map['duration_ms'] = Variable<int>(durationMs);
    map['cue_count'] = Variable<int>(cueCount);
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    map['transcription_source'] = Variable<String>(transcriptionSource);
    if (!nullToAbsent || translatedLanguage != null) {
      map['translated_language'] = Variable<String>(translatedLanguage);
    }
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    if (!nullToAbsent || lastOpenedAtMillis != null) {
      map['last_opened_at_millis'] = Variable<int>(lastOpenedAtMillis);
    }
    return map;
  }

  LocalPracticeEntriesCompanion toCompanion(bool nullToAbsent) {
    return LocalPracticeEntriesCompanion(
      id: Value(id),
      ownerCacheKey: Value(ownerCacheKey),
      title: Value(title),
      transcriptPreview: Value(transcriptPreview),
      description: Value(description),
      localVideoPath: Value(localVideoPath),
      spokenLanguage: Value(spokenLanguage),
      accent: Value(accent),
      durationMs: Value(durationMs),
      cueCount: Value(cueCount),
      fileSizeBytes: Value(fileSizeBytes),
      transcriptionSource: Value(transcriptionSource),
      translatedLanguage: translatedLanguage == null && nullToAbsent
          ? const Value.absent()
          : Value(translatedLanguage),
      createdAtMillis: Value(createdAtMillis),
      updatedAtMillis: Value(updatedAtMillis),
      lastOpenedAtMillis: lastOpenedAtMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOpenedAtMillis),
    );
  }

  factory LocalPracticeEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPracticeEntry(
      id: serializer.fromJson<String>(json['id']),
      ownerCacheKey: serializer.fromJson<String>(json['ownerCacheKey']),
      title: serializer.fromJson<String>(json['title']),
      transcriptPreview: serializer.fromJson<String>(json['transcriptPreview']),
      description: serializer.fromJson<String>(json['description']),
      localVideoPath: serializer.fromJson<String>(json['localVideoPath']),
      spokenLanguage: serializer.fromJson<String>(json['spokenLanguage']),
      accent: serializer.fromJson<String>(json['accent']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      cueCount: serializer.fromJson<int>(json['cueCount']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      transcriptionSource: serializer.fromJson<String>(
        json['transcriptionSource'],
      ),
      translatedLanguage: serializer.fromJson<String?>(
        json['translatedLanguage'],
      ),
      createdAtMillis: serializer.fromJson<int>(json['createdAtMillis']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
      lastOpenedAtMillis: serializer.fromJson<int?>(json['lastOpenedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerCacheKey': serializer.toJson<String>(ownerCacheKey),
      'title': serializer.toJson<String>(title),
      'transcriptPreview': serializer.toJson<String>(transcriptPreview),
      'description': serializer.toJson<String>(description),
      'localVideoPath': serializer.toJson<String>(localVideoPath),
      'spokenLanguage': serializer.toJson<String>(spokenLanguage),
      'accent': serializer.toJson<String>(accent),
      'durationMs': serializer.toJson<int>(durationMs),
      'cueCount': serializer.toJson<int>(cueCount),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'transcriptionSource': serializer.toJson<String>(transcriptionSource),
      'translatedLanguage': serializer.toJson<String?>(translatedLanguage),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
      'lastOpenedAtMillis': serializer.toJson<int?>(lastOpenedAtMillis),
    };
  }

  LocalPracticeEntry copyWith({
    String? id,
    String? ownerCacheKey,
    String? title,
    String? transcriptPreview,
    String? description,
    String? localVideoPath,
    String? spokenLanguage,
    String? accent,
    int? durationMs,
    int? cueCount,
    int? fileSizeBytes,
    String? transcriptionSource,
    Value<String?> translatedLanguage = const Value.absent(),
    int? createdAtMillis,
    int? updatedAtMillis,
    Value<int?> lastOpenedAtMillis = const Value.absent(),
  }) => LocalPracticeEntry(
    id: id ?? this.id,
    ownerCacheKey: ownerCacheKey ?? this.ownerCacheKey,
    title: title ?? this.title,
    transcriptPreview: transcriptPreview ?? this.transcriptPreview,
    description: description ?? this.description,
    localVideoPath: localVideoPath ?? this.localVideoPath,
    spokenLanguage: spokenLanguage ?? this.spokenLanguage,
    accent: accent ?? this.accent,
    durationMs: durationMs ?? this.durationMs,
    cueCount: cueCount ?? this.cueCount,
    fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    transcriptionSource: transcriptionSource ?? this.transcriptionSource,
    translatedLanguage: translatedLanguage.present
        ? translatedLanguage.value
        : this.translatedLanguage,
    createdAtMillis: createdAtMillis ?? this.createdAtMillis,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
    lastOpenedAtMillis: lastOpenedAtMillis.present
        ? lastOpenedAtMillis.value
        : this.lastOpenedAtMillis,
  );
  LocalPracticeEntry copyWithCompanion(LocalPracticeEntriesCompanion data) {
    return LocalPracticeEntry(
      id: data.id.present ? data.id.value : this.id,
      ownerCacheKey: data.ownerCacheKey.present
          ? data.ownerCacheKey.value
          : this.ownerCacheKey,
      title: data.title.present ? data.title.value : this.title,
      transcriptPreview: data.transcriptPreview.present
          ? data.transcriptPreview.value
          : this.transcriptPreview,
      description: data.description.present
          ? data.description.value
          : this.description,
      localVideoPath: data.localVideoPath.present
          ? data.localVideoPath.value
          : this.localVideoPath,
      spokenLanguage: data.spokenLanguage.present
          ? data.spokenLanguage.value
          : this.spokenLanguage,
      accent: data.accent.present ? data.accent.value : this.accent,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      cueCount: data.cueCount.present ? data.cueCount.value : this.cueCount,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      transcriptionSource: data.transcriptionSource.present
          ? data.transcriptionSource.value
          : this.transcriptionSource,
      translatedLanguage: data.translatedLanguage.present
          ? data.translatedLanguage.value
          : this.translatedLanguage,
      createdAtMillis: data.createdAtMillis.present
          ? data.createdAtMillis.value
          : this.createdAtMillis,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
      lastOpenedAtMillis: data.lastOpenedAtMillis.present
          ? data.lastOpenedAtMillis.value
          : this.lastOpenedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPracticeEntry(')
          ..write('id: $id, ')
          ..write('ownerCacheKey: $ownerCacheKey, ')
          ..write('title: $title, ')
          ..write('transcriptPreview: $transcriptPreview, ')
          ..write('description: $description, ')
          ..write('localVideoPath: $localVideoPath, ')
          ..write('spokenLanguage: $spokenLanguage, ')
          ..write('accent: $accent, ')
          ..write('durationMs: $durationMs, ')
          ..write('cueCount: $cueCount, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('transcriptionSource: $transcriptionSource, ')
          ..write('translatedLanguage: $translatedLanguage, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('lastOpenedAtMillis: $lastOpenedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerCacheKey,
    title,
    transcriptPreview,
    description,
    localVideoPath,
    spokenLanguage,
    accent,
    durationMs,
    cueCount,
    fileSizeBytes,
    transcriptionSource,
    translatedLanguage,
    createdAtMillis,
    updatedAtMillis,
    lastOpenedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPracticeEntry &&
          other.id == this.id &&
          other.ownerCacheKey == this.ownerCacheKey &&
          other.title == this.title &&
          other.transcriptPreview == this.transcriptPreview &&
          other.description == this.description &&
          other.localVideoPath == this.localVideoPath &&
          other.spokenLanguage == this.spokenLanguage &&
          other.accent == this.accent &&
          other.durationMs == this.durationMs &&
          other.cueCount == this.cueCount &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.transcriptionSource == this.transcriptionSource &&
          other.translatedLanguage == this.translatedLanguage &&
          other.createdAtMillis == this.createdAtMillis &&
          other.updatedAtMillis == this.updatedAtMillis &&
          other.lastOpenedAtMillis == this.lastOpenedAtMillis);
}

class LocalPracticeEntriesCompanion
    extends UpdateCompanion<LocalPracticeEntry> {
  final Value<String> id;
  final Value<String> ownerCacheKey;
  final Value<String> title;
  final Value<String> transcriptPreview;
  final Value<String> description;
  final Value<String> localVideoPath;
  final Value<String> spokenLanguage;
  final Value<String> accent;
  final Value<int> durationMs;
  final Value<int> cueCount;
  final Value<int> fileSizeBytes;
  final Value<String> transcriptionSource;
  final Value<String?> translatedLanguage;
  final Value<int> createdAtMillis;
  final Value<int> updatedAtMillis;
  final Value<int?> lastOpenedAtMillis;
  final Value<int> rowid;
  const LocalPracticeEntriesCompanion({
    this.id = const Value.absent(),
    this.ownerCacheKey = const Value.absent(),
    this.title = const Value.absent(),
    this.transcriptPreview = const Value.absent(),
    this.description = const Value.absent(),
    this.localVideoPath = const Value.absent(),
    this.spokenLanguage = const Value.absent(),
    this.accent = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.cueCount = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.transcriptionSource = const Value.absent(),
    this.translatedLanguage = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.lastOpenedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPracticeEntriesCompanion.insert({
    required String id,
    required String ownerCacheKey,
    required String title,
    required String transcriptPreview,
    required String description,
    required String localVideoPath,
    required String spokenLanguage,
    required String accent,
    required int durationMs,
    required int cueCount,
    required int fileSizeBytes,
    required String transcriptionSource,
    this.translatedLanguage = const Value.absent(),
    required int createdAtMillis,
    required int updatedAtMillis,
    this.lastOpenedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerCacheKey = Value(ownerCacheKey),
       title = Value(title),
       transcriptPreview = Value(transcriptPreview),
       description = Value(description),
       localVideoPath = Value(localVideoPath),
       spokenLanguage = Value(spokenLanguage),
       accent = Value(accent),
       durationMs = Value(durationMs),
       cueCount = Value(cueCount),
       fileSizeBytes = Value(fileSizeBytes),
       transcriptionSource = Value(transcriptionSource),
       createdAtMillis = Value(createdAtMillis),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<LocalPracticeEntry> custom({
    Expression<String>? id,
    Expression<String>? ownerCacheKey,
    Expression<String>? title,
    Expression<String>? transcriptPreview,
    Expression<String>? description,
    Expression<String>? localVideoPath,
    Expression<String>? spokenLanguage,
    Expression<String>? accent,
    Expression<int>? durationMs,
    Expression<int>? cueCount,
    Expression<int>? fileSizeBytes,
    Expression<String>? transcriptionSource,
    Expression<String>? translatedLanguage,
    Expression<int>? createdAtMillis,
    Expression<int>? updatedAtMillis,
    Expression<int>? lastOpenedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerCacheKey != null) 'owner_cache_key': ownerCacheKey,
      if (title != null) 'title': title,
      if (transcriptPreview != null) 'transcript_preview': transcriptPreview,
      if (description != null) 'description': description,
      if (localVideoPath != null) 'local_video_path': localVideoPath,
      if (spokenLanguage != null) 'spoken_language': spokenLanguage,
      if (accent != null) 'accent': accent,
      if (durationMs != null) 'duration_ms': durationMs,
      if (cueCount != null) 'cue_count': cueCount,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (transcriptionSource != null)
        'transcription_source': transcriptionSource,
      if (translatedLanguage != null) 'translated_language': translatedLanguage,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (lastOpenedAtMillis != null)
        'last_opened_at_millis': lastOpenedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPracticeEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerCacheKey,
    Value<String>? title,
    Value<String>? transcriptPreview,
    Value<String>? description,
    Value<String>? localVideoPath,
    Value<String>? spokenLanguage,
    Value<String>? accent,
    Value<int>? durationMs,
    Value<int>? cueCount,
    Value<int>? fileSizeBytes,
    Value<String>? transcriptionSource,
    Value<String?>? translatedLanguage,
    Value<int>? createdAtMillis,
    Value<int>? updatedAtMillis,
    Value<int?>? lastOpenedAtMillis,
    Value<int>? rowid,
  }) {
    return LocalPracticeEntriesCompanion(
      id: id ?? this.id,
      ownerCacheKey: ownerCacheKey ?? this.ownerCacheKey,
      title: title ?? this.title,
      transcriptPreview: transcriptPreview ?? this.transcriptPreview,
      description: description ?? this.description,
      localVideoPath: localVideoPath ?? this.localVideoPath,
      spokenLanguage: spokenLanguage ?? this.spokenLanguage,
      accent: accent ?? this.accent,
      durationMs: durationMs ?? this.durationMs,
      cueCount: cueCount ?? this.cueCount,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      transcriptionSource: transcriptionSource ?? this.transcriptionSource,
      translatedLanguage: translatedLanguage ?? this.translatedLanguage,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      lastOpenedAtMillis: lastOpenedAtMillis ?? this.lastOpenedAtMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerCacheKey.present) {
      map['owner_cache_key'] = Variable<String>(ownerCacheKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (transcriptPreview.present) {
      map['transcript_preview'] = Variable<String>(transcriptPreview.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (localVideoPath.present) {
      map['local_video_path'] = Variable<String>(localVideoPath.value);
    }
    if (spokenLanguage.present) {
      map['spoken_language'] = Variable<String>(spokenLanguage.value);
    }
    if (accent.present) {
      map['accent'] = Variable<String>(accent.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (cueCount.present) {
      map['cue_count'] = Variable<int>(cueCount.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (transcriptionSource.present) {
      map['transcription_source'] = Variable<String>(transcriptionSource.value);
    }
    if (translatedLanguage.present) {
      map['translated_language'] = Variable<String>(translatedLanguage.value);
    }
    if (createdAtMillis.present) {
      map['created_at_millis'] = Variable<int>(createdAtMillis.value);
    }
    if (updatedAtMillis.present) {
      map['updated_at_millis'] = Variable<int>(updatedAtMillis.value);
    }
    if (lastOpenedAtMillis.present) {
      map['last_opened_at_millis'] = Variable<int>(lastOpenedAtMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPracticeEntriesCompanion(')
          ..write('id: $id, ')
          ..write('ownerCacheKey: $ownerCacheKey, ')
          ..write('title: $title, ')
          ..write('transcriptPreview: $transcriptPreview, ')
          ..write('description: $description, ')
          ..write('localVideoPath: $localVideoPath, ')
          ..write('spokenLanguage: $spokenLanguage, ')
          ..write('accent: $accent, ')
          ..write('durationMs: $durationMs, ')
          ..write('cueCount: $cueCount, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('transcriptionSource: $transcriptionSource, ')
          ..write('translatedLanguage: $translatedLanguage, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('lastOpenedAtMillis: $lastOpenedAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPracticeCueEntriesTable extends LocalPracticeCueEntries
    with TableInfo<$LocalPracticeCueEntriesTable, LocalPracticeCueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPracticeCueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_practice_entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _cueIndexMeta = const VerificationMeta(
    'cueIndex',
  );
  @override
  late final GeneratedColumn<int> cueIndex = GeneratedColumn<int>(
    'cue_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMsMeta = const VerificationMeta(
    'startTimeMs',
  );
  @override
  late final GeneratedColumn<int> startTimeMs = GeneratedColumn<int>(
    'start_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMsMeta = const VerificationMeta(
    'endTimeMs',
  );
  @override
  late final GeneratedColumn<int> endTimeMs = GeneratedColumn<int>(
    'end_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalTextMeta = const VerificationMeta(
    'originalText',
  );
  @override
  late final GeneratedColumn<String> originalText = GeneratedColumn<String>(
    'original_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translatedTextMeta = const VerificationMeta(
    'translatedText',
  );
  @override
  late final GeneratedColumn<String> translatedText = GeneratedColumn<String>(
    'translated_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    cueIndex,
    startTimeMs,
    endTimeMs,
    originalText,
    translatedText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_practice_cue_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPracticeCueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('cue_index')) {
      context.handle(
        _cueIndexMeta,
        cueIndex.isAcceptableOrUnknown(data['cue_index']!, _cueIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_cueIndexMeta);
    }
    if (data.containsKey('start_time_ms')) {
      context.handle(
        _startTimeMsMeta,
        startTimeMs.isAcceptableOrUnknown(
          data['start_time_ms']!,
          _startTimeMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startTimeMsMeta);
    }
    if (data.containsKey('end_time_ms')) {
      context.handle(
        _endTimeMsMeta,
        endTimeMs.isAcceptableOrUnknown(data['end_time_ms']!, _endTimeMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMsMeta);
    }
    if (data.containsKey('original_text')) {
      context.handle(
        _originalTextMeta,
        originalText.isAcceptableOrUnknown(
          data['original_text']!,
          _originalTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalTextMeta);
    }
    if (data.containsKey('translated_text')) {
      context.handle(
        _translatedTextMeta,
        translatedText.isAcceptableOrUnknown(
          data['translated_text']!,
          _translatedTextMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPracticeCueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPracticeCueEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      cueIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cue_index'],
      )!,
      startTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time_ms'],
      )!,
      endTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_time_ms'],
      )!,
      originalText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_text'],
      )!,
      translatedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translated_text'],
      )!,
    );
  }

  @override
  $LocalPracticeCueEntriesTable createAlias(String alias) {
    return $LocalPracticeCueEntriesTable(attachedDatabase, alias);
  }
}

class LocalPracticeCueEntry extends DataClass
    implements Insertable<LocalPracticeCueEntry> {
  final String id;
  final String itemId;
  final int cueIndex;
  final int startTimeMs;
  final int endTimeMs;
  final String originalText;
  final String translatedText;
  const LocalPracticeCueEntry({
    required this.id,
    required this.itemId,
    required this.cueIndex,
    required this.startTimeMs,
    required this.endTimeMs,
    required this.originalText,
    required this.translatedText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['cue_index'] = Variable<int>(cueIndex);
    map['start_time_ms'] = Variable<int>(startTimeMs);
    map['end_time_ms'] = Variable<int>(endTimeMs);
    map['original_text'] = Variable<String>(originalText);
    map['translated_text'] = Variable<String>(translatedText);
    return map;
  }

  LocalPracticeCueEntriesCompanion toCompanion(bool nullToAbsent) {
    return LocalPracticeCueEntriesCompanion(
      id: Value(id),
      itemId: Value(itemId),
      cueIndex: Value(cueIndex),
      startTimeMs: Value(startTimeMs),
      endTimeMs: Value(endTimeMs),
      originalText: Value(originalText),
      translatedText: Value(translatedText),
    );
  }

  factory LocalPracticeCueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPracticeCueEntry(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      cueIndex: serializer.fromJson<int>(json['cueIndex']),
      startTimeMs: serializer.fromJson<int>(json['startTimeMs']),
      endTimeMs: serializer.fromJson<int>(json['endTimeMs']),
      originalText: serializer.fromJson<String>(json['originalText']),
      translatedText: serializer.fromJson<String>(json['translatedText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'cueIndex': serializer.toJson<int>(cueIndex),
      'startTimeMs': serializer.toJson<int>(startTimeMs),
      'endTimeMs': serializer.toJson<int>(endTimeMs),
      'originalText': serializer.toJson<String>(originalText),
      'translatedText': serializer.toJson<String>(translatedText),
    };
  }

  LocalPracticeCueEntry copyWith({
    String? id,
    String? itemId,
    int? cueIndex,
    int? startTimeMs,
    int? endTimeMs,
    String? originalText,
    String? translatedText,
  }) => LocalPracticeCueEntry(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    cueIndex: cueIndex ?? this.cueIndex,
    startTimeMs: startTimeMs ?? this.startTimeMs,
    endTimeMs: endTimeMs ?? this.endTimeMs,
    originalText: originalText ?? this.originalText,
    translatedText: translatedText ?? this.translatedText,
  );
  LocalPracticeCueEntry copyWithCompanion(
    LocalPracticeCueEntriesCompanion data,
  ) {
    return LocalPracticeCueEntry(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      cueIndex: data.cueIndex.present ? data.cueIndex.value : this.cueIndex,
      startTimeMs: data.startTimeMs.present
          ? data.startTimeMs.value
          : this.startTimeMs,
      endTimeMs: data.endTimeMs.present ? data.endTimeMs.value : this.endTimeMs,
      originalText: data.originalText.present
          ? data.originalText.value
          : this.originalText,
      translatedText: data.translatedText.present
          ? data.translatedText.value
          : this.translatedText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPracticeCueEntry(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('cueIndex: $cueIndex, ')
          ..write('startTimeMs: $startTimeMs, ')
          ..write('endTimeMs: $endTimeMs, ')
          ..write('originalText: $originalText, ')
          ..write('translatedText: $translatedText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    cueIndex,
    startTimeMs,
    endTimeMs,
    originalText,
    translatedText,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPracticeCueEntry &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.cueIndex == this.cueIndex &&
          other.startTimeMs == this.startTimeMs &&
          other.endTimeMs == this.endTimeMs &&
          other.originalText == this.originalText &&
          other.translatedText == this.translatedText);
}

class LocalPracticeCueEntriesCompanion
    extends UpdateCompanion<LocalPracticeCueEntry> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<int> cueIndex;
  final Value<int> startTimeMs;
  final Value<int> endTimeMs;
  final Value<String> originalText;
  final Value<String> translatedText;
  final Value<int> rowid;
  const LocalPracticeCueEntriesCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.cueIndex = const Value.absent(),
    this.startTimeMs = const Value.absent(),
    this.endTimeMs = const Value.absent(),
    this.originalText = const Value.absent(),
    this.translatedText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPracticeCueEntriesCompanion.insert({
    required String id,
    required String itemId,
    required int cueIndex,
    required int startTimeMs,
    required int endTimeMs,
    required String originalText,
    this.translatedText = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       cueIndex = Value(cueIndex),
       startTimeMs = Value(startTimeMs),
       endTimeMs = Value(endTimeMs),
       originalText = Value(originalText);
  static Insertable<LocalPracticeCueEntry> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<int>? cueIndex,
    Expression<int>? startTimeMs,
    Expression<int>? endTimeMs,
    Expression<String>? originalText,
    Expression<String>? translatedText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (cueIndex != null) 'cue_index': cueIndex,
      if (startTimeMs != null) 'start_time_ms': startTimeMs,
      if (endTimeMs != null) 'end_time_ms': endTimeMs,
      if (originalText != null) 'original_text': originalText,
      if (translatedText != null) 'translated_text': translatedText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPracticeCueEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<int>? cueIndex,
    Value<int>? startTimeMs,
    Value<int>? endTimeMs,
    Value<String>? originalText,
    Value<String>? translatedText,
    Value<int>? rowid,
  }) {
    return LocalPracticeCueEntriesCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      cueIndex: cueIndex ?? this.cueIndex,
      startTimeMs: startTimeMs ?? this.startTimeMs,
      endTimeMs: endTimeMs ?? this.endTimeMs,
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (cueIndex.present) {
      map['cue_index'] = Variable<int>(cueIndex.value);
    }
    if (startTimeMs.present) {
      map['start_time_ms'] = Variable<int>(startTimeMs.value);
    }
    if (endTimeMs.present) {
      map['end_time_ms'] = Variable<int>(endTimeMs.value);
    }
    if (originalText.present) {
      map['original_text'] = Variable<String>(originalText.value);
    }
    if (translatedText.present) {
      map['translated_text'] = Variable<String>(translatedText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPracticeCueEntriesCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('cueIndex: $cueIndex, ')
          ..write('startTimeMs: $startTimeMs, ')
          ..write('endTimeMs: $endTimeMs, ')
          ..write('originalText: $originalText, ')
          ..write('translatedText: $translatedText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalPracticeDatabase extends GeneratedDatabase {
  _$LocalPracticeDatabase(QueryExecutor e) : super(e);
  $LocalPracticeDatabaseManager get managers =>
      $LocalPracticeDatabaseManager(this);
  late final $LocalPracticeEntriesTable localPracticeEntries =
      $LocalPracticeEntriesTable(this);
  late final $LocalPracticeCueEntriesTable localPracticeCueEntries =
      $LocalPracticeCueEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localPracticeEntries,
    localPracticeCueEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'local_practice_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('local_practice_cue_entries', kind: UpdateKind.delete),
      ],
    ),
  ]);
}

typedef $$LocalPracticeEntriesTableCreateCompanionBuilder =
    LocalPracticeEntriesCompanion Function({
      required String id,
      required String ownerCacheKey,
      required String title,
      required String transcriptPreview,
      required String description,
      required String localVideoPath,
      required String spokenLanguage,
      required String accent,
      required int durationMs,
      required int cueCount,
      required int fileSizeBytes,
      required String transcriptionSource,
      Value<String?> translatedLanguage,
      required int createdAtMillis,
      required int updatedAtMillis,
      Value<int?> lastOpenedAtMillis,
      Value<int> rowid,
    });
typedef $$LocalPracticeEntriesTableUpdateCompanionBuilder =
    LocalPracticeEntriesCompanion Function({
      Value<String> id,
      Value<String> ownerCacheKey,
      Value<String> title,
      Value<String> transcriptPreview,
      Value<String> description,
      Value<String> localVideoPath,
      Value<String> spokenLanguage,
      Value<String> accent,
      Value<int> durationMs,
      Value<int> cueCount,
      Value<int> fileSizeBytes,
      Value<String> transcriptionSource,
      Value<String?> translatedLanguage,
      Value<int> createdAtMillis,
      Value<int> updatedAtMillis,
      Value<int?> lastOpenedAtMillis,
      Value<int> rowid,
    });

final class $$LocalPracticeEntriesTableReferences
    extends
        BaseReferences<
          _$LocalPracticeDatabase,
          $LocalPracticeEntriesTable,
          LocalPracticeEntry
        > {
  $$LocalPracticeEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $LocalPracticeCueEntriesTable,
    List<LocalPracticeCueEntry>
  >
  _localPracticeCueEntriesRefsTable(_$LocalPracticeDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.localPracticeCueEntries,
        aliasName: $_aliasNameGenerator(
          db.localPracticeEntries.id,
          db.localPracticeCueEntries.itemId,
        ),
      );

  $$LocalPracticeCueEntriesTableProcessedTableManager
  get localPracticeCueEntriesRefs {
    final manager = $$LocalPracticeCueEntriesTableTableManager(
      $_db,
      $_db.localPracticeCueEntries,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _localPracticeCueEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalPracticeEntriesTableFilterComposer
    extends Composer<_$LocalPracticeDatabase, $LocalPracticeEntriesTable> {
  $$LocalPracticeEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerCacheKey => $composableBuilder(
    column: $table.ownerCacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcriptPreview => $composableBuilder(
    column: $table.transcriptPreview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localVideoPath => $composableBuilder(
    column: $table.localVideoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spokenLanguage => $composableBuilder(
    column: $table.spokenLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accent => $composableBuilder(
    column: $table.accent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cueCount => $composableBuilder(
    column: $table.cueCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcriptionSource => $composableBuilder(
    column: $table.transcriptionSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translatedLanguage => $composableBuilder(
    column: $table.translatedLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastOpenedAtMillis => $composableBuilder(
    column: $table.lastOpenedAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> localPracticeCueEntriesRefs(
    Expression<bool> Function($$LocalPracticeCueEntriesTableFilterComposer f) f,
  ) {
    final $$LocalPracticeCueEntriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localPracticeCueEntries,
          getReferencedColumn: (t) => t.itemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalPracticeCueEntriesTableFilterComposer(
                $db: $db,
                $table: $db.localPracticeCueEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LocalPracticeEntriesTableOrderingComposer
    extends Composer<_$LocalPracticeDatabase, $LocalPracticeEntriesTable> {
  $$LocalPracticeEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerCacheKey => $composableBuilder(
    column: $table.ownerCacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcriptPreview => $composableBuilder(
    column: $table.transcriptPreview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localVideoPath => $composableBuilder(
    column: $table.localVideoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spokenLanguage => $composableBuilder(
    column: $table.spokenLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accent => $composableBuilder(
    column: $table.accent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cueCount => $composableBuilder(
    column: $table.cueCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcriptionSource => $composableBuilder(
    column: $table.transcriptionSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translatedLanguage => $composableBuilder(
    column: $table.translatedLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastOpenedAtMillis => $composableBuilder(
    column: $table.lastOpenedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPracticeEntriesTableAnnotationComposer
    extends Composer<_$LocalPracticeDatabase, $LocalPracticeEntriesTable> {
  $$LocalPracticeEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerCacheKey => $composableBuilder(
    column: $table.ownerCacheKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get transcriptPreview => $composableBuilder(
    column: $table.transcriptPreview,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localVideoPath => $composableBuilder(
    column: $table.localVideoPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get spokenLanguage => $composableBuilder(
    column: $table.spokenLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accent =>
      $composableBuilder(column: $table.accent, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cueCount =>
      $composableBuilder(column: $table.cueCount, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transcriptionSource => $composableBuilder(
    column: $table.transcriptionSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translatedLanguage => $composableBuilder(
    column: $table.translatedLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastOpenedAtMillis => $composableBuilder(
    column: $table.lastOpenedAtMillis,
    builder: (column) => column,
  );

  Expression<T> localPracticeCueEntriesRefs<T extends Object>(
    Expression<T> Function($$LocalPracticeCueEntriesTableAnnotationComposer a)
    f,
  ) {
    final $$LocalPracticeCueEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localPracticeCueEntries,
          getReferencedColumn: (t) => t.itemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalPracticeCueEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.localPracticeCueEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LocalPracticeEntriesTableTableManager
    extends
        RootTableManager<
          _$LocalPracticeDatabase,
          $LocalPracticeEntriesTable,
          LocalPracticeEntry,
          $$LocalPracticeEntriesTableFilterComposer,
          $$LocalPracticeEntriesTableOrderingComposer,
          $$LocalPracticeEntriesTableAnnotationComposer,
          $$LocalPracticeEntriesTableCreateCompanionBuilder,
          $$LocalPracticeEntriesTableUpdateCompanionBuilder,
          (LocalPracticeEntry, $$LocalPracticeEntriesTableReferences),
          LocalPracticeEntry,
          PrefetchHooks Function({bool localPracticeCueEntriesRefs})
        > {
  $$LocalPracticeEntriesTableTableManager(
    _$LocalPracticeDatabase db,
    $LocalPracticeEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPracticeEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPracticeEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalPracticeEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerCacheKey = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> transcriptPreview = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> localVideoPath = const Value.absent(),
                Value<String> spokenLanguage = const Value.absent(),
                Value<String> accent = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> cueCount = const Value.absent(),
                Value<int> fileSizeBytes = const Value.absent(),
                Value<String> transcriptionSource = const Value.absent(),
                Value<String?> translatedLanguage = const Value.absent(),
                Value<int> createdAtMillis = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<int?> lastOpenedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPracticeEntriesCompanion(
                id: id,
                ownerCacheKey: ownerCacheKey,
                title: title,
                transcriptPreview: transcriptPreview,
                description: description,
                localVideoPath: localVideoPath,
                spokenLanguage: spokenLanguage,
                accent: accent,
                durationMs: durationMs,
                cueCount: cueCount,
                fileSizeBytes: fileSizeBytes,
                transcriptionSource: transcriptionSource,
                translatedLanguage: translatedLanguage,
                createdAtMillis: createdAtMillis,
                updatedAtMillis: updatedAtMillis,
                lastOpenedAtMillis: lastOpenedAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerCacheKey,
                required String title,
                required String transcriptPreview,
                required String description,
                required String localVideoPath,
                required String spokenLanguage,
                required String accent,
                required int durationMs,
                required int cueCount,
                required int fileSizeBytes,
                required String transcriptionSource,
                Value<String?> translatedLanguage = const Value.absent(),
                required int createdAtMillis,
                required int updatedAtMillis,
                Value<int?> lastOpenedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPracticeEntriesCompanion.insert(
                id: id,
                ownerCacheKey: ownerCacheKey,
                title: title,
                transcriptPreview: transcriptPreview,
                description: description,
                localVideoPath: localVideoPath,
                spokenLanguage: spokenLanguage,
                accent: accent,
                durationMs: durationMs,
                cueCount: cueCount,
                fileSizeBytes: fileSizeBytes,
                transcriptionSource: transcriptionSource,
                translatedLanguage: translatedLanguage,
                createdAtMillis: createdAtMillis,
                updatedAtMillis: updatedAtMillis,
                lastOpenedAtMillis: lastOpenedAtMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalPracticeEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({localPracticeCueEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (localPracticeCueEntriesRefs) db.localPracticeCueEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (localPracticeCueEntriesRefs)
                    await $_getPrefetchedData<
                      LocalPracticeEntry,
                      $LocalPracticeEntriesTable,
                      LocalPracticeCueEntry
                    >(
                      currentTable: table,
                      referencedTable: $$LocalPracticeEntriesTableReferences
                          ._localPracticeCueEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LocalPracticeEntriesTableReferences(
                            db,
                            table,
                            p0,
                          ).localPracticeCueEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LocalPracticeEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalPracticeDatabase,
      $LocalPracticeEntriesTable,
      LocalPracticeEntry,
      $$LocalPracticeEntriesTableFilterComposer,
      $$LocalPracticeEntriesTableOrderingComposer,
      $$LocalPracticeEntriesTableAnnotationComposer,
      $$LocalPracticeEntriesTableCreateCompanionBuilder,
      $$LocalPracticeEntriesTableUpdateCompanionBuilder,
      (LocalPracticeEntry, $$LocalPracticeEntriesTableReferences),
      LocalPracticeEntry,
      PrefetchHooks Function({bool localPracticeCueEntriesRefs})
    >;
typedef $$LocalPracticeCueEntriesTableCreateCompanionBuilder =
    LocalPracticeCueEntriesCompanion Function({
      required String id,
      required String itemId,
      required int cueIndex,
      required int startTimeMs,
      required int endTimeMs,
      required String originalText,
      Value<String> translatedText,
      Value<int> rowid,
    });
typedef $$LocalPracticeCueEntriesTableUpdateCompanionBuilder =
    LocalPracticeCueEntriesCompanion Function({
      Value<String> id,
      Value<String> itemId,
      Value<int> cueIndex,
      Value<int> startTimeMs,
      Value<int> endTimeMs,
      Value<String> originalText,
      Value<String> translatedText,
      Value<int> rowid,
    });

final class $$LocalPracticeCueEntriesTableReferences
    extends
        BaseReferences<
          _$LocalPracticeDatabase,
          $LocalPracticeCueEntriesTable,
          LocalPracticeCueEntry
        > {
  $$LocalPracticeCueEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalPracticeEntriesTable _itemIdTable(_$LocalPracticeDatabase db) =>
      db.localPracticeEntries.createAlias(
        $_aliasNameGenerator(
          db.localPracticeCueEntries.itemId,
          db.localPracticeEntries.id,
        ),
      );

  $$LocalPracticeEntriesTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$LocalPracticeEntriesTableTableManager(
      $_db,
      $_db.localPracticeEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalPracticeCueEntriesTableFilterComposer
    extends Composer<_$LocalPracticeDatabase, $LocalPracticeCueEntriesTable> {
  $$LocalPracticeCueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cueIndex => $composableBuilder(
    column: $table.cueIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTimeMs => $composableBuilder(
    column: $table.startTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endTimeMs => $composableBuilder(
    column: $table.endTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalText => $composableBuilder(
    column: $table.originalText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translatedText => $composableBuilder(
    column: $table.translatedText,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalPracticeEntriesTableFilterComposer get itemId {
    final $$LocalPracticeEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.localPracticeEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalPracticeEntriesTableFilterComposer(
            $db: $db,
            $table: $db.localPracticeEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalPracticeCueEntriesTableOrderingComposer
    extends Composer<_$LocalPracticeDatabase, $LocalPracticeCueEntriesTable> {
  $$LocalPracticeCueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cueIndex => $composableBuilder(
    column: $table.cueIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTimeMs => $composableBuilder(
    column: $table.startTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endTimeMs => $composableBuilder(
    column: $table.endTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalText => $composableBuilder(
    column: $table.originalText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translatedText => $composableBuilder(
    column: $table.translatedText,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalPracticeEntriesTableOrderingComposer get itemId {
    final $$LocalPracticeEntriesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.itemId,
          referencedTable: $db.localPracticeEntries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalPracticeEntriesTableOrderingComposer(
                $db: $db,
                $table: $db.localPracticeEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocalPracticeCueEntriesTableAnnotationComposer
    extends Composer<_$LocalPracticeDatabase, $LocalPracticeCueEntriesTable> {
  $$LocalPracticeCueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cueIndex =>
      $composableBuilder(column: $table.cueIndex, builder: (column) => column);

  GeneratedColumn<int> get startTimeMs => $composableBuilder(
    column: $table.startTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endTimeMs =>
      $composableBuilder(column: $table.endTimeMs, builder: (column) => column);

  GeneratedColumn<String> get originalText => $composableBuilder(
    column: $table.originalText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translatedText => $composableBuilder(
    column: $table.translatedText,
    builder: (column) => column,
  );

  $$LocalPracticeEntriesTableAnnotationComposer get itemId {
    final $$LocalPracticeEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.itemId,
          referencedTable: $db.localPracticeEntries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalPracticeEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.localPracticeEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocalPracticeCueEntriesTableTableManager
    extends
        RootTableManager<
          _$LocalPracticeDatabase,
          $LocalPracticeCueEntriesTable,
          LocalPracticeCueEntry,
          $$LocalPracticeCueEntriesTableFilterComposer,
          $$LocalPracticeCueEntriesTableOrderingComposer,
          $$LocalPracticeCueEntriesTableAnnotationComposer,
          $$LocalPracticeCueEntriesTableCreateCompanionBuilder,
          $$LocalPracticeCueEntriesTableUpdateCompanionBuilder,
          (LocalPracticeCueEntry, $$LocalPracticeCueEntriesTableReferences),
          LocalPracticeCueEntry,
          PrefetchHooks Function({bool itemId})
        > {
  $$LocalPracticeCueEntriesTableTableManager(
    _$LocalPracticeDatabase db,
    $LocalPracticeCueEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPracticeCueEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalPracticeCueEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalPracticeCueEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<int> cueIndex = const Value.absent(),
                Value<int> startTimeMs = const Value.absent(),
                Value<int> endTimeMs = const Value.absent(),
                Value<String> originalText = const Value.absent(),
                Value<String> translatedText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPracticeCueEntriesCompanion(
                id: id,
                itemId: itemId,
                cueIndex: cueIndex,
                startTimeMs: startTimeMs,
                endTimeMs: endTimeMs,
                originalText: originalText,
                translatedText: translatedText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required int cueIndex,
                required int startTimeMs,
                required int endTimeMs,
                required String originalText,
                Value<String> translatedText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPracticeCueEntriesCompanion.insert(
                id: id,
                itemId: itemId,
                cueIndex: cueIndex,
                startTimeMs: startTimeMs,
                endTimeMs: endTimeMs,
                originalText: originalText,
                translatedText: translatedText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalPracticeCueEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable:
                                    $$LocalPracticeCueEntriesTableReferences
                                        ._itemIdTable(db),
                                referencedColumn:
                                    $$LocalPracticeCueEntriesTableReferences
                                        ._itemIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LocalPracticeCueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalPracticeDatabase,
      $LocalPracticeCueEntriesTable,
      LocalPracticeCueEntry,
      $$LocalPracticeCueEntriesTableFilterComposer,
      $$LocalPracticeCueEntriesTableOrderingComposer,
      $$LocalPracticeCueEntriesTableAnnotationComposer,
      $$LocalPracticeCueEntriesTableCreateCompanionBuilder,
      $$LocalPracticeCueEntriesTableUpdateCompanionBuilder,
      (LocalPracticeCueEntry, $$LocalPracticeCueEntriesTableReferences),
      LocalPracticeCueEntry,
      PrefetchHooks Function({bool itemId})
    >;

class $LocalPracticeDatabaseManager {
  final _$LocalPracticeDatabase _db;
  $LocalPracticeDatabaseManager(this._db);
  $$LocalPracticeEntriesTableTableManager get localPracticeEntries =>
      $$LocalPracticeEntriesTableTableManager(_db, _db.localPracticeEntries);
  $$LocalPracticeCueEntriesTableTableManager get localPracticeCueEntries =>
      $$LocalPracticeCueEntriesTableTableManager(
        _db,
        _db.localPracticeCueEntries,
      );
}
