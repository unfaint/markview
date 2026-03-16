# markview

A lightweight, cross-platform Markdown viewer for iOS, Android, macOS, Windows, Linux, and Web.

[![CI](https://github.com/your-org/markview/actions/workflows/ci.yml/badge.svg)](https://github.com/your-org/markview/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Features

- **Full GFM support** — headings, bold/italic/strikethrough, tables, blockquotes, task lists, fenced code blocks
- **Syntax highlighting** — code blocks highlighted for 100+ languages
- **Table of Contents** — auto-generated, collapsible sidebar
- **In-document search** — Ctrl+F / Cmd+F with match navigation
- **Light, dark, and system themes**
- **Recent files** — quickly reopen the last 10 files
- **Copy code** — one-click copy button on every code block
- **Runs everywhere** — one app for all your devices

## Download

| Platform | Download |
|----------|----------|
| Android  | [APK](https://github.com/your-org/markview/releases/latest) |
| macOS    | [DMG](https://github.com/your-org/markview/releases/latest) |
| Windows  | [ZIP](https://github.com/your-org/markview/releases/latest) |
| Linux    | [tar.gz](https://github.com/your-org/markview/releases/latest) |
| Web      | [markview.app](https://your-org.github.io/markview/) |

iOS: build from source (requires Apple Developer account for distribution).

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Ctrl+F / Cmd+F | Open search |
| Escape | Close search |
| Enter / Shift+Enter | Next / previous match |

## Build from Source

**Prerequisites:** [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, ≥ 3.22)

```bash
git clone https://github.com/your-org/markview.git
cd markview

# Initialize platform targets (first time only)
flutter create --platforms=android,ios,macos,windows,linux,web .

flutter pub get

# Run on connected device or emulator
flutter run

# Build release for a specific platform
flutter build apk --release      # Android
flutter build ios --release      # iOS (requires macOS + Xcode)
flutter build macos --release    # macOS
flutter build windows --release  # Windows
flutter build linux --release    # Linux
flutter build web --release      # Web
```

## Project Structure

```
lib/
├── main.dart              # Entry point
├── app.dart               # App shell, themes, routing
├── models/document.dart   # Document data model
├── providers/             # Riverpod state (theme, document, history)
├── screens/               # HomeScreen, ViewerScreen
├── widgets/               # MarkdownViewer, TocPanel, SearchOverlay
└── utils/                 # File I/O, TOC parsing
```

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

[MIT](LICENSE) © 2026 markview contributors
