import 'dart:math' as math;

import 'package:flutter/material.dart';

class ShockwaveEffect extends StatefulWidget {
  const ShockwaveEffect({
    required this.position,
    this.duration = const Duration(milliseconds: 900),
    super.key,
  });

  final Offset position;
  final Duration duration;

  @override
  State<ShockwaveEffect> createState() => _ShockwaveEffectState();
}

class _ShockwaveEffectState extends State<ShockwaveEffect>
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
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = Curves.easeOutCubic.transform(_controller.value);
          final opacity = (1 - _controller.value).clamp(0, 1).toDouble();

          return CustomPaint(
            painter: _ShockwavePainter(
              center: widget.position,
              progress: progress,
              opacity: opacity,
            ),
          );
        },
      ),
    );
  }
}

class _ShockwavePainter extends CustomPainter {
  const _ShockwavePainter({
    required this.center,
    required this.progress,
    required this.opacity,
  });

  final Offset center;
  final double progress;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final maxRadius = size.longestSide * 0.62;
    final radius = 18 + maxRadius * progress;
    final flashPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (center.dx / size.width - 0.5) * 2,
          (center.dy / size.height - 0.5) * 2,
        ),
        radius: 0.82,
        colors: [
          Colors.white.withValues(alpha: 0.18 * opacity),
          const Color(0xFFFFD166).withValues(alpha: 0.12 * opacity),
          Colors.transparent,
        ],
      ).createShader(rect);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(Offset.zero & size, flashPaint);

    for (var index = 0; index < 4; index++) {
      final local = ((progress - index * 0.08) / (1 - index * 0.08))
          .clamp(0.0, 1.0)
          .toDouble();
      final localRadius = 18 + maxRadius * local * (1 - index * 0.1);
      ringPaint
        ..strokeWidth = (12 - index * 2) * (1 - local) + 1.6
        ..color = Color.lerp(
          Colors.white,
          const Color(0xFFFFD166),
          index / 3,
        )!
            .withValues(alpha: opacity * (0.76 - index * 0.12));
      canvas.drawCircle(center, localRadius, ringPaint);

      final arcRect =
          Rect.fromCircle(center: center, radius: localRadius * 0.78);
      canvas.drawArc(
        arcRect,
        -math.pi / 2 + index * 0.8,
        math.pi * (0.42 + index * 0.08),
        false,
        ringPaint
          ..strokeWidth = 4 * (1 - local) + 1
          ..color = const Color(0xFFFFF0A3).withValues(alpha: opacity * 0.42),
      );
    }

    final rayPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 22; index++) {
      final angle = index * math.pi * 2 / 22;
      final start = radius * (0.26 + (index % 3) * 0.04);
      final end = start + 84 * (1 - progress);
      rayPaint
        ..strokeWidth = index.isEven ? 2.6 : 1.2
        ..color = (index.isEven ? Colors.white : const Color(0xFFFFD166))
            .withValues(alpha: opacity * 0.26);
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * start,
        center + Offset(math.cos(angle), math.sin(angle)) * end,
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ShockwavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.opacity != opacity ||
        oldDelegate.center != center;
  }
}
