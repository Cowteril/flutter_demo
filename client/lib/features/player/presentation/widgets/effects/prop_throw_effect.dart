import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../companion/domain/ai_companion_models.dart';

class PropThrowEffect extends StatefulWidget {
  const PropThrowEffect({
    required this.type,
    required this.start,
    required this.target,
    super.key,
  });

  final CompanionPropType type;
  final Offset start;
  final Offset target;

  @override
  State<PropThrowEffect> createState() => _PropThrowEffectState();
}

class _PropThrowEffectState extends State<PropThrowEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 920),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final raw = _controller.value;
        final progress = Curves.easeInOutCubic.transform(raw);
        final target = widget.target;
        final projectile = _projectilePosition(progress);
        final impact = raw > 0.66 ? ((raw - 0.66) / 0.34).clamp(0.0, 1.0) : 0.0;

        return Stack(
          fit: StackFit.expand,
          children: [
            if (widget.type != CompanionPropType.glove && raw < 0.82)
              Positioned(
                left: projectile.dx - 18,
                top: projectile.dy - 18,
                child: Transform.rotate(
                  angle: progress * math.pi * 2,
                  child: Icon(
                    _iconFor(widget.type),
                    color: _colorFor(widget.type),
                    size: 36,
                    shadows: const [
                      Shadow(color: Colors.black87, blurRadius: 10),
                    ],
                  ),
                ),
              ),
            Positioned(
              left: target.dx - 46,
              top: target.dy - 46,
              child: Opacity(
                opacity: impact.toDouble(),
                child: Transform.scale(
                  scale: 0.7 + impact * 0.55,
                  child: _ImpactBurst(type: widget.type),
                ),
              ),
            ),
            if (impact > 0)
              Positioned(
                left: target.dx - 24,
                top: target.dy - 70 - impact * 18,
                child: Text(
                  _sfxFor(widget.type),
                  style: TextStyle(
                    color: _colorFor(widget.type),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    shadows: const [
                      Shadow(color: Colors.black, blurRadius: 8),
                    ],
                  ),
                )
                    .animate(key: ValueKey(widget.type))
                    .fadeIn(duration: 80.ms)
                    .shake(duration: 220.ms, hz: 8),
              ),
          ],
        );
      },
    );
  }

  Offset _projectilePosition(double progress) {
    if (widget.type == CompanionPropType.glove) {
      return widget.target;
    }
    final linear = Offset.lerp(widget.start, widget.target, progress)!;
    final arc = math.sin(progress * math.pi) * 92;
    return linear.translate(0, -arc);
  }
}

class _ImpactBurst extends StatelessWidget {
  const _ImpactBurst({required this.type});

  final CompanionPropType type;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 92,
      child: CustomPaint(painter: _ImpactPainter(type: type)),
    );
  }
}

class _ImpactPainter extends CustomPainter {
  const _ImpactPainter({required this.type});

  final CompanionPropType type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final color = _colorFor(type);
    final paint = Paint()..color = color.withValues(alpha: 0.32);
    canvas.drawCircle(center, 32, paint);

    final rayPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = type == CompanionPropType.glove ? 4 : 2
      ..color = color;
    for (var index = 0; index < 12; index++) {
      final angle = math.pi * 2 * index / 12;
      final start = center + Offset(math.cos(angle), math.sin(angle)) * 22;
      final end = center + Offset(math.cos(angle), math.sin(angle)) * 42;
      canvas.drawLine(start, end, rayPaint);
    }

    if (type == CompanionPropType.egg) {
      final shell = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = Colors.white;
      final path = Path()
        ..moveTo(center.dx - 16, center.dy - 4)
        ..lineTo(center.dx - 4, center.dy + 6)
        ..lineTo(center.dx + 6, center.dy - 6)
        ..lineTo(center.dx + 16, center.dy + 4);
      canvas.drawPath(path, shell);
    }
  }

  @override
  bool shouldRepaint(covariant _ImpactPainter oldDelegate) {
    return oldDelegate.type != type;
  }
}

IconData _iconFor(CompanionPropType type) {
  return switch (type) {
    CompanionPropType.glove => Icons.sports_mma,
    CompanionPropType.flower => Icons.local_florist,
    CompanionPropType.egg => Icons.egg_alt,
  };
}

Color _colorFor(CompanionPropType type) {
  return switch (type) {
    CompanionPropType.glove => const Color(0xFFFF7A1A),
    CompanionPropType.flower => const Color(0xFFFF4F8B),
    CompanionPropType.egg => const Color(0xFFFFD166),
  };
}

String _sfxFor(CompanionPropType type) {
  return switch (type) {
    CompanionPropType.glove => '砰!',
    CompanionPropType.flower => '啪!',
    CompanionPropType.egg => '啪嚓!',
  };
}
