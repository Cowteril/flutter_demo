import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../domain/models/effect_type.dart';

class CinematicBurstEffect extends StatefulWidget {
  const CinematicBurstEffect({
    required this.type,
    required this.position,
    this.duration = const Duration(milliseconds: 1350),
    super.key,
  });

  final EffectType type;
  final Offset position;
  final Duration duration;

  @override
  State<CinematicBurstEffect> createState() => _CinematicBurstEffectState();
}

class _CinematicBurstEffectState extends State<CinematicBurstEffect>
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
    final visual = _visualForType(widget.type);

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final rawProgress = _controller.value;
          final entrance = Curves.easeOutBack
              .transform((rawProgress / 0.32).clamp(0.0, 1.0).toDouble());
          final exit = Curves.easeInCubic.transform(
            ((rawProgress - 0.64) / 0.36).clamp(0.0, 1.0).toDouble(),
          );
          final opacity =
              (rawProgress < 0.7 ? 1 : 1 - exit).clamp(0.0, 1.0).toDouble();

          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _CinematicBurstPainter(
                  color: visual.color,
                  center: widget.position,
                  progress: rawProgress,
                ),
              ),
              Positioned(
                left: widget.position.dx - 62,
                top: widget.position.dy - 62,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: 0.52 + entrance * 0.62 - exit * 0.12,
                    child: _BurstSigil(visual: visual),
                  ).animate(value: rawProgress, autoPlay: false).shake(
                        delay: 110.ms,
                        duration: 280.ms,
                        hz: 9,
                        offset: const Offset(2.5, 0),
                        rotation: 0.035,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BurstSigil extends StatelessWidget {
  const _BurstSigil({required this.visual});

  final _BurstVisual visual;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 124,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.92),
                  visual.color.withValues(alpha: 0.78),
                  visual.color.withValues(alpha: 0.04),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: visual.color.withValues(alpha: 0.62),
                  blurRadius: 36,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const SizedBox.square(dimension: 104),
          ),
          Icon(
            visual.icon,
            color: Colors.black.withValues(alpha: 0.86),
            size: 54,
            shadows: [
              Shadow(
                color: Colors.white.withValues(alpha: 0.8),
                blurRadius: 16,
              ),
            ],
          ),
          Positioned(
            bottom: 14,
            child: Text(
              visual.label,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.82),
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CinematicBurstPainter extends CustomPainter {
  const _CinematicBurstPainter({
    required this.color,
    required this.center,
    required this.progress,
  });

  final Color color;
  final Offset center;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final eased = Curves.easeOutCubic.transform(progress);
    final lateFade =
        (1 - ((progress - 0.68) / 0.32).clamp(0.0, 1.0)).toDouble();
    final opacity = (progress < 0.12 ? progress / 0.12 : lateFade)
        .clamp(0.0, 1.0)
        .toDouble();
    final maxRadius = size.longestSide * 0.86;

    final flashPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (center.dx / size.width - 0.5) * 2,
          (center.dy / size.height - 0.5) * 2,
        ),
        radius: 0.86,
        colors: [
          Colors.white.withValues(alpha: 0.2 * opacity),
          color.withValues(alpha: 0.16 * opacity),
          Colors.transparent,
        ],
        stops: const [0, 0.42, 1],
      ).createShader(rect);
    canvas.drawRect(rect, flashPaint);

    final rayPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 28; index++) {
      final angle = index * math.pi * 2 / 28 + math.sin(index) * 0.08;
      final startRadius = 34 + eased * (42 + index % 4 * 9);
      final endRadius = startRadius + (150 + index % 5 * 22) * (1 - progress);
      final alpha = (index.isEven ? 0.34 : 0.2) * opacity;
      rayPaint
        ..strokeWidth = index.isEven ? 3.2 : 1.5
        ..color =
            (index % 3 == 0 ? Colors.white : color).withValues(alpha: alpha);
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * startRadius,
        center + Offset(math.cos(angle), math.sin(angle)) * endRadius,
        rayPaint,
      );
    }

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 4; index++) {
      final local = ((progress - index * 0.07) / (1 - index * 0.07))
          .clamp(0.0, 1.0)
          .toDouble();
      final ringProgress = Curves.easeOutCubic.transform(local);
      final radius = 28 + maxRadius * (0.2 + index * 0.08) * ringProgress;
      ringPaint
        ..strokeWidth = (12 - index * 2.2) * (1 - local) + 1.2
        ..color = Color.lerp(Colors.white, color, index / 4)!
            .withValues(alpha: opacity * (0.62 - index * 0.1));
      canvas.drawCircle(center, radius, ringPaint);

      final arcRect = Rect.fromCircle(center: center, radius: radius * 0.74);
      canvas.drawArc(
        arcRect,
        -math.pi * 0.72 + index,
        math.pi * (0.42 + index * 0.08),
        false,
        ringPaint
          ..strokeWidth = 3.8 * (1 - local) + 1
          ..color = color.withValues(alpha: opacity * 0.5),
      );
    }

    final shardPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: opacity * 0.62);
    for (var index = 0; index < 12; index++) {
      final angle = index * math.pi * 2 / 12 + progress * 0.34;
      final distance = 50 + eased * (78 + index % 4 * 18);
      final shardCenter =
          center + Offset(math.cos(angle), math.sin(angle)) * distance;
      final tangent = Offset(-math.sin(angle), math.cos(angle));
      final normal = Offset(math.cos(angle), math.sin(angle));
      final path = Path()
        ..moveTo(
          shardCenter.dx + normal.dx * 18,
          shardCenter.dy + normal.dy * 18,
        )
        ..lineTo(
          shardCenter.dx - normal.dx * 11 + tangent.dx * 5,
          shardCenter.dy - normal.dy * 11 + tangent.dy * 5,
        )
        ..lineTo(
          shardCenter.dx - normal.dx * 7 - tangent.dx * 5,
          shardCenter.dy - normal.dy * 7 - tangent.dy * 5,
        )
        ..close();
      canvas.drawPath(path, shardPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CinematicBurstPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.center != center ||
        oldDelegate.progress != progress;
  }
}

class _BurstVisual {
  const _BurstVisual({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

_BurstVisual _visualForType(EffectType type) {
  return switch (type) {
    EffectType.heart => const _BurstVisual(
        label: 'HEART',
        icon: Icons.favorite,
        color: Color(0xFFFF4F8B),
      ),
    EffectType.shockwave => const _BurstVisual(
        label: 'IMPACT',
        icon: Icons.bolt,
        color: Color(0xFFFFD166),
      ),
    EffectType.tears => const _BurstVisual(
        label: 'TEARS',
        icon: Icons.water_drop,
        color: Color(0xFF60A5FA),
      ),
    EffectType.candy => const _BurstVisual(
        label: 'SWEET',
        icon: Icons.auto_awesome,
        color: Color(0xFFF472B6),
      ),
    EffectType.flame => const _BurstVisual(
        label: 'BURN',
        icon: Icons.local_fire_department,
        color: Color(0xFFFF7A1A),
      ),
    EffectType.textFly => const _BurstVisual(
        label: 'QUOTE',
        icon: Icons.text_fields,
        color: Color(0xFF7DD3FC),
      ),
  };
}
