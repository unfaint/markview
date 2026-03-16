import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/document_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/toc_parser.dart';
import '../widgets/markdown_viewer.dart';
import '../widgets/search_overlay.dart';
import '../widgets/toc_panel.dart';

class ViewerScreen extends ConsumerStatefulWidget {
  const ViewerScreen({super.key});

  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends ConsumerState<ViewerScreen> {
  bool _tocOpen = false;
  bool _searchOpen = false;
  String _searchQuery = '';
  int _matchCount = 0;
  int _currentMatch = 0;

  // Key used to rebuild the Markdown widget and scroll to matches.
  final _markdownKey = GlobalKey();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleToc() => setState(() => _tocOpen = !_tocOpen);

  void _openSearch() => setState(() => _searchOpen = true);

  void _closeSearch() {
    setState(() {
      _searchOpen = false;
      _searchQuery = '';
      _matchCount = 0;
      _currentMatch = 0;
    });
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      _searchQuery = query;
      _currentMatch = 0;
      // Match count is computed by the viewer widget via a simple string scan.
      _matchCount = query.isEmpty
          ? 0
          : _countMatches(
              ref.read(documentProvider).value?.content ?? '',
              query,
            );
    });
  }

  int _countMatches(String content, String query) {
    if (query.isEmpty) return 0;
    final lower = content.toLowerCase();
    final q = query.toLowerCase();
    int count = 0;
    int idx = 0;
    while ((idx = lower.indexOf(q, idx)) != -1) {
      count++;
      idx += q.length;
    }
    return count;
  }

  void _nextMatch() {
    if (_matchCount == 0) return;
    setState(() => _currentMatch = (_currentMatch + 1) % _matchCount);
  }

  void _previousMatch() {
    if (_matchCount == 0) return;
    setState(
      () => _currentMatch = (_currentMatch - 1 + _matchCount) % _matchCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final documentAsync = ref.watch(documentProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: _buildAppBar(context, ref, documentAsync, themeMode),
      body: documentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (doc) {
          if (doc == null) {
            Navigator.of(context).maybePop();
            return const SizedBox.shrink();
          }
          return _buildContent(context, doc.content);
        },
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    AsyncValue documentAsync,
    ThemeMode themeMode,
  ) {
    final title = documentAsync.value?.title ?? 'markview';

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_outlined),
          tooltip: 'Search (Ctrl+F)',
          onPressed: _openSearch,
        ),
        IconButton(
          icon: Icon(
            _tocOpen
                ? Icons.format_list_bulleted
                : Icons.format_list_bulleted_outlined,
          ),
          tooltip: 'Table of contents',
          onPressed: _toggleToc,
        ),
        IconButton(
          icon: Icon(_themeIcon(themeMode)),
          tooltip: 'Toggle theme',
          onPressed: () => ref.read(themeModeProvider.notifier).cycle(),
        ),
        IconButton(
          icon: const Icon(Icons.folder_open_outlined),
          tooltip: 'Open another file',
          onPressed: () => ref.read(documentProvider.notifier).pickAndOpen(),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, String content) {
    final tocEntries = parseToc(content);
    final isWide = MediaQuery.of(context).size.width > 900;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            _openSearch,
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true): _openSearch,
        const SingleActivator(LogicalKeyboardKey.escape): _closeSearch,
      },
      child: Focus(
        autofocus: true,
        child: Column(
          children: [
            if (_searchOpen)
              SearchOverlay(
                onQueryChanged: _onSearchQueryChanged,
                onClose: _closeSearch,
                matchCount: _matchCount,
                currentMatch: _currentMatch,
                onNext: _nextMatch,
                onPrevious: _previousMatch,
              ),
            Expanded(
              child: isWide && _tocOpen
                  ? _wideLayout(content, tocEntries)
                  : _narrowLayout(context, content, tocEntries),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wideLayout(String content, List<TocEntry> tocEntries) {
    return Row(
      children: [
        SizedBox(
          width: 240,
          child: TocPanel(entries: tocEntries, onEntryTap: (_) {}),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: _markdownView(content)),
      ],
    );
  }

  Widget _narrowLayout(
    BuildContext context,
    String content,
    List<TocEntry> tocEntries,
  ) {
    return Stack(
      children: [
        _markdownView(content),
        if (_tocOpen)
          GestureDetector(
            onTap: _toggleToc,
            child: Container(color: Colors.black54),
          ),
        if (_tocOpen)
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: 260,
            child: Material(
              elevation: 4,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Contents',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: _toggleToc,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: TocPanel(
                      entries: tocEntries,
                      onEntryTap: (_) => _toggleToc(),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _markdownView(String content) {
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: MarkdownViewer(key: _markdownKey, content: content),
          ),
        ),
      ),
    );
  }

  IconData _themeIcon(ThemeMode mode) => switch (mode) {
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
    ThemeMode.system => Icons.brightness_auto_outlined,
  };
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to open file',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
