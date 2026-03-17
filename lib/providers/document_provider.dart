import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/document.dart';
import '../utils/file_utils.dart';
import 'history_provider.dart';

/// Holds the currently open [Document], or null when no file is open.
final documentProvider =
    StateNotifierProvider<DocumentNotifier, AsyncValue<Document?>>(
      (ref) => DocumentNotifier(ref),
    );

class DocumentNotifier extends StateNotifier<AsyncValue<Document?>> {
  DocumentNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> openFile(String path) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final content = await FileUtils.readFile(path);
      final doc = Document(path: path, content: content);
      await _ref.read(historyProvider.notifier).addFile(path);
      return doc;
    });
  }

  Future<void> pickAndOpen() async {
    final file = await FileUtils.pickMarkdownFile();
    if (file == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final String content;
      final String displayPath;
      if (kIsWeb) {
        final bytes = file.bytes;
        if (bytes == null) throw StateError('No bytes available for web file.');
        content = FileUtils.readFileBytes(bytes);
        displayPath = file.name;
      } else {
        final path = file.path!;
        content = await FileUtils.readFile(path);
        displayPath = path;
      }
      final doc = Document(path: displayPath, content: content);
      await _ref.read(historyProvider.notifier).addFile(displayPath);
      return doc;
    });
  }

  void close() => state = const AsyncValue.data(null);
}
