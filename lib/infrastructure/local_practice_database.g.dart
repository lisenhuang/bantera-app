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

class $LocalCueAttemptEntriesTable extends LocalCueAttemptEntries
    with TableInfo<$LocalCueAttemptEntriesTable, LocalCueAttemptEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCueAttemptEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _mediaItemIdMeta = const VerificationMeta(
    'mediaItemId',
  );
  @override
  late final GeneratedColumn<String> mediaItemId = GeneratedColumn<String>(
    'media_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cueIdMeta = const VerificationMeta('cueId');
  @override
  late final GeneratedColumn<String> cueId = GeneratedColumn<String>(
    'cue_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transcriptTextMeta = const VerificationMeta(
    'transcriptText',
  );
  @override
  late final GeneratedColumn<String> transcriptText = GeneratedColumn<String>(
    'transcript_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceLocaleIdentifierMeta =
      const VerificationMeta('sourceLocaleIdentifier');
  @override
  late final GeneratedColumn<String> sourceLocaleIdentifier =
      GeneratedColumn<String>(
        'source_locale_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matchedCountMeta = const VerificationMeta(
    'matchedCount',
  );
  @override
  late final GeneratedColumn<int> matchedCount = GeneratedColumn<int>(
    'matched_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unexpectedCountMeta = const VerificationMeta(
    'unexpectedCount',
  );
  @override
  late final GeneratedColumn<int> unexpectedCount = GeneratedColumn<int>(
    'unexpected_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _missingCountMeta = const VerificationMeta(
    'missingCount',
  );
  @override
  late final GeneratedColumn<int> missingCount = GeneratedColumn<int>(
    'missing_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordingDurationMsMeta =
      const VerificationMeta('recordingDurationMs');
  @override
  late final GeneratedColumn<int> recordingDurationMs = GeneratedColumn<int>(
    'recording_duration_ms',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerCacheKey,
    mediaItemId,
    cueId,
    transcriptText,
    sourceLocaleIdentifier,
    audioPath,
    matchedCount,
    unexpectedCount,
    missingCount,
    recordingDurationMs,
    createdAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_cue_attempt_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCueAttemptEntry> instance, {
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
    if (data.containsKey('media_item_id')) {
      context.handle(
        _mediaItemIdMeta,
        mediaItemId.isAcceptableOrUnknown(
          data['media_item_id']!,
          _mediaItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediaItemIdMeta);
    }
    if (data.containsKey('cue_id')) {
      context.handle(
        _cueIdMeta,
        cueId.isAcceptableOrUnknown(data['cue_id']!, _cueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cueIdMeta);
    }
    if (data.containsKey('transcript_text')) {
      context.handle(
        _transcriptTextMeta,
        transcriptText.isAcceptableOrUnknown(
          data['transcript_text']!,
          _transcriptTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transcriptTextMeta);
    }
    if (data.containsKey('source_locale_identifier')) {
      context.handle(
        _sourceLocaleIdentifierMeta,
        sourceLocaleIdentifier.isAcceptableOrUnknown(
          data['source_locale_identifier']!,
          _sourceLocaleIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceLocaleIdentifierMeta);
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    } else if (isInserting) {
      context.missing(_audioPathMeta);
    }
    if (data.containsKey('matched_count')) {
      context.handle(
        _matchedCountMeta,
        matchedCount.isAcceptableOrUnknown(
          data['matched_count']!,
          _matchedCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_matchedCountMeta);
    }
    if (data.containsKey('unexpected_count')) {
      context.handle(
        _unexpectedCountMeta,
        unexpectedCount.isAcceptableOrUnknown(
          data['unexpected_count']!,
          _unexpectedCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unexpectedCountMeta);
    }
    if (data.containsKey('missing_count')) {
      context.handle(
        _missingCountMeta,
        missingCount.isAcceptableOrUnknown(
          data['missing_count']!,
          _missingCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_missingCountMeta);
    }
    if (data.containsKey('recording_duration_ms')) {
      context.handle(
        _recordingDurationMsMeta,
        recordingDurationMs.isAcceptableOrUnknown(
          data['recording_duration_ms']!,
          _recordingDurationMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordingDurationMsMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCueAttemptEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCueAttemptEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerCacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_cache_key'],
      )!,
      mediaItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_item_id'],
      )!,
      cueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cue_id'],
      )!,
      transcriptText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript_text'],
      )!,
      sourceLocaleIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_locale_identifier'],
      )!,
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      )!,
      matchedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}matched_count'],
      )!,
      unexpectedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unexpected_count'],
      )!,
      missingCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}missing_count'],
      )!,
      recordingDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recording_duration_ms'],
      )!,
      createdAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_millis'],
      )!,
    );
  }

  @override
  $LocalCueAttemptEntriesTable createAlias(String alias) {
    return $LocalCueAttemptEntriesTable(attachedDatabase, alias);
  }
}

