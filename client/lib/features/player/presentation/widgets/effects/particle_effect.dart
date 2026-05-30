import 'dart:math' as math;

import 'package:flutter/material.dart';

class ParticleSpec {
  const ParticleSpec({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
  });

  final double angle;
  final double distance;
  final double size;
  final Color color;
}

List<ParticleSpec> buildParticleSpecs({
  required int count,
  required Color color,
  int seed = 1,
  double minDistance = 36,
  double maxDistance = 118,
  double minSize = 6,
  double maxSize = 16,
}) {
  final random = math.Random(seed);

  return [
    for (var index = 0; index < count; index++)
      ParticleSpec(
        angle: random.nextDouble() * math.pi * 2,
        distance:
            minDistance + random.nextDouble() * (maxDistance - minDistance),
        size: minSize + random.nextDouble() * (maxSize - minSize),
        color: color.withValues(alpha: 0.55 + random.nextDouble() * 0.4),
      ),
  ];
}

class ParticleBurst extends StatelessWidget {
  const ParticleBurst({
    required this.progress,
    required this.particles,
    this.centerIcon,
    this.dimension = 176,
    super.key,
  });

  final double progress;
  final List<ParticleSpec> particles;
  final Widget? centerIcon;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOutCubic.transform(progress.clamp(0, 1));
    final opacity = (1 - progress).clamp(0, 1).toDouble();

    return Opacity(
      opacity: opacity,
      child: SizedBox.square(
        dimension: dimension,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            for (final particle in particles)
              Transform.translate(
                offset: Offset(
                  math.cos(particle.angle) * particle.distance * eased,
                  math.sin(particle.angle) * particle.distance * eased,
                ),
                child: Transform.scale(
                  scale: 0.7 + eased * 0.8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: particle.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: particle.color.withValues(alpha: 0.45),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: SizedBox.square(dimension: particle.size),
                  ),
                ),
              ),
            if (centerIcon != null)
              Transform.scale(
                scale: 0.8 + Curves.elasticOut.transform(progress) * 0.65,
                child: centerIcon,
              ),
          ],
        ),
      ),
    );
  }
}
