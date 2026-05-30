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
    final maxRadius = size.longestSide * 0.58;
    final radius = 18 + maxRadius * progress;
    final flashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14 * opacity);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10 * (1 - progress) + 2
      ..color = Colors.white.withValues(alpha: 0.8 * opacity);

    canvas.drawRect(Offset.zero & size, flashPaint);
    canvas.drawCircle(center, radius, ringPaint);
    canvas.drawCircle(
      center,
      radius * 0.58,
      ringPaint
        ..color = const Color(0xFFFFD166).withValues(alpha: 0.5 * opacity),
    );
  }

  @override
  bool shouldRepaint(covariant _ShockwavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.opacity != opacity ||
        oldDelegate.center != center;
  }
}
