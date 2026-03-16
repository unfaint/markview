import 'package:path/path.dart' as p;

/// Represents an opened Markdown document.
class Document {
  const Document({required this.path, required this.content});

  final String path;
  final String content;

  String get title {
    // Use first H1 heading if present, otherwise filename without extension.
    final h1Match = RegExp(r'^#\s+(.+)$', multiLine: true).firstMatch(content);
    if (h1Match != null) {
      return h1Match.group(1)!.trim();
    }
    return p.basenameWithoutExtension(path);
  }

  String get directory => p.dirname(path);

  bool get isEmpty => content.trim().isEmpty;

  Document copyWith({String? path, String? content}) {
    return Document(path: path ?? this.path, content: content ?? this.content);
  }
}
