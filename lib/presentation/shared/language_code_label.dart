/// Presentation only: do not use this value as an API or preference key.
/// Language is lowercase, script is title case, and region is uppercase.
String languageCodeLabel(String identifier) {
  final parts = identifier.trim().replaceAll('_', '-').toLowerCase().split('-');
  var extension = false;
  for (var i = 1; i < parts.length; i++) {
    final part = parts[i];
    if (part.length == 1) extension = true;
    if (extension) continue;
    if (RegExp(r'^[a-z]{2}$').hasMatch(part)) {
      parts[i] = part.toUpperCase();
    } else if (RegExp(r'^[a-z]{4}$').hasMatch(part)) {
      parts[i] = '${part[0].toUpperCase()}${part.substring(1)}';
    }
  }
  return parts.join('-');
}
