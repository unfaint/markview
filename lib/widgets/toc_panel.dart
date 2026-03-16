import 'package:flutter/material.dart';

import '../utils/toc_parser.dart';

/// A Table of Contents panel that lists parsed [TocEntry] headings.
/// Tapping an entry calls [onEntryTap] with the anchor slug.
class TocPanel extends StatelessWidget {
  const TocPanel({
    super.key,
    required this.entries,
    required this.onEntryTap,
    this.activeAnchor,
  });

  final List<TocEntry> entries;
  final ValueChanged<String> onEntryTap;
  final String? activeAnchor;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No headings found',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withAlpha(102),
                ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: entries.length,
      itemBuilder: (context, index) => _TocTile(
        entry: entries[index],
        isActive: entries[index].anchor == activeAnchor,
        onTap: () => onEntryTap(entries[index].anchor),
      ),
    );
  }
}

class _TocTile extends StatelessWidget {
  const _TocTile({
    required this.entry,
    required this.onTap,
    required this.isActive,
  });

  final TocEntry entry;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final indent = (entry.level - 1) * 12.0;
    final isH1 = entry.level == 1;
    final color = isActive
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withAlpha(isH1 ? 204 : 153);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16 + indent,
          right: 16,
          top: 6,
          bottom: 6,
        ),
        child: Row(
          children: [
            if (isActive)
              Container(
                width: 3,
                height: 14,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            Expanded(
              child: Text(
                entry.text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isH1 ? 13 : 12,
                  fontWeight:
                      isH1 ? FontWeight.w600 : FontWeight.normal,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
