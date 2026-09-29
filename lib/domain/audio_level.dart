/// Shared wire/storage values. Null represents All levels (no generation choice).
enum AudioLevel {
  beginner,
  intermediate,
  advanced;

  static AudioLevel? fromStorage(String? value) {
    for (final level in values) {
      if (level.name == value) return level;
    }
    return null;
  }
}
