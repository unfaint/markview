import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../providers/document_provider.dart';
import '../providers/history_provider.dart';
import '../providers/theme_provider.dart';
import 'viewer_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentAsync = ref.watch(documentProvider);
    final history = ref.watch(historyProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Navigate to viewer when a document is loaded.
    ref.listen(documentProvider, (_, next) {
      next.whenData((doc) {
        if (doc != null) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const ViewerScreen()));
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'markview',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: _themeTooltip(themeMode),
            icon: Icon(_themeIcon(themeMode)),
            onPressed: () => ref.read(themeModeProvider.notifier).cycle(),
          ),
        ],
      ),
      body: documentAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, ref, history),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ref.read(documentProvider.notifier).pickAndOpen(),
        icon: const Icon(Icons.folder_open_outlined),
        label: const Text('Open file'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, List<String> history) {
    if (history.isEmpty) {
      return _EmptyState(
        onOpen: () => ref.read(documentProvider.notifier).pickAndOpen(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Recent files',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final path = history[index];
              return _RecentFileTile(
                path: path,
                onTap: () => ref.read(documentProvider.notifier).openFile(path),
                onRemove: () =>
                    ref.read(historyProvider.notifier).removeFile(path),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _themeIcon(ThemeMode mode) => switch (mode) {
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
    ThemeMode.system => Icons.brightness_auto_outlined,
  };

  String _themeTooltip(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'Light theme',
    ThemeMode.dark => 'Dark theme',
    ThemeMode.system => 'System theme',
  };
}

class _RecentFileTile extends StatelessWidget {
  const _RecentFileTile({
    required this.path,
    required this.onTap,
    required this.onRemove,
  });

  final String path;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final filename = p.basename(path);
    final directory = p.dirname(path);
    final fileExists = File(path).existsSync();

    return ListTile(
      leading: Icon(
        Icons.description_outlined,
        color: fileExists
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withAlpha(102),
      ),
      title: Text(
        filename,
        style: TextStyle(
          color: fileExists
              ? null
              : Theme.of(context).colorScheme.onSurface.withAlpha(102),
        ),
      ),
      subtitle: Text(
        directory,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: fileExists ? onTap : null,
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 18),
        tooltip: 'Remove from history',
        onPressed: onRemove,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.article_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(51),
          ),
          const SizedBox(height: 16),
          Text(
            'No file open',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Open file" to browse your Markdown files.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(102),
            ),
          ),
        ],
      ),
    );
  }
}
