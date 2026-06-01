import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../domain/models/effect_type.dart';

class GenericParticleEffect extends StatefulWidget {
  const GenericParticleEffect({
    required this.type,
    required this.position,
    this.duration = const Duration(milliseconds: 1100),
    super.key,
  });

  final EffectType type;
  final Offset position;
  final Duration duration;

  @override
  State<GenericParticleEffect> createState() => _GenericParticleEffectState();
}

class _GenericParticleEffectState extends State<GenericParticleEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..forward();

  late final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(milliseconds: 850),
  );

  late final List<_FloatingParticle> _floatingParticles =
      _buildFloatingParticles(
    seed: widget.position.dx.round() * 31 +
        widget.position.dy.round() * 17 +
        widget.type.index,
  );

  bool get _usesConfetti => widget.type == EffectType.candy;

  @override
  void initState() {
    super.initState();
    if (_usesConfetti) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _confettiController.play();
        }
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = switch (widget.type) {
      EffectType.tears => const _ParticleConfig(
          icon: Icons.water_drop,
          color: Color(0xFF60A5FA),
          secondaryColor: Color(0xFFA5D8FF),
          dy: 150,
        ),
      EffectType.candy => const _ParticleConfig(
          icon: Icons.circle,
          color: Color(0xFFF472B6),
          secondaryColor: Color(0xFFFACC15),
          dy: 130,
        ),
      EffectType.flame => const _ParticleConfig(
          icon: Icons.local_fire_department,
          color: Color(0xFFFF7A1A),
          secondaryColor: Color(0xFFFFD166),
          dy: -150,
        ),
      _ => const _ParticleConfig(
          icon: Icons.auto_awesome,
          color: Color(0xFFFFD166),
          secondaryColor: Color(0xFFFFF3B0),
          dy: -120,
        ),
    };

    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (_usesConfetti)
            Positioned(
              left: widget.position.dx,
              top: widget.position.dy,
              child: SizedBox.square(
                dimension: 1,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.28,
                  numberOfParticles: 9,
                  maxBlastForce: 28,
                  minBlastForce: 9,
                  gravity: 0.18,
                  particleDrag: 0.08,
                  minimumSize: const Size(7, 7),
                  maximumSize: const Size(15, 15),
                  colors: _candyColors,
                  canvas: MediaQuery.sizeOf(context),
                  createParticlePath: _buildSparkPath,
                ),
              ),
            ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final rawProgress = _controller.value;
              final progress = Curves.easeOutCubic.transform(rawProgress);
              final opacity = (1 - rawProgress).clamp(0, 1).toDouble();

              return Opacity(
                opacity: opacity,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ParticleBloomPainter(
                          type: widget.type,
                          color: config.color,
                          secondaryColor: config.secondaryColor,
                          position: widget.position,
                          progress: rawProgress,
                        ),
                      ),
                    ),
                    for (var index = 0;
                        index < _floatingParticles.length;
                        index++)
                      _ParticleIcon(
                        particle: _floatingParticles[index],
                        config: config,
                        index: index,
                        progress: progress,
                        rawProgress: rawProgress,
                        position: widget.position,
                        type: widget.type,
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ParticleConfig {
  const _ParticleConfig({
    required this.icon,
    required this.color,
    required this.secondaryColor,
    required this.dy,
  });

  final IconData icon;
  final Color color;
  final Color secondaryColor;
  final double dy;
}

class _FloatingParticle {
  const _FloatingParticle({
    required this.angle,
    required this.distance,
    required this.delay,
    required this.size,
    required this.spin,
  });

  final double angle;
  final double distance;
  final double delay;
  final double size;
  final double spin;
}

class _ParticleIcon extends StatelessWidget {
  const _ParticleIcon({
    required this.particle,
    required this.config,
    required this.index,
    required this.progress,
    required this.rawProgress,
    required this.position,
    required this.type,
  });

  final _FloatingParticle particle;
  final _ParticleConfig config;
  final int index;
  final double progress;
  final double rawProgress;
  final Offset position;
  final EffectType type;

  @override
  Widget build(BuildContext context) {
    final localProgress = ((progress - particle.delay) / (1 - particle.delay))
        .clamp(0.0, 1.0)
        .toDouble();
    final lift = type == EffectType.tears ? config.dy : config.dy * 0.66;
    final spread = particle.distance *
        Curves.easeOutBack.transform(
          localProgress,
        );
    final color = switch (type) {
      EffectType.candy => _candyColors[index % _candyColors.length],
      EffectType.flame => Color.lerp(
          config.color,
          config.secondaryColor,
          (index % 4) / 3,
        )!,
      _ => index.isEven ? config.color : config.secondaryColor,
    };

    return Positioned(
      left: position.dx + math.cos(particle.angle) * spread - particle.size / 2,
      top: position.dy +
          math.sin(particle.angle) * spread +
          lift * localProgress -
          particle.size / 2,
      child: Transform.rotate(
        angle: particle.spin * localProgress,
        child: Icon(
          config.icon,
          color: color.withValues(alpha: 0.92),
          size: particle.size,
          shadows: [
            Shadow(
              color: color.withValues(alpha: 0.72),
              blurRadius: 12,
            ),
          ],
        ).animate(value: rawProgress, autoPlay: false).scaleXY(
              begin: 0.72,
              end: 1.12,
              duration: 260.ms,
              curve: Curves.elasticOut,
            ),
      ),
    );
  }
}

List<_FloatingParticle> _buildFloatingParticles({required int seed}) {
  final random = math.Random(seed);
  return [
    for (var index = 0; index < 28; index++)
      _FloatingParticle(
        angle: random.nextDouble() * math.pi * 2,
        distance: 48 + random.nextDouble() * 126,
        delay: random.nextDouble() * 0.22,
        size: 13 + random.nextDouble() * 20,
        spin: (random.nextBool() ? 1 : -1) * (1.4 + random.nextDouble() * 3.2),
      ),
  ];
}

const _candyColors = [
  Color(0xFFF472B6),
  Color(0xFFFACC15),
  Color(0xFF34D399),
  Color(0xFF60A5FA),
  Color(0xFFFF8A65),
];

Path _buildSparkPath(Size size) {
  final path = Path();
  final center = Offset(size.width / 2, size.height / 2);
  final outer = math.min(size.width, size.height) / 2;
  final inner = outer * 0.44;
  for (var index = 0; index < 8; index++) {
    final radius = index.isEven ? outer : inner;
    final angle = -math.pi / 2 + index * math.pi / 4;
    final point = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
    if (index == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  return path..close();
}

class _ParticleBloomPainter extends CustomPainter {
  const _ParticleBloomPainter({
    required this.type,
    required this.color,
    required this.secondaryColor,
    required this.position,
    required this.progress,
  });

  final EffectType type;
  final Color color;
  final Color secondaryColor;
  final Offset position;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final eased = Curves.easeOutCubic.transform(progress);
    final opacity = (1 - progress).clamp(0.0, 1.0).toDouble();
    final bloomRadius = 92 + size.longestSide * 0.18 * eased;

    final bloomPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (position.dx / size.width - 0.5) * 2,
          (position.dy / size.height - 0.5) * 2,
        ),
        radius: 0.48,
        colors: [
          color.withValues(alpha: 0.24 * opacity),
          secondaryColor.withValues(alpha: 0.12 * opacity),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawCircle(position, bloomRadius, bloomPaint);

    final streakPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final count = type == EffectType.flame ? 18 : 14;
    for (var index = 0; index < count; index++) {
      final angle = -math.pi / 2 +
          (index - count / 2) * math.pi / count +
          math.sin(index * 1.7) * 0.12;
      final length = (type == EffectType.tears ? 58 : 86) * (1 - progress);
      final startDistance = 28 + eased * (index % 4) * 8;
      final endDistance = startDistance + length;
      final direction = Offset(math.cos(angle), math.sin(angle));
      final tint = Color.lerp(color, secondaryColor, index / count)!;
      streakPaint
        ..strokeWidth = index.isEven ? 2.6 : 1.2
        ..color = tint.withValues(alpha: opacity * 0.28);
      canvas.drawLine(
        position + direction * startDistance,
        position + direction * endDistance,
        streakPaint,
      );
    }

    if (type == EffectType.flame) {
      final flamePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = secondaryColor.withValues(alpha: opacity * 0.44);
      for (var index = 0; index < 5; index++) {
        final path = Path()
          ..moveTo(position.dx - 42 + index * 21, position.dy + 28)
          ..cubicTo(
            position.dx - 66 + index * 18,
            position.dy - 18 - eased * 52,
            position.dx - 18 + index * 20,
            position.dy - 42 - eased * 74,
            position.dx - 34 + index * 24,
            position.dy - 94 - eased * 40,
          );
        canvas.drawPath(path, flamePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleBloomPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.color != color ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.position != position ||
        oldDelegate.progress != progress;
  }
}
