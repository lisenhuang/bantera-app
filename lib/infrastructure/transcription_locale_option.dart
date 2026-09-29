class TranscriptionLocaleOption {
  const TranscriptionLocaleOption({
    required this.identifier,
    required String displayName,
    required this.isInstalled,
    this.flagEmoji,
  }) : _displayName = displayName;

  factory TranscriptionLocaleOption.fromMap(Map<Object?, Object?> map) {
    return TranscriptionLocaleOption(
      identifier: map['identifier']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? '',
      isInstalled: map['isInstalled'] == true,
      flagEmoji: map['flagEmoji']?.toString(),
    );
  }

  final String identifier;
  final String _displayName;
  String get displayName => localeDisplayName(identifier, _displayName);
  final bool isInstalled;
  final String? flagEmoji;
}

/// Keep the Taiwan Mandarin accent name consistent across API/native pickers.
String localeDisplayName(String identifier, String displayName) {
  final code = normalizeLocaleIdentifierForLookup(identifier);
  return code == 'zh-tw' || code == 'zh-hant-tw'
      ? 'Mandarin (Taiwan)'
      : displayName;
}

String normalizeLocaleIdentifierForLookup(String identifier) {
  return identifier.trim().replaceAll('_', '-').toLowerCase();
}

String? primaryLanguageCodeForLocaleIdentifier(String identifier) {
  final normalized = normalizeLocaleIdentifierForLookup(identifier);
  if (normalized.isEmpty) return null;
  return normalized.split('-').first;
}

String normalizeLegacyLearningLanguageIdentifier(String identifier) {
  final normalized = normalizeLocaleIdentifierForLookup(identifier);
  return switch (normalized) {
    'fr' => 'fr-FR',
    'it' => 'it-IT',
    'de' => 'de-DE',
    'es' => 'es-ES',
    _ => identifier.trim().replaceAll('_', '-'),
  };
}
