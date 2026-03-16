import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markview/widgets/markdown_viewer.dart';

void main() {
  group('MarkdownViewer', () {
    testWidgets('renders plain text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownViewer(content: 'Hello, world!'),
          ),
        ),
      );
      expect(find.textContaining('Hello, world!'), findsOneWidget);
    });

    testWidgets('renders heading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownViewer(content: '# My Heading'),
          ),
        ),
      );
      expect(find.textContaining('My Heading'), findsOneWidget);
    });

    testWidgets('renders code block without crashing', (tester) async {
      const md = '''
```dart
void main() {
  print('hello');
}
```
''';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownViewer(content: md),
          ),
        ),
      );
      await tester.pump();
      // No crash and code content is present.
      expect(find.textContaining("print('hello')"), findsOneWidget);
    });

    testWidgets('renders GFM table without crashing', (tester) async {
      const md = '''
| Name | Value |
|------|-------|
| foo  | bar   |
''';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownViewer(content: md),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('foo'), findsOneWidget);
    });
  });
}
