import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
          final rawProgress = _controller.value;
          final entrance = Curves.elasticOut
              .transform((rawProgress / 0.36).clamp(0.0, 1.0).toDouble());
          final exit = Curves.easeInCubic.transform(
            ((rawProgress - 0.52) / 0.48).clamp(0.0, 1.0).toDouble(),
          );
          final opacity =
              (rawProgress < 0.68 ? 1 : 1 - (rawProgress - 0.68) / 0.32)
                  .clamp(0.0, 1.0)
                  .toDouble();
          final rotation =
              math.sin(rawProgress * math.pi * 5) * 0.035 * (1 - exit);

          return Transform.translate(
            offset: Offset(0, -18 * entrance - 92 * exit),
            child: Transform.scale(
              scale: 0.74 + entrance * 0.36 - exit * 0.08,
              child: Opacity(
                opacity: opacity,
                child: Transform.rotate(
                  angle: rotation,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.62),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.52),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ).animate(value: rawProgress, autoPlay: false).shake(
                        delay: 140.ms,
                        duration: 280.ms,
                        hz: 8,
                        offset: const Offset(2, 0),
                        rotation: 0.025,
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