class LocalCueAttemptEntry extends DataClass
    implements Insertable<LocalCueAttemptEntry> {
  final String id;
  final String ownerCacheKey;
  final String mediaItemId;
  final String cueId;
  final String transcriptText;
  final String sourceLocaleIdentifier;
  final String audioPath;
  final int matchedCount;
  final int unexpectedCount;
  final int missingCount;
  final int recordingDurationMs;
  final int createdAtMillis;
  const LocalCueAttemptEntry({
    required this.id,
    required this.ownerCacheKey,
    required this.mediaItemId,
    required this.cueId,
    required this.transcriptText,
    required this.sourceLocaleIdentifier,
    required this.audioPath,
    required this.matchedCount,
    required this.unexpectedCount,
    required this.missingCount,
    required this.recordingDurationMs,
    required this.createdAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_cache_key'] = Variable<String>(ownerCacheKey);
    map['media_item_id'] = Variable<String>(mediaItemId);
    map['cue_id'] = Variable<String>(cueId);
    map['transcript_text'] = Variable<String>(transcriptText);
    map['source_locale_identifier'] = Variable<String>(sourceLocaleIdentifier);
    map['audio_path'] = Variable<String>(audioPath);
    map['matched_count'] = Variable<int>(matchedCount);
    map['unexpected_count'] = Variable<int>(unexpectedCount);
    map['missing_count'] = Variable<int>(missingCount);
    map['recording_duration_ms'] = Variable<int>(recordingDurationMs);
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    return map;
  }

  LocalCueAttemptEntriesCompanion toCompanion(bool nullToAbsent) {
    return LocalCueAttemptEntriesCompanion(
      id: Value(id),
      ownerCacheKey: Value(ownerCacheKey),
      mediaItemId: Value(mediaItemId),
      cueId: Value(cueId),
      transcriptText: Value(transcriptText),
      sourceLocaleIdentifier: Value(sourceLocaleIdentifier),
      audioPath: Value(audioPath),
      matchedCount: Value(matchedCount),
      unexpectedCount: Value(unexpectedCount),
      missingCount: Value(missingCount),
      recordingDurationMs: Value(recordingDurationMs),
      createdAtMillis: Value(createdAtMillis),
    );
  }

  factory LocalCueAttemptEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCueAttemptEntry(
      id: serializer.fromJson<String>(json['id']),
      ownerCacheKey: serializer.fromJson<String>(json['ownerCacheKey']),
      mediaItemId: serializer.fromJson<String>(json['mediaItemId']),
      cueId: serializer.fromJson<String>(json['cueId']),
      transcriptText: serializer.fromJson<String>(json['transcriptText']),
      sourceLocaleIdentifier: serializer.fromJson<String>(
        json['sourceLocaleIdentifier'],
      ),
      audioPath: serializer.fromJson<String>(json['audioPath']),
      matchedCount: serializer.fromJson<int>(json['matchedCount']),
      unexpectedCount: serializer.fromJson<int>(json['unexpectedCount']),
      missingCount: serializer.fromJson<int>(json['missingCount']),
      recordingDurationMs: serializer.fromJson<int>(
        json['recordingDurationMs'],
      ),
      createdAtMillis: serializer.fromJson<int>(json['createdAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerCacheKey': serializer.toJson<String>(ownerCacheKey),
      'mediaItemId': serializer.toJson<String>(mediaItemId),
      'cueId': serializer.toJson<String>(cueId),
      'transcriptText': serializer.toJson<String>(transcriptText),
      'sourceLocaleIdentifier': serializer.toJson<String>(
        sourceLocaleIdentifier,
      ),
      'audioPath': serializer.toJson<String>(audioPath),
      'matchedCount': serializer.toJson<int>(matchedCount),
      'unexpectedCount': serializer.toJson<int>(unexpectedCount),
      'missingCount': serializer.toJson<int>(missingCount),
      'recordingDurationMs': serializer.toJson<int>(recordingDurationMs),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
    };
  }

  LocalCueAttemptEntry copyWith({
    String? id,
    String? ownerCacheKey,
    String? mediaItemId,
    String? cueId,
    String? transcriptText,
    String? sourceLocaleIdentifier,
    String? audioPath,
    int? matchedCount,
    int? unexpectedCount,
    int? missingCount,
    int? recordingDurationMs,
    int? createdAtMillis,
  }) => LocalCueAttemptEntry(
    id: id ?? this.id,
    ownerCacheKey: ownerCacheKey ?? this.ownerCacheKey,
    mediaItemId: mediaItemId ?? this.mediaItemId,
    cueId: cueId ?? this.cueId,
    transcriptText: transcriptText ?? this.transcriptText,
    sourceLocaleIdentifier:
        sourceLocaleIdentifier ?? this.sourceLocaleIdentifier,
    audioPath: audioPath ?? this.audioPath,
    matchedCount: matchedCount ?? this.matchedCount,
    unexpectedCount: unexpectedCount ?? this.unexpectedCount,
    missingCount: missingCount ?? this.missingCount,
    recordingDurationMs: recordingDurationMs ?? this.recordingDurationMs,
    createdAtMillis: createdAtMillis ?? this.createdAtMillis,
  );
  LocalCueAttemptEntry copyWithCompanion(LocalCueAttemptEntriesCompanion data) {
    return LocalCueAttemptEntry(
      id: data.id.present ? data.id.value : this.id,
      ownerCacheKey: data.ownerCacheKey.present
          ? data.ownerCacheKey.value
          : this.ownerCacheKey,
      mediaItemId: data.mediaItemId.present
          ? data.mediaItemId.value
          : this.mediaItemId,
      cueId: data.cueId.present ? data.cueId.value : this.cueId,
      transcriptText: data.transcriptText.present
          ? data.transcriptText.value
          : this.transcriptText,
      sourceLocaleIdentifier: data.sourceLocaleIdentifier.present
          ? data.sourceLocaleIdentifier.value
          : this.sourceLocaleIdentifier,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      matchedCount: data.matchedCount.present
          ? data.matchedCount.value
          : this.matchedCount,
      unexpectedCount: data.unexpectedCount.present
          ? data.unexpectedCount.value
          : this.unexpectedCount,
      missingCount: data.missingCount.present
          ? data.missingCount.value
          : this.missingCount,
      recordingDurationMs: data.recordingDurationMs.present
          ? data.recordingDurationMs.value
          : this.recordingDurationMs,
      createdAtMillis: data.createdAtMillis.present
          ? data.createdAtMillis.value
          : this.createdAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCueAttemptEntry(')
          ..write('id: $id, ')
          ..write('ownerCacheKey: $ownerCacheKey, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('cueId: $cueId, ')
          ..write('transcriptText: $transcriptText, ')
          ..write('sourceLocaleIdentifier: $sourceLocaleIdentifier, ')
          ..write('audioPath: $audioPath, ')
          ..write('matchedCount: $matchedCount, ')
          ..write('unexpectedCount: $unexpectedCount, ')
          ..write('missingCount: $missingCount, ')
          ..write('recordingDurationMs: $recordingDurationMs, ')
          ..write('createdAtMillis: $createdAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerCacheKey,
    mediaItemId,
    cueId,
    transcriptText,
    sourceLocaleIdentifier,
    audioPath,
    matchedCount,
    unexpectedCount,
    missingCount,
    recordingDurationMs,
    createdAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCueAttemptEntry &&
          other.id == this.id &&
          other.ownerCacheKey == this.ownerCacheKey &&
          other.mediaItemId == this.mediaItemId &&
          other.cueId == this.cueId &&
          other.transcriptText == this.transcriptText &&
          other.sourceLocaleIdentifier == this.sourceLocaleIdentifier &&
          other.audioPath == this.audioPath &&
          other.matchedCount == this.matchedCount &&
          other.unexpectedCount == this.unexpectedCount &&
          other.missingCount == this.missingCount &&
          other.recordingDurationMs == this.recordingDurationMs &&
          other.createdAtMillis == this.createdAtMillis);
}

class LocalCueAttemptEntriesCompanion
    extends UpdateCompanion<LocalCueAttemptEntry> {
  final Value<String> id;
  final Value<String> ownerCacheKey;
  final Value<String> mediaItemId;
  final Value<String> cueId;
  final Value<String> transcriptText;
  final Value<String> sourceLocaleIdentifier;
  final Value<String> audioPath;
  final Value<int> matchedCount;
  final Value<int> unexpectedCount;
  final Value<int> missingCount;
  final Value<int> recordingDurationMs;
  final Value<int> createdAtMillis;
  final Value<int> rowid;
  const LocalCueAttemptEntriesCompanion({
    this.id = const Value.absent(),
    this.ownerCacheKey = const Value.absent(),
    this.mediaItemId = const Value.absent(),
    this.cueId = const Value.absent(),
    this.transcriptText = const Value.absent(),
    this.sourceLocaleIdentifier = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.matchedCount = const Value.absent(),
    this.unexpectedCount = const Value.absent(),
    this.missingCount = const Value.absent(),
    this.recordingDurationMs = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCueAttemptEntriesCompanion.insert({
    required String id,
    required String ownerCacheKey,
    required String mediaItemId,
    required String cueId,
    required String transcriptText,
    required String sourceLocaleIdentifier,
    required String audioPath,
    required int matchedCount,
    required int unexpectedCount,
    required int missingCount,
    required int recordingDurationMs,
    required int createdAtMillis,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerCacheKey = Value(ownerCacheKey),
       mediaItemId = Value(mediaItemId),
       cueId = Value(cueId),
       transcriptText = Value(transcriptText),
       sourceLocaleIdentifier = Value(sourceLocaleIdentifier),
       audioPath = Value(audioPath),
       matchedCount = Value(matchedCount),
       unexpectedCount = Value(unexpectedCount),
       missingCount = Value(missingCount),
       recordingDurationMs = Value(recordingDurationMs),
       createdAtMillis = Value(createdAtMillis);
  static Insertable<LocalCueAttemptEntry> custom({
    Expression<String>? id,
    Expression<String>? ownerCacheKey,
    Expression<String>? mediaItemId,
    Expression<String>? cueId,
    Expression<String>? transcriptText,
    Expression<String>? sourceLocaleIdentifier,
    Expression<String>? audioPath,
    Expression<int>? matchedCount,
    Expression<int>? unexpectedCount,
    Expression<int>? missingCount,
    Expression<int>? recordingDurationMs,
    Expression<int>? createdAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerCacheKey != null) 'owner_cache_key': ownerCacheKey,
      if (mediaItemId != null) 'media_item_id': mediaItemId,
      if (cueId != null) 'cue_id': cueId,
      if (transcriptText != null) 'transcript_text': transcriptText,
      if (sourceLocaleIdentifier != null)
        'source_locale_identifier': sourceLocaleIdentifier,
      if (audioPath != null) 'audio_path': audioPath,
      if (matchedCount != null) 'matched_count': matchedCount,
      if (unexpectedCount != null) 'unexpected_count': unexpectedCount,
      if (missingCount != null) 'missing_count': missingCount,
      if (recordingDurationMs != null)
        'recording_duration_ms': recordingDurationMs,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCueAttemptEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerCacheKey,
    Value<String>? mediaItemId,
    Value<String>? cueId,
    Value<String>? transcriptText,
    Value<String>? sourceLocaleIdentifier,
    Value<String>? audioPath,
    Value<int>? matchedCount,
    Value<int>? unexpectedCount,
    Value<int>? missingCount,
    Value<int>? recordingDurationMs,
    Value<int>? createdAtMillis,
    Value<int>? rowid,
  }) {
    return LocalCueAttemptEntriesCompanion(
      id: id ?? this.id,
      ownerCacheKey: ownerCacheKey ?? this.ownerCacheKey,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      cueId: cueId ?? this.cueId,
      transcriptText: transcriptText ?? this.transcriptText,
      sourceLocaleIdentifier:
          sourceLocaleIdentifier ?? this.sourceLocaleIdentifier,
      audioPath: audioPath ?? this.audioPath,
      matchedCount: matchedCount ?? this.matchedCount,
      unexpectedCount: unexpectedCount ?? this.unexpectedCount,
      missingCount: missingCount ?? this.missingCount,
      recordingDurationMs: recordingDurationMs ?? this.recordingDurationMs,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
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
    if (mediaItemId.present) {
      map['media_item_id'] = Variable<String>(mediaItemId.value);
    }
    if (cueId.present) {
      map['cue_id'] = Variable<String>(cueId.value);
    }
    if (transcriptText.present) {
      map['transcript_text'] = Variable<String>(transcriptText.value);
    }
    if (sourceLocaleIdentifier.present) {
      map['source_locale_identifier'] = Variable<String>(
        sourceLocaleIdentifier.value,
      );
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (matchedCount.present) {
      map['matched_count'] = Variable<int>(matchedCount.value);
    }
    if (unexpectedCount.present) {
      map['unexpected_count'] = Variable<int>(unexpectedCount.value);
    }
    if (missingCount.present) {
      map['missing_count'] = Variable<int>(missingCount.value);
    }
    if (recordingDurationMs.present) {
      map['recording_duration_ms'] = Variable<int>(recordingDurationMs.value);
    }
    if (createdAtMillis.present) {
      map['created_at_millis'] = Variable<int>(createdAtMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCueAttemptEntriesCompanion(')
          ..write('id: $id, ')
          ..write('ownerCacheKey: $ownerCacheKey, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('cueId: $cueId, ')
          ..write('transcriptText: $transcriptText, ')
          ..write('sourceLocaleIdentifier: $sourceLocaleIdentifier, ')
          ..write('audioPath: $audioPath, ')
          ..write('matchedCount: $matchedCount, ')
          ..write('unexpectedCount: $unexpectedCount, ')
          ..write('missingCount: $missingCount, ')
          ..write('recordingDurationMs: $recordingDurationMs, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedCueEntriesTable extends SavedCueEntries
    with TableInfo<$SavedCueEntriesTable, SavedCueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedCueEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _mediaItemIdMeta = const VerificationMeta(
    'mediaItemId',
  );
  @override
  late final GeneratedColumn<String> mediaItemId = GeneratedColumn<String>(
    'media_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cueIdMeta = const VerificationMeta('cueId');
  @override
  late final GeneratedColumn<String> cueId = GeneratedColumn<String>(
    'cue_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _cueTextMeta = const VerificationMeta(
    'cueText',
  );
  @override
  late final GeneratedColumn<String> cueText = GeneratedColumn<String>(
    'cue_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMsMeta = const VerificationMeta(
    'startTimeMs',
  );
  @override
  late final GeneratedColumn<int> startTimeMs = GeneratedColumn<int>(
    'start_time_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTimeMsMeta = const VerificationMeta(
    'endTimeMs',
  );
  @override
  late final GeneratedColumn<int> endTimeMs = GeneratedColumn<int>(
    'end_time_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cueModeMeta = const VerificationMeta(
    'cueMode',
  );
  @override
  late final GeneratedColumn<String> cueMode = GeneratedColumn<String>(
    'cue_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentCueIdMeta = const VerificationMeta(
    'parentCueId',
  );
  @override
  late final GeneratedColumn<String> parentCueId = GeneratedColumn<String>(
    'parent_cue_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentCueIndexMeta = const VerificationMeta(
    'parentCueIndex',
  );
  @override
  late final GeneratedColumn<int> parentCueIndex = GeneratedColumn<int>(
    'parent_cue_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaItemJsonMeta = const VerificationMeta(
    'mediaItemJson',
  );
  @override
  late final GeneratedColumn<String> mediaItemJson = GeneratedColumn<String>(
    'media_item_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMillisMeta = const VerificationMeta(
    'savedAtMillis',
  );
  @override
  late final GeneratedColumn<int> savedAtMillis = GeneratedColumn<int>(
    'saved_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerCacheKey,
    mediaItemId,
    cueId,
    cueIndex,
    cueText,
    startTimeMs,
    endTimeMs,
    cueMode,
    parentCueId,
    parentCueIndex,
    mediaItemJson,
    savedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_cue_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedCueEntry> instance, {
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
    if (data.containsKey('media_item_id')) {
      context.handle(
        _mediaItemIdMeta,
        mediaItemId.isAcceptableOrUnknown(
          data['media_item_id']!,
          _mediaItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediaItemIdMeta);
    }
    if (data.containsKey('cue_id')) {
      context.handle(
        _cueIdMeta,
        cueId.isAcceptableOrUnknown(data['cue_id']!, _cueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cueIdMeta);
    }
    if (data.containsKey('cue_index')) {
      context.handle(
        _cueIndexMeta,
        cueIndex.isAcceptableOrUnknown(data['cue_index']!, _cueIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_cueIndexMeta);
    }
    if (data.containsKey('cue_text')) {
      context.handle(
        _cueTextMeta,
        cueText.isAcceptableOrUnknown(data['cue_text']!, _cueTextMeta),
      );
    } else if (isInserting) {
      context.missing(_cueTextMeta);
    }
    if (data.containsKey('start_time_ms')) {
      context.handle(
        _startTimeMsMeta,
        startTimeMs.isAcceptableOrUnknown(
          data['start_time_ms']!,
          _startTimeMsMeta,
        ),
      );
    }
    if (data.containsKey('end_time_ms')) {
      context.handle(
        _endTimeMsMeta,
        endTimeMs.isAcceptableOrUnknown(data['end_time_ms']!, _endTimeMsMeta),
      );
    }
    if (data.containsKey('cue_mode')) {
      context.handle(
        _cueModeMeta,
        cueMode.isAcceptableOrUnknown(data['cue_mode']!, _cueModeMeta),
      );
    }
    if (data.containsKey('parent_cue_id')) {
      context.handle(
        _parentCueIdMeta,
        parentCueId.isAcceptableOrUnknown(
          data['parent_cue_id']!,
          _parentCueIdMeta,
        ),
      );
    }
    if (data.containsKey('parent_cue_index')) {
      context.handle(
        _parentCueIndexMeta,
        parentCueIndex.isAcceptableOrUnknown(
          data['parent_cue_index']!,
          _parentCueIndexMeta,
        ),
      );
    }
    if (data.containsKey('media_item_json')) {
      context.handle(
        _mediaItemJsonMeta,
        mediaItemJson.isAcceptableOrUnknown(
          data['media_item_json']!,
          _mediaItemJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediaItemJsonMeta);
    }
    if (data.containsKey('saved_at_millis')) {
      context.handle(
        _savedAtMillisMeta,
        savedAtMillis.isAcceptableOrUnknown(
          data['saved_at_millis']!,
          _savedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_savedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedCueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedCueEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerCacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_cache_key'],
      )!,
      mediaItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_item_id'],
      )!,
      cueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cue_id'],
      )!,
      cueIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cue_index'],
      )!,
      cueText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cue_text'],
      )!,
      startTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time_ms'],
      ),
      endTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_time_ms'],
      ),
      cueMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cue_mode'],
      ),
      parentCueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_cue_id'],
      ),
      parentCueIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_cue_index'],
      ),
      mediaItemJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_item_json'],
      )!,
      savedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saved_at_millis'],
      )!,
    );
  }

  @override
  $SavedCueEntriesTable createAlias(String alias) {
    return $SavedCueEntriesTable(attachedDatabase, alias);
  }
}

class SavedCueEntry extends DataClass implements Insertable<SavedCueEntry> {
  final String id;
  final String ownerCacheKey;
  final String mediaItemId;
  final String cueId;
  final int cueIndex;
  final String cueText;
  final int? startTimeMs;
  final int? endTimeMs;
  final String? cueMode;
  final String? parentCueId;
  final int? parentCueIndex;
  final String mediaItemJson;
  final int savedAtMillis;
  const SavedCueEntry({
    required this.id,
    required this.ownerCacheKey,
    required this.mediaItemId,
    required this.cueId,
    required this.cueIndex,
    required this.cueText,
    this.startTimeMs,
    this.endTimeMs,
    this.cueMode,
    this.parentCueId,
    this.parentCueIndex,
    required this.mediaItemJson,
    required this.savedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_cache_key'] = Variable<String>(ownerCacheKey);
    map['media_item_id'] = Variable<String>(mediaItemId);
    map['cue_id'] = Variable<String>(cueId);
    map['cue_index'] = Variable<int>(cueIndex);
    map['cue_text'] = Variable<String>(cueText);
    if (!nullToAbsent || startTimeMs != null) {
      map['start_time_ms'] = Variable<int>(startTimeMs);
    }
    if (!nullToAbsent || endTimeMs != null) {
      map['end_time_ms'] = Variable<int>(endTimeMs);
    }
    if (!nullToAbsent || cueMode != null) {
      map['cue_mode'] = Variable<String>(cueMode);
    }
    if (!nullToAbsent || parentCueId != null) {
      map['parent_cue_id'] = Variable<String>(parentCueId);
    }
    if (!nullToAbsent || parentCueIndex != null) {
      map['parent_cue_index'] = Variable<int>(parentCueIndex);
    }
    map['media_item_json'] = Variable<String>(mediaItemJson);
    map['saved_at_millis'] = Variable<int>(savedAtMillis);
    return map;
  }

  SavedCueEntriesCompanion toCompanion(bool nullToAbsent) {
    return SavedCueEntriesCompanion(
      id: Value(id),
      ownerCacheKey: Value(ownerCacheKey),
      mediaItemId: Value(mediaItemId),
      cueId: Value(cueId),
      cueIndex: Value(cueIndex),
      cueText: Value(cueText),
      startTimeMs: startTimeMs == null && nullToAbsent
          ? const Value.absent()
          : Value(startTimeMs),
      endTimeMs: endTimeMs == null && nullToAbsent
          ? const Value.absent()
          : Value(endTimeMs),
      cueMode: cueMode == null && nullToAbsent
          ? const Value.absent()
          : Value(cueMode),
      parentCueId: parentCueId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentCueId),
      parentCueIndex: parentCueIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(parentCueIndex),
      mediaItemJson: Value(mediaItemJson),
      savedAtMillis: Value(savedAtMillis),
    );
  }

  factory SavedCueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedCueEntry(
      id: serializer.fromJson<String>(json['id']),
      ownerCacheKey: serializer.fromJson<String>(json['ownerCacheKey']),
      mediaItemId: serializer.fromJson<String>(json['mediaItemId']),
      cueId: serializer.fromJson<String>(json['cueId']),
      cueIndex: serializer.fromJson<int>(json['cueIndex']),
      cueText: serializer.fromJson<String>(json['cueText']),
      startTimeMs: serializer.fromJson<int?>(json['startTimeMs']),
      endTimeMs: serializer.fromJson<int?>(json['endTimeMs']),
      cueMode: serializer.fromJson<String?>(json['cueMode']),
      parentCueId: serializer.fromJson<String?>(json['parentCueId']),
      parentCueIndex: serializer.fromJson<int?>(json['parentCueIndex']),
      mediaItemJson: serializer.fromJson<String>(json['mediaItemJson']),
      savedAtMillis: serializer.fromJson<int>(json['savedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerCacheKey': serializer.toJson<String>(ownerCacheKey),
      'mediaItemId': serializer.toJson<String>(mediaItemId),
      'cueId': serializer.toJson<String>(cueId),
      'cueIndex': serializer.toJson<int>(cueIndex),
      'cueText': serializer.toJson<String>(cueText),
      'startTimeMs': serializer.toJson<int?>(startTimeMs),
      'endTimeMs': serializer.toJson<int?>(endTimeMs),
      'cueMode': serializer.toJson<String?>(cueMode),
      'parentCueId': serializer.toJson<String?>(parentCueId),
      'parentCueIndex': serializer.toJson<int?>(parentCueIndex),
      'mediaItemJson': serializer.toJson<String>(mediaItemJson),
      'savedAtMillis': serializer.toJson<int>(savedAtMillis),
    };
  }

  SavedCueEntry copyWith({
    String? id,
    String? ownerCacheKey,
    String? mediaItemId,
    String? cueId,
    int? cueIndex,
    String? cueText,
    Value<int?> startTimeMs = const Value.absent(),
    Value<int?> endTimeMs = const Value.absent(),
    Value<String?> cueMode = const Value.absent(),
    Value<String?> parentCueId = const Value.absent(),
    Value<int?> parentCueIndex = const Value.absent(),
    String? mediaItemJson,
    int? savedAtMillis,
  }) => SavedCueEntry(
    id: id ?? this.id,
    ownerCacheKey: ownerCacheKey ?? this.ownerCacheKey,
    mediaItemId: mediaItemId ?? this.mediaItemId,
    cueId: cueId ?? this.cueId,
    cueIndex: cueIndex ?? this.cueIndex,
    cueText: cueText ?? this.cueText,
    startTimeMs: startTimeMs.present ? startTimeMs.value : this.startTimeMs,
    endTimeMs: endTimeMs.present ? endTimeMs.value : this.endTimeMs,
    cueMode: cueMode.present ? cueMode.value : this.cueMode,
    parentCueId: parentCueId.present ? parentCueId.value : this.parentCueId,
    parentCueIndex: parentCueIndex.present
        ? parentCueIndex.value
        : this.parentCueIndex,
    mediaItemJson: mediaItemJson ?? this.mediaItemJson,
    savedAtMillis: savedAtMillis ?? this.savedAtMillis,
  );
  SavedCueEntry copyWithCompanion(SavedCueEntriesCompanion data) {
    return SavedCueEntry(
      id: data.id.present ? data.id.value : this.id,
      ownerCacheKey: data.ownerCacheKey.present
          ? data.ownerCacheKey.value
          : this.ownerCacheKey,
      mediaItemId: data.mediaItemId.present
          ? data.mediaItemId.value
          : this.mediaItemId,
      cueId: data.cueId.present ? data.cueId.value : this.cueId,
      cueIndex: data.cueIndex.present ? data.cueIndex.value : this.cueIndex,
      cueText: data.cueText.present ? data.cueText.value : this.cueText,
      startTimeMs: data.startTimeMs.present
          ? data.startTimeMs.value
          : this.startTimeMs,
      endTimeMs: data.endTimeMs.present ? data.endTimeMs.value : this.endTimeMs,
      cueMode: data.cueMode.present ? data.cueMode.value : this.cueMode,
      parentCueId: data.parentCueId.present
          ? data.parentCueId.value
          : this.parentCueId,
      parentCueIndex: data.parentCueIndex.present
          ? data.parentCueIndex.value
          : this.parentCueIndex,
      mediaItemJson: data.mediaItemJson.present
          ? data.mediaItemJson.value
          : this.mediaItemJson,
      savedAtMillis: data.savedAtMillis.present
          ? data.savedAtMillis.value
          : this.savedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedCueEntry(')
          ..write('id: $id, ')
          ..write('ownerCacheKey: $ownerCacheKey, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('cueId: $cueId, ')
          ..write('cueIndex: $cueIndex, ')
          ..write('cueText: $cueText, ')
          ..write('startTimeMs: $startTimeMs, ')
          ..write('endTimeMs: $endTimeMs, ')
          ..write('cueMode: $cueMode, ')
          ..write('parentCueId: $parentCueId, ')
          ..write('parentCueIndex: $parentCueIndex, ')
          ..write('mediaItemJson: $mediaItemJson, ')
          ..write('savedAtMillis: $savedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerCacheKey,
    mediaItemId,
    cueId,
    cueIndex,
    cueText,
    startTimeMs,
    endTimeMs,
    cueMode,
    parentCueId,
    parentCueIndex,
    mediaItemJson,
    savedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedCueEntry &&
          other.id == this.id &&
          other.ownerCacheKey == this.ownerCacheKey &&
          other.mediaItemId == this.mediaItemId &&
          other.cueId == this.cueId &&
          other.cueIndex == this.cueIndex &&
          other.cueText == this.cueText &&
          other.startTimeMs == this.startTimeMs &&
          other.endTimeMs == this.endTimeMs &&
          other.cueMode == this.cueMode &&
          other.parentCueId == this.parentCueId &&
          other.parentCueIndex == this.parentCueIndex &&
          other.mediaItemJson == this.mediaItemJson &&
          other.savedAtMillis == this.savedAtMillis);
}

class SavedCueEntriesCompanion extends UpdateCompanion<SavedCueEntry> {
  final Value<String> id;
  final Value<String> ownerCacheKey;
  final Value<String> mediaItemId;
  final Value<String> cueId;
  final Value<int> cueIndex;
  final Value<String> cueText;
  final Value<int?> startTimeMs;
  final Value<int?> endTimeMs;
  final Value<String?> cueMode;
  final Value<String?> parentCueId;
  final Value<int?> parentCueIndex;
  final Value<String> mediaItemJson;
  final Value<int> savedAtMillis;
  final Value<int> rowid;
  const SavedCueEntriesCompanion({
    this.id = const Value.absent(),
    this.ownerCacheKey = const Value.absent(),
    this.mediaItemId = const Value.absent(),
    this.cueId = const Value.absent(),
    this.cueIndex = const Value.absent(),
    this.cueText = const Value.absent(),
    this.startTimeMs = const Value.absent(),
    this.endTimeMs = const Value.absent(),
    this.cueMode = const Value.absent(),
    this.parentCueId = const Value.absent(),
    this.parentCueIndex = const Value.absent(),
    this.mediaItemJson = const Value.absent(),
    this.savedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedCueEntriesCompanion.insert({
    required String id,
    required String ownerCacheKey,
    required String mediaItemId,
    required String cueId,
    required int cueIndex,
    required String cueText,
    this.startTimeMs = const Value.absent(),
    this.endTimeMs = const Value.absent(),
    this.cueMode = const Value.absent(),
    this.parentCueId = const Value.absent(),
    this.parentCueIndex = const Value.absent(),
    required String mediaItemJson,
    required int savedAtMillis,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerCacheKey = Value(ownerCacheKey),
       mediaItemId = Value(mediaItemId),
       cueId = Value(cueId),
       cueIndex = Value(cueIndex),
       cueText = Value(cueText),
       mediaItemJson = Value(mediaItemJson),
       savedAtMillis = Value(savedAtMillis);
  static Insertable<SavedCueEntry> custom({
    Expression<String>? id,
    Expression<String>? ownerCacheKey,
    Expression<String>? mediaItemId,
    Expression<String>? cueId,
    Expression<int>? cueIndex,
    Expression<String>? cueText,
    Expression<int>? startTimeMs,
    Expression<int>? endTimeMs,
    Expression<String>? cueMode,
    Expression<String>? parentCueId,
    Expression<int>? parentCueIndex,
    Expression<String>? mediaItemJson,
    Expression<int>? savedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerCacheKey != null) 'owner_cache_key': ownerCacheKey,
      if (mediaItemId != null) 'media_item_id': mediaItemId,
      if (cueId != null) 'cue_id': cueId,
      if (cueIndex != null) 'cue_index': cueIndex,
      if (cueText != null) 'cue_text': cueText,
      if (startTimeMs != null) 'start_time_ms': startTimeMs,
      if (endTimeMs != null) 'end_time_ms': endTimeMs,
      if (cueMode != null) 'cue_mode': cueMode,
      if (parentCueId != null) 'parent_cue_id': parentCueId,
      if (parentCueIndex != null) 'parent_cue_index': parentCueIndex,
      if (mediaItemJson != null) 'media_item_json': mediaItemJson,
      if (savedAtMillis != null) 'saved_at_millis': savedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedCueEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerCacheKey,
    Value<String>? mediaItemId,
    Value<String>? cueId,
    Value<int>? cueIndex,
    Value<String>? cueText,
    Value<int?>? startTimeMs,
    Value<int?>? endTimeMs,
    Value<String?>? cueMode,
    Value<String?>? parentCueId,
    Value<int?>? parentCueIndex,
    Value<String>? mediaItemJson,
    Value<int>? savedAtMillis,
    Value<int>? rowid,
  }) {
    return SavedCueEntriesCompanion(
      id: id ?? this.id,
      ownerCacheKey: ownerCacheKey ?? this.ownerCacheKey,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      cueId: cueId ?? this.cueId,
      cueIndex: cueIndex ?? this.cueIndex,
      cueText: cueText ?? this.cueText,
      startTimeMs: startTimeMs ?? this.startTimeMs,
      endTimeMs: endTimeMs ?? this.endTimeMs,
      cueMode: cueMode ?? this.cueMode,
      parentCueId: parentCueId ?? this.parentCueId,
      parentCueIndex: parentCueIndex ?? this.parentCueIndex,
      mediaItemJson: mediaItemJson ?? this.mediaItemJson,
      savedAtMillis: savedAtMillis ?? this.savedAtMillis,
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
    if (mediaItemId.present) {
      map['media_item_id'] = Variable<String>(mediaItemId.value);
    }
    if (cueId.present) {
      map['cue_id'] = Variable<String>(cueId.value);
    }
    if (cueIndex.present) {
      map['cue_index'] = Variable<int>(cueIndex.value);
    }
    if (cueText.present) {
      map['cue_text'] = Variable<String>(cueText.value);
    }
    if (startTimeMs.present) {
      map['start_time_ms'] = Variable<int>(startTimeMs.value);
    }
    if (endTimeMs.present) {
      map['end_time_ms'] = Variable<int>(endTimeMs.value);
    }
    if (cueMode.present) {
      map['cue_mode'] = Variable<String>(cueMode.value);
    }
    if (parentCueId.present) {
      map['parent_cue_id'] = Variable<String>(parentCueId.value);
    }
    if (parentCueIndex.present) {
      map['parent_cue_index'] = Variable<int>(parentCueIndex.value);
    }
    if (mediaItemJson.present) {
      map['media_item_json'] = Variable<String>(mediaItemJson.value);
    }
    if (savedAtMillis.present) {
      map['saved_at_millis'] = Variable<int>(savedAtMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedCueEntriesCompanion(')
          ..write('id: $id, ')
          ..write('ownerCacheKey: $ownerCacheKey, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('cueId: $cueId, ')
          ..write('cueIndex: $cueIndex, ')
          ..write('cueText: $cueText, ')
          ..write('startTimeMs: $startTimeMs, ')
          ..write('endTimeMs: $endTimeMs, ')
          ..write('cueMode: $cueMode, ')
          ..write('parentCueId: $parentCueId, ')
          ..write('parentCueIndex: $parentCueIndex, ')
          ..write('mediaItemJson: $mediaItemJson, ')
          ..write('savedAtMillis: $savedAtMillis, ')
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
  late final $LocalCueAttemptEntriesTable localCueAttemptEntries =
      $LocalCueAttemptEntriesTable(this);
  late final $SavedCueEntriesTable savedCueEntries = $SavedCueEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localPracticeEntries,
    localPracticeCueEntries,
    localCueAttemptEntries,
    savedCueEntries,
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
typedef $$LocalCueAttemptEntriesTableCreateCompanionBuilder =
    LocalCueAttemptEntriesCompanion Function({
      required String id,
      required String ownerCacheKey,
      required String mediaItemId,
      required String cueId,
      required String transcriptText,
      required String sourceLocaleIdentifier,
      required String audioPath,
      required int matchedCount,
      required int unexpectedCount,
      required int missingCount,
      required int recordingDurationMs,
      required int createdAtMillis,
      Value<int> rowid,
    });
typedef $$LocalCueAttemptEntriesTableUpdateCompanionBuilder =
    LocalCueAttemptEntriesCompanion Function({
      Value<String> id,
      Value<String> ownerCacheKey,
      Value<String> mediaItemId,
      Value<String> cueId,
      Value<String> transcriptText,
      Value<String> sourceLocaleIdentifier,
      Value<String> audioPath,
      Value<int> matchedCount,
      Value<int> unexpectedCount,
      Value<int> missingCount,
      Value<int> recordingDurationMs,
      Value<int> createdAtMillis,
      Value<int> rowid,
    });

class $$LocalCueAttemptEntriesTableFilterComposer
    extends Composer<_$LocalPracticeDatabase, $LocalCueAttemptEntriesTable> {
  $$LocalCueAttemptEntriesTableFilterComposer({
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

  ColumnFilters<String> get mediaItemId => $composableBuilder(
    column: $table.mediaItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cueId => $composableBuilder(
    column: $table.cueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcriptText => $composableBuilder(
    column: $table.transcriptText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceLocaleIdentifier => $composableBuilder(
    column: $table.sourceLocaleIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get matchedCount => $composableBuilder(
    column: $table.matchedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unexpectedCount => $composableBuilder(
    column: $table.unexpectedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get missingCount => $composableBuilder(
    column: $table.missingCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordingDurationMs => $composableBuilder(
    column: $table.recordingDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCueAttemptEntriesTableOrderingComposer
    extends Composer<_$LocalPracticeDatabase, $LocalCueAttemptEntriesTable> {
  $$LocalCueAttemptEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get mediaItemId => $composableBuilder(
    column: $table.mediaItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cueId => $composableBuilder(
    column: $table.cueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcriptText => $composableBuilder(
    column: $table.transcriptText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceLocaleIdentifier => $composableBuilder(
    column: $table.sourceLocaleIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get matchedCount => $composableBuilder(
    column: $table.matchedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unexpectedCount => $composableBuilder(
    column: $table.unexpectedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get missingCount => $composableBuilder(
    column: $table.missingCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordingDurationMs => $composableBuilder(
    column: $table.recordingDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCueAttemptEntriesTableAnnotationComposer
    extends Composer<_$LocalPracticeDatabase, $LocalCueAttemptEntriesTable> {
  $$LocalCueAttemptEntriesTableAnnotationComposer({
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

  GeneratedColumn<String> get mediaItemId => $composableBuilder(
    column: $table.mediaItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cueId =>
      $composableBuilder(column: $table.cueId, builder: (column) => column);

  GeneratedColumn<String> get transcriptText => $composableBuilder(
    column: $table.transcriptText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceLocaleIdentifier => $composableBuilder(
    column: $table.sourceLocaleIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<int> get matchedCount => $composableBuilder(
    column: $table.matchedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unexpectedCount => $composableBuilder(
    column: $table.unexpectedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get missingCount => $composableBuilder(
    column: $table.missingCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recordingDurationMs => $composableBuilder(
    column: $table.recordingDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => column,
  );
}

class $$LocalCueAttemptEntriesTableTableManager
    extends
        RootTableManager<
          _$LocalPracticeDatabase,
          $LocalCueAttemptEntriesTable,
          LocalCueAttemptEntry,
          $$LocalCueAttemptEntriesTableFilterComposer,
          $$LocalCueAttemptEntriesTableOrderingComposer,
          $$LocalCueAttemptEntriesTableAnnotationComposer,
          $$LocalCueAttemptEntriesTableCreateCompanionBuilder,
          $$LocalCueAttemptEntriesTableUpdateCompanionBuilder,
          (
            LocalCueAttemptEntry,
            BaseReferences<
              _$LocalPracticeDatabase,
              $LocalCueAttemptEntriesTable,
              LocalCueAttemptEntry
            >,
          ),
          LocalCueAttemptEntry,
          PrefetchHooks Function()
        > {
  $$LocalCueAttemptEntriesTableTableManager(
    _$LocalPracticeDatabase db,
    $LocalCueAttemptEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCueAttemptEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalCueAttemptEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalCueAttemptEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerCacheKey = const Value.absent(),
                Value<String> mediaItemId = const Value.absent(),
                Value<String> cueId = const Value.absent(),
                Value<String> transcriptText = const Value.absent(),
                Value<String> sourceLocaleIdentifier = const Value.absent(),
                Value<String> audioPath = const Value.absent(),
                Value<int> matchedCount = const Value.absent(),
                Value<int> unexpectedCount = const Value.absent(),
                Value<int> missingCount = const Value.absent(),
                Value<int> recordingDurationMs = const Value.absent(),
                Value<int> createdAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCueAttemptEntriesCompanion(
                id: id,
                ownerCacheKey: ownerCacheKey,
                mediaItemId: mediaItemId,
                cueId: cueId,
                transcriptText: transcriptText,
                sourceLocaleIdentifier: sourceLocaleIdentifier,
                audioPath: audioPath,
                matchedCount: matchedCount,
                unexpectedCount: unexpectedCount,
                missingCount: missingCount,
                recordingDurationMs: recordingDurationMs,
                createdAtMillis: createdAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerCacheKey,
                required String mediaItemId,
                required String cueId,
                required String transcriptText,
                required String sourceLocaleIdentifier,
                required String audioPath,
                required int matchedCount,
                required int unexpectedCount,
                required int missingCount,
                required int recordingDurationMs,
                required int createdAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => LocalCueAttemptEntriesCompanion.insert(
                id: id,
                ownerCacheKey: ownerCacheKey,
                mediaItemId: mediaItemId,
                cueId: cueId,
                transcriptText: transcriptText,
                sourceLocaleIdentifier: sourceLocaleIdentifier,
                audioPath: audioPath,
                matchedCount: matchedCount,
                unexpectedCount: unexpectedCount,
                missingCount: missingCount,
                recordingDurationMs: recordingDurationMs,
                createdAtMillis: createdAtMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCueAttemptEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalPracticeDatabase,
      $LocalCueAttemptEntriesTable,
      LocalCueAttemptEntry,
      $$LocalCueAttemptEntriesTableFilterComposer,
      $$LocalCueAttemptEntriesTableOrderingComposer,
      $$LocalCueAttemptEntriesTableAnnotationComposer,
      $$LocalCueAttemptEntriesTableCreateCompanionBuilder,
      $$LocalCueAttemptEntriesTableUpdateCompanionBuilder,
      (
        LocalCueAttemptEntry,
        BaseReferences<
          _$LocalPracticeDatabase,
          $LocalCueAttemptEntriesTable,
          LocalCueAttemptEntry
        >,
      ),
      LocalCueAttemptEntry,
      PrefetchHooks Function()
    >;
typedef $$SavedCueEntriesTableCreateCompanionBuilder =
    SavedCueEntriesCompanion Function({
      required String id,
      required String ownerCacheKey,
      required String mediaItemId,
      required String cueId,
      required int cueIndex,
      required String cueText,
      Value<int?> startTimeMs,
      Value<int?> endTimeMs,
      Value<String?> cueMode,
      Value<String?> parentCueId,
      Value<int?> parentCueIndex,
      required String mediaItemJson,
      required int savedAtMillis,
      Value<int> rowid,
    });
typedef $$SavedCueEntriesTableUpdateCompanionBuilder =
    SavedCueEntriesCompanion Function({
      Value<String> id,
      Value<String> ownerCacheKey,
      Value<String> mediaItemId,
      Value<String> cueId,
      Value<int> cueIndex,
      Value<String> cueText,
      Value<int?> startTimeMs,
      Value<int?> endTimeMs,
      Value<String?> cueMode,
      Value<String?> parentCueId,
      Value<int?> parentCueIndex,
      Value<String> mediaItemJson,
      Value<int> savedAtMillis,
      Value<int> rowid,
    });

class $$SavedCueEntriesTableFilterComposer
    extends Composer<_$LocalPracticeDatabase, $SavedCueEntriesTable> {
  $$SavedCueEntriesTableFilterComposer({
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

  ColumnFilters<String> get mediaItemId => $composableBuilder(
    column: $table.mediaItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cueId => $composableBuilder(
    column: $table.cueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cueIndex => $composableBuilder(
    column: $table.cueIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cueText => $composableBuilder(
    column: $table.cueText,
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

  ColumnFilters<String> get cueMode => $composableBuilder(
    column: $table.cueMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentCueId => $composableBuilder(
    column: $table.parentCueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentCueIndex => $composableBuilder(
    column: $table.parentCueIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaItemJson => $composableBuilder(
    column: $table.mediaItemJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savedAtMillis => $composableBuilder(
    column: $table.savedAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedCueEntriesTableOrderingComposer
    extends Composer<_$LocalPracticeDatabase, $SavedCueEntriesTable> {
  $$SavedCueEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get mediaItemId => $composableBuilder(
    column: $table.mediaItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cueId => $composableBuilder(
    column: $table.cueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cueIndex => $composableBuilder(
    column: $table.cueIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cueText => $composableBuilder(
    column: $table.cueText,
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

  ColumnOrderings<String> get cueMode => $composableBuilder(
    column: $table.cueMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentCueId => $composableBuilder(
    column: $table.parentCueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentCueIndex => $composableBuilder(
    column: $table.parentCueIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaItemJson => $composableBuilder(
    column: $table.mediaItemJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savedAtMillis => $composableBuilder(
    column: $table.savedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedCueEntriesTableAnnotationComposer
    extends Composer<_$LocalPracticeDatabase, $SavedCueEntriesTable> {
  $$SavedCueEntriesTableAnnotationComposer({
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

  GeneratedColumn<String> get mediaItemId => $composableBuilder(
    column: $table.mediaItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cueId =>
      $composableBuilder(column: $table.cueId, builder: (column) => column);

  GeneratedColumn<int> get cueIndex =>
      $composableBuilder(column: $table.cueIndex, builder: (column) => column);

  GeneratedColumn<String> get cueText =>
      $composableBuilder(column: $table.cueText, builder: (column) => column);

  GeneratedColumn<int> get startTimeMs => $composableBuilder(
    column: $table.startTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endTimeMs =>
      $composableBuilder(column: $table.endTimeMs, builder: (column) => column);

  GeneratedColumn<String> get cueMode =>
      $composableBuilder(column: $table.cueMode, builder: (column) => column);

  GeneratedColumn<String> get parentCueId => $composableBuilder(
    column: $table.parentCueId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parentCueIndex => $composableBuilder(
    column: $table.parentCueIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mediaItemJson => $composableBuilder(
    column: $table.mediaItemJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get savedAtMillis => $composableBuilder(
    column: $table.savedAtMillis,
    builder: (column) => column,
  );
}

class $$SavedCueEntriesTableTableManager
    extends
        RootTableManager<
          _$LocalPracticeDatabase,
          $SavedCueEntriesTable,
          SavedCueEntry,
          $$SavedCueEntriesTableFilterComposer,
          $$SavedCueEntriesTableOrderingComposer,
          $$SavedCueEntriesTableAnnotationComposer,
          $$SavedCueEntriesTableCreateCompanionBuilder,
          $$SavedCueEntriesTableUpdateCompanionBuilder,
          (
            SavedCueEntry,
            BaseReferences<
              _$LocalPracticeDatabase,
              $SavedCueEntriesTable,
              SavedCueEntry
            >,
          ),
          SavedCueEntry,
          PrefetchHooks Function()
        > {
  $$SavedCueEntriesTableTableManager(
    _$LocalPracticeDatabase db,
    $SavedCueEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedCueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedCueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedCueEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerCacheKey = const Value.absent(),
                Value<String> mediaItemId = const Value.absent(),
                Value<String> cueId = const Value.absent(),
                Value<int> cueIndex = const Value.absent(),
                Value<String> cueText = const Value.absent(),
                Value<int?> startTimeMs = const Value.absent(),
                Value<int?> endTimeMs = const Value.absent(),
                Value<String?> cueMode = const Value.absent(),
                Value<String?> parentCueId = const Value.absent(),
                Value<int?> parentCueIndex = const Value.absent(),
                Value<String> mediaItemJson = const Value.absent(),
                Value<int> savedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedCueEntriesCompanion(
                id: id,
                ownerCacheKey: ownerCacheKey,
                mediaItemId: mediaItemId,
                cueId: cueId,
                cueIndex: cueIndex,
                cueText: cueText,
                startTimeMs: startTimeMs,
                endTimeMs: endTimeMs,
                cueMode: cueMode,
                parentCueId: parentCueId,
                parentCueIndex: parentCueIndex,
                mediaItemJson: mediaItemJson,
                savedAtMillis: savedAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerCacheKey,
                required String mediaItemId,
                required String cueId,
                required int cueIndex,
                required String cueText,
                Value<int?> startTimeMs = const Value.absent(),
                Value<int?> endTimeMs = const Value.absent(),
                Value<String?> cueMode = const Value.absent(),
                Value<String?> parentCueId = const Value.absent(),
                Value<int?> parentCueIndex = const Value.absent(),
                required String mediaItemJson,
                required int savedAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => SavedCueEntriesCompanion.insert(
                id: id,
                ownerCacheKey: ownerCacheKey,
                mediaItemId: mediaItemId,
                cueId: cueId,
                cueIndex: cueIndex,
                cueText: cueText,
                startTimeMs: startTimeMs,
                endTimeMs: endTimeMs,
                cueMode: cueMode,
                parentCueId: parentCueId,
                parentCueIndex: parentCueIndex,
                mediaItemJson: mediaItemJson,
                savedAtMillis: savedAtMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedCueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalPracticeDatabase,
      $SavedCueEntriesTable,
      SavedCueEntry,
      $$SavedCueEntriesTableFilterComposer,
      $$SavedCueEntriesTableOrderingComposer,
      $$SavedCueEntriesTableAnnotationComposer,
      $$SavedCueEntriesTableCreateCompanionBuilder,
      $$SavedCueEntriesTableUpdateCompanionBuilder,
      (
        SavedCueEntry,
        BaseReferences<
          _$LocalPracticeDatabase,
          $SavedCueEntriesTable,
          SavedCueEntry
        >,
      ),
      SavedCueEntry,
      PrefetchHooks Function()
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
  $$LocalCueAttemptEntriesTableTableManager get localCueAttemptEntries =>
      $$LocalCueAttemptEntriesTableTableManager(
        _db,
        _db.localCueAttemptEntries,
      );
  $$SavedCueEntriesTableTableManager get savedCueEntries =>
      $$SavedCueEntriesTableTableManager(_db, _db.savedCueEntries);
}
