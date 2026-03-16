import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/github-dark.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

/// Renders Markdown content with syntax-highlighted code blocks.
class MarkdownViewer extends StatelessWidget {
  const MarkdownViewer({
    super.key,
    required this.content,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
  });

  final String content;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Markdown(
      data: content,
      selectable: true,
      padding: padding,
      extensionSet: md.ExtensionSet(
        md.ExtensionSet.gitHubFlavored.blockSyntaxes,
        <md.InlineSyntax>[
          md.EmojiSyntax(),
          ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
        ],
      ),
      builders: {'code': _CodeBlockBuilder(isDark: isDark)},
      onTapLink: (text, href, title) async {
        if (href == null) return;
        final uri = Uri.tryParse(href);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      styleSheet: _buildStyleSheet(context),
    );
  }

  MarkdownStyleSheet _buildStyleSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final codeBackground = isDark
        ? const Color(0xFF161B22)
        : const Color(0xFFF6F8FA);

    return MarkdownStyleSheet(
      h1: theme.textTheme.headlineMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      h2: theme.textTheme.headlineSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      h3: theme.textTheme.titleLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      h4: theme.textTheme.titleMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      p: theme.textTheme.bodyLarge?.copyWith(color: textColor, height: 1.7),
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        color: isDark ? const Color(0xFFFF7B72) : const Color(0xFFCF222E),
        backgroundColor: codeBackground,
      ),
      codeblockDecoration: BoxDecoration(
        color: codeBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
        ),
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
            width: 4,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
      blockquote: theme.textTheme.bodyLarge?.copyWith(
        color: isDark ? const Color(0xFF8B949E) : const Color(0xFF57606A),
        height: 1.7,
      ),
      tableHead: TextStyle(fontWeight: FontWeight.w600, color: textColor),
      tableBody: TextStyle(color: textColor),
      tableBorder: TableBorder.all(
        color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
          ),
        ),
      ),
    );
  }
}

/// Custom builder that renders fenced code blocks with syntax highlighting.
class _CodeBlockBuilder extends MarkdownElementBuilder {
  _CodeBlockBuilder({required this.isDark});

  final bool isDark;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag != 'code') return null;

    final code = element.textContent;
    final className = element.attributes['class'] ?? '';
    final language = className.startsWith('language-')
        ? className.substring(9)
        : 'text';

    return _HighlightBlock(code: code, language: language, isDark: isDark);
  }
}

class _HighlightBlock extends StatelessWidget {
  const _HighlightBlock({
    required this.code,
    required this.language,
    required this.isDark,
  });

  final String code;
  final String language;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HighlightView(
          code.trimRight(),
          language: language,
          theme: isDark ? githubDarkTheme : githubTheme,
          padding: const EdgeInsets.all(16),
          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            height: 1.5,
          ),
        ),
        Positioned(top: 6, right: 6, child: _CopyButton(code: code)),
      ],
    );
  }
}

class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.code});
  final String code;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_copied ? Icons.check : Icons.copy_outlined, size: 16),
      tooltip: _copied ? 'Copied!' : 'Copy code',
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: widget.code));
        setState(() => _copied = true);
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _copied = false);
      },
    );
  }
}
