# Contributing to markview

Thank you for your interest in contributing! This document covers how to set up the project, submit issues, and open pull requests.

## Getting Started

1. **Fork** the repository and clone your fork:
   ```bash
   git clone https://github.com/your-username/markview.git
   cd markview
   ```

2. **Install Flutter** (stable channel, ≥ 3.22): https://docs.flutter.dev/get-started/install

3. **Initialize platform targets** (first time after cloning):
   ```bash
   flutter create --platforms=android,ios,macos,windows,linux,web .
   ```

4. **Install dependencies:**
   ```bash
   flutter pub get
   ```

5. **Run the app:**
   ```bash
   flutter run
   ```

## Development Workflow

- Create a branch from `main`: `git checkout -b feat/my-feature`
- Make your changes
- Run checks before pushing:
  ```bash
  dart format lib/ test/      # format
  flutter analyze             # lint
  flutter test                # tests
  ```
- Open a Pull Request against `main`

## Branch Naming

| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feat/<short-description>` | `feat/export-to-html` |
| Bug fix | `fix/<short-description>` | `fix/dark-theme-table-border` |
| Documentation | `docs/<short-description>` | `docs/update-shortcuts` |
| Chore | `chore/<short-description>` | `chore/bump-flutter-version` |

## Reporting Bugs

Please open a [GitHub Issue](https://github.com/your-org/markview/issues) with:
- Platform (macOS / Windows / Linux / iOS / Android / Web)
- markview version
- Steps to reproduce
- Expected vs actual behaviour
- A sample `.md` file if relevant

## Adding a New Theme

1. Theme is defined in `lib/app.dart` inside `_buildLightTheme()` / `_buildDarkTheme()`.
2. `ThemeMode` cycles through light → dark → system.
3. To add a sepia theme, extend `ThemeModeNotifier` with an additional state and add a fourth `ThemeData` in `app.dart`.

## Adding Markdown Extensions

All Markdown rendering goes through `flutter_markdown`. To add a new extension:
1. Check if a `flutter_markdown` builder or extension already exists.
2. Add a custom `MarkdownElementBuilder` in `lib/widgets/markdown_viewer.dart`.
3. Register it in the `builders` map of the `Markdown` widget.

## Code Style

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style).
- Run `dart format` before committing — CI enforces this.
- Avoid `print()` statements; use `debugPrint()` for debug output.
- Prefer `const` constructors wherever possible.
- All public APIs should have doc comments (`///`).

## License

By contributing you agree that your contributions will be licensed under the [MIT License](LICENSE).
