import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kHistoryKey = 'recent_files';
const _kMaxHistory = 10;

/// Persisted list of recently opened file paths (newest first).
final historyProvider = StateNotifierProvider<HistoryNotifier, List<String>>(
  (ref) => HistoryNotifier(),
);

class HistoryNotifier extends StateNotifier<List<String>> {
  HistoryNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_kHistoryKey) ?? [];
  }

  Future<void> addFile(String path) async {
    final updated = [
      path,
      ...state.where((p) => p != path),
    ].take(_kMaxHistory).toList();
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kHistoryKey, updated);
  }

  Future<void> removeFile(String path) async {
    state = state.where((p) => p != path).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kHistoryKey, state);
  }

  Future<void> clear() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kHistoryKey);
  }
}
