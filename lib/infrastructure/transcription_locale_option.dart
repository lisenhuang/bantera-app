class TranscriptionLocaleOption {
  const TranscriptionLocaleOption({
    required this.identifier,
    required this.displayName,
    required this.isInstalled,
    this.flagEmoji,
  });

  factory TranscriptionLocaleOption.fromMap(Map<Object?, Object?> map) {
    return TranscriptionLocaleOption(
      identifier: map['identifier']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? '',
      isInstalled: map['isInstalled'] == true,
      flagEmoji: map['flagEmoji']?.toString(),
    );
  }

  final String identifier;
  final String displayName;
  final bool isInstalled;
  final String? flagEmoji;
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
