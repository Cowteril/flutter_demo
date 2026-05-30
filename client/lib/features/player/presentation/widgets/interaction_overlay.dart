import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../drama/domain/models/highlight_point.dart';

class InteractionOverlay extends StatefulWidget {
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
  State<InteractionOverlay> createState() => _InteractionOverlayState();
}

class _InteractionOverlayState extends State<InteractionOverlay> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 18,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        elevation: 10,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(_iconForKind(widget.highlight.kind)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.highlight.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Tooltip(
                    message: '关闭',
                    child: IconButton(
                      onPressed: widget.onDismiss,
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(widget.highlight.description),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var index = 0;
                      index < widget.highlight.options.length;
                      index++)
                    _AnimatedOptionButton(
                      option: widget.highlight.options[index],
                      onSelect: widget.onSelect,
                    )
                        .animate(delay: (index * 45).ms)
                        .fadeIn(duration: 180.ms, curve: Curves.easeOut)
                        .slideY(
                          begin: 0.18,
                          end: 0,
                          duration: 220.ms,
                          curve: Curves.easeOutCubic,
                        ),
                ],
              ),
            ],
          ),
        ),
      )
          .animate(key: ValueKey(widget.highlight.id))
          .fadeIn(duration: 180.ms, curve: Curves.easeOut)
          .slideY(
            begin: 0.16,
            end: 0,
            duration: 240.ms,
            curve: Curves.easeOutCubic,
          )
          .scaleXY(
            begin: 0.96,
            end: 1,
            duration: 240.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}

class _AnimatedOptionButton extends StatefulWidget {
  const _AnimatedOptionButton({
    required this.option,
    required this.onSelect,
  });

  final InteractionOption option;
  final ValueChanged<InteractionOption> onSelect;

  @override
  State<_AnimatedOptionButton> createState() => _AnimatedOptionButtonState();
}

class _AnimatedOptionButtonState extends State<_AnimatedOptionButton> {
  var _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1,
        duration: 90.ms,
        curve: Curves.easeOutCubic,
        child: FilledButton(
          onPressed: () => widget.onSelect(widget.option),
          child: Text(widget.option.label),
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
