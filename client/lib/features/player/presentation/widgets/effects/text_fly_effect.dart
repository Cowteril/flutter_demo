import 'package:flutter/material.dart';

class TextFlyEffect extends StatefulWidget {
  const TextFlyEffect({
    required this.text,
    required this.position,
    this.color = const Color(0xFFFFD166),
    this.duration = const Duration(milliseconds: 1200),
    super.key,
  });

  final String text;
  final Offset position;
  final Color color;
  final Duration duration;

  @override
  State<TextFlyEffect> createState() => _TextFlyEffectState();
}

class _TextFlyEffectState extends State<TextFlyEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = Curves.easeOutCubic.transform(_controller.value);
          final opacity = (1 - _controller.value).clamp(0, 1).toDouble();

          return Transform.translate(
            offset: Offset(0, -80 * progress),
            child: Transform.scale(
              scale: 0.78 + progress * 0.35,
              child: Opacity(
                opacity: opacity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.45),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    child: Text(
                      widget.text,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
