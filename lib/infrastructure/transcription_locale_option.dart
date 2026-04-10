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
