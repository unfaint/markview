import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Search overlay that appears at the top of the viewer.
/// Notifies the parent of the current [query] via [onQueryChanged].
class SearchOverlay extends StatefulWidget {
  const SearchOverlay({
    super.key,
    required this.onQueryChanged,
    required this.onClose,
    required this.matchCount,
    required this.currentMatch,
    required this.onNext,
    required this.onPrevious,
  });

  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClose;
  final int matchCount;
  final int currentMatch;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field when overlay opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMatches = widget.matchCount > 0;
    final matchLabel = widget.matchCount == 0
        ? 'No results'
        : '${widget.currentMatch + 1} / ${widget.matchCount}';

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          widget.onClose();
        }
      },
      child: Material(
        elevation: 2,
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.search, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Find in document...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: widget.onQueryChanged,
                  onSubmitted: (_) => widget.onNext(),
                ),
              ),
              if (_controller.text.isNotEmpty)
                Text(
                  matchLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: hasMatches
                        ? null
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up, size: 20),
                tooltip: 'Previous match',
                onPressed: hasMatches ? widget.onPrevious : null,
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                tooltip: 'Next match',
                onPressed: hasMatches ? widget.onNext : null,
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                tooltip: 'Close search (Esc)',
                onPressed: widget.onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
