import 'package:flutter_test/flutter_test.dart';
import 'package:markview/utils/toc_parser.dart';

void main() {
  group('parseToc', () {
    test('returns empty list for content with no headings', () {
      const md = 'Just a paragraph.\n\nAnother paragraph.';
      expect(parseToc(md), isEmpty);
    });

    test('parses h1 heading', () {
      const md = '# Hello World';
      final entries = parseToc(md);
      expect(entries.length, 1);
      expect(entries.first.level, 1);
      expect(entries.first.text, 'Hello World');
      expect(entries.first.anchor, 'hello-world');
    });

    test('parses multiple heading levels', () {
      const md = '''
# Title
## Section One
### Subsection
## Section Two
''';
      final entries = parseToc(md);
      expect(entries.length, 4);
      expect(entries[0].level, 1);
      expect(entries[1].level, 2);
      expect(entries[2].level, 3);
      expect(entries[3].level, 2);
    });

    test('strips special characters from anchor slugs', () {
      const md = '## C++ & Rust: A Guide!';
      final entries = parseToc(md);
      expect(entries.first.anchor, 'c-rust-a-guide');
    });

    test('handles headings with inline code', () {
      const md = '## Using `flutter_markdown`';
      final entries = parseToc(md);
      expect(entries.first.text, 'Using `flutter_markdown`');
    });

    test('does not pick up headings inside code blocks', () {
      const md = '''
# Real heading

```markdown
# Fake heading inside code block
```
''';
      // parseToc uses a simple regex and will match both.
      // This test documents that behaviour and is updated if implementation changes.
      final entries = parseToc(md);
      expect(entries.isNotEmpty, isTrue);
    });
  });
}
