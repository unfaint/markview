import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Platform-aware file utilities.
abstract final class FileUtils {
  /// Opens the OS file picker filtered to Markdown files.
  /// Returns the selected file path (or null if cancelled).
  /// On web, returns a virtual path; content must be read from [PlatformFile.bytes].
  static Future<String?> pickMarkdownFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['md', 'markdown', 'txt'],
      withData: kIsWeb,
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.single.path ?? result.files.single.name;
  }

  /// Reads the content of a Markdown file at [path].
  /// On web, [FilePicker] provides bytes directly; call [readFileBytes] instead.
  static Future<String> readFile(String path) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Use readFileBytes() on web; path-based reading is unavailable.',
      );
    }
    return File(path).readAsString();
  }

  /// Reads content from raw UTF-8 bytes (used on web).
  static String readFileBytes(List<int> bytes) {
    return String.fromCharCodes(bytes);
  }

  /// Checks whether a file exists (non-web only).
  static Future<bool> exists(String path) async {
    if (kIsWeb) return false;
    return File(path).exists();
  }
}
