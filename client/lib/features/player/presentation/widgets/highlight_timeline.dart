import 'package:flutter/material.dart';

import '../../../drama/domain/models/highlight_point.dart';

class HighlightTimeline extends StatelessWidget {
  const HighlightTimeline({
    required this.duration,
    required this.position,
    required this.highlights,
    required this.onJump,
    super.key,
  });

  final Duration duration;
  final Duration position;
  final List<HighlightPoint> highlights;
  final ValueChanged<HighlightPoint> onJump;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalSeconds = duration.inSeconds.clamp(1, 999999);
          final progress =
              position.inSeconds.clamp(0, totalSeconds) / totalSeconds;

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned.fill(
                top: 18,
                bottom: 18,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 18,
                bottom: 18,
                width: constraints.maxWidth * progress,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.76),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              for (final highlight in highlights)
                _HighlightMarker(
                  left: constraints.maxWidth *
                      (highlight.at.inSeconds.clamp(0, totalSeconds) /
                          totalSeconds),
                  highlight: highlight,
                  onTap: () => onJump(highlight),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HighlightMarker extends StatefulWidget {
  const _HighlightMarker({
    required this.left,
    required this.highlight,
    required this.onTap,
  });

  final double left;
  final HighlightPoint highlight;
  final VoidCallback onTap;

  @override
  State<_HighlightMarker> createState() => _HighlightMarkerState();
}

class _HighlightMarkerState extends State<_HighlightMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (widget.highlight.kind) {
      HighlightKind.reaction => (
          const Color(0xFFFF8A2A),
          Icons.local_fire_department
        ),
      HighlightKind.branch => (
          const Color(0xFFB56CFF),
          Icons.account_tree_outlined
        ),
      HighlightKind.extension => (const Color(0xFFFFD166), Icons.auto_awesome),
      HighlightKind.prediction => (
          const Color(0xFF7DD3FC),
          Icons.psychology_alt
        ),
    };

    return Positioned(
      left: widget.left - 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.92 + _controller.value * 0.18,
            child: child,
          );
        },
        child: Tooltip(
          message: widget.highlight.title,
          child: InkResponse(
            onTap: widget.onTap,
            radius: 24,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.55),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: SizedBox.square(
                dimension: 32,
                child: Icon(icon, color: Colors.black, size: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
