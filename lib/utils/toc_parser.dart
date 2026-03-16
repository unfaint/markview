/// A parsed heading entry for the Table of Contents.
class TocEntry {
  const TocEntry({
    required this.level,
    required this.text,
    required this.anchor,
  });

  /// Heading level: 1 for H1, 2 for H2, etc.
  final int level;
  final String text;

  /// URL-safe anchor slug matching flutter_markdown's default behaviour.
  final String anchor;
}

/// Parses the headings from raw Markdown content and returns a [TocEntry] list.
List<TocEntry> parseToc(String markdown) {
  final entries = <TocEntry>[];
  final headingRegex = RegExp(
    r'^(#{1,6})\s+(.+?)(?:\s+#+)?\s*$',
    multiLine: true,
  );

  for (final match in headingRegex.allMatches(markdown)) {
    final level = match.group(1)!.length;
    final text = match.group(2)!.trim();
    final anchor = _slugify(text);
    entries.add(TocEntry(level: level, text: text, anchor: anchor));
  }

  return entries;
}

/// Converts heading text to a GitHub-style URL slug.
String _slugify(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s-]'), '')
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
