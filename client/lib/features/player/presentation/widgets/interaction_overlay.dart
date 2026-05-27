import 'package:flutter/material.dart';

import '../../../drama/domain/models/highlight_point.dart';

class InteractionOverlay extends StatelessWidget {
  const InteractionOverlay({
    required this.highlight,
    required this.onDismiss,
    required this.onSelect,
    super.key,
  });

  final HighlightPoint highlight;
  final VoidCallback onDismiss;
  final ValueChanged<InteractionOption> onSelect;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 18,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(_iconForKind(highlight.kind)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      highlight.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Tooltip(
                    message: '关闭',
                    child: IconButton(
                      onPressed: onDismiss,
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(highlight.description),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in highlight.options)
                    FilledButton(
                      onPressed: () => onSelect(option),
                      child: Text(option.label),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _iconForKind(HighlightKind kind) {
  return switch (kind) {
    HighlightKind.reaction => Icons.emoji_emotions_outlined,
    HighlightKind.branch => Icons.account_tree_outlined,
    HighlightKind.extension => Icons.auto_awesome_outlined,
  };
}
