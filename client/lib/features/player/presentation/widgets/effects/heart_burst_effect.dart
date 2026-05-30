import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'particle_effect.dart';

const _burstSize = 220.0;

class HeartBurstEffect extends StatefulWidget {
  const HeartBurstEffect({
    required this.position,
    this.duration = const Duration(milliseconds: 850),
    super.key,
  });

  final Offset position;
  final Duration duration;

  @override
  State<HeartBurstEffect> createState() => _HeartBurstEffectState();
}

class _HeartBurstEffectState extends State<HeartBurstEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..forward();

  late final List<ParticleSpec> _particles = buildParticleSpecs(
    count: 14,
    color: const Color(0xFFFF4F8B),
    seed: widget.position.dx.round() + widget.position.dy.round(),
    minDistance: 42,
    maxDistance: 132,
    minSize: 5,
    maxSize: 18,
  );

  late final List<ParticleSpec> _sparkles = buildParticleSpecs(
    count: 8,
    color: const Color(0xFFFFD1E0),
    seed: widget.position.dx.round() * 3 + widget.position.dy.round(),
    minDistance: 24,
    maxDistance: 92,
    minSize: 4,
    maxSize: 10,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - _burstSize / 2,
      top: widget.position.dy - _burstSize / 2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = _controller.value;
          final delayedSparkleProgress =
              ((progress - 0.12) / 0.88).clamp(0.0, 1.0).toDouble();

          return SizedBox.square(
            dimension: _burstSize,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                ParticleBurst(
                  progress: progress,
                  particles: _particles,
                  dimension: _burstSize,
                ),
                if (delayedSparkleProgress > 0)
                  ParticleBurst(
                    progress: delayedSparkleProgress,
                    particles: _sparkles,
                    dimension: _burstSize,
                  ),
                _HeartPulse(progress: progress),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeartPulse extends StatelessWidget {
  const _HeartPulse({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0).toDouble();

    return Stack(
      alignment: Alignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.82),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(color: Color(0xFFFF5B8F), blurRadius: 28),
            ],
          ),
          child: const SizedBox.square(dimension: 70),
        )
            .animate(value: clamped, autoPlay: false)
            .scaleXY(
              begin: 0.42,
              end: 2.35,
              duration: 560.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeOut(duration: 560.ms, curve: Curves.easeOutCubic),
        const Icon(
          Icons.favorite,
          color: Color(0xFFFF3B72),
          size: 74,
          shadows: [
            Shadow(color: Colors.white, blurRadius: 20),
            Shadow(color: Color(0xFFFF84AA), blurRadius: 36),
          ],
        )
            .animate(value: clamped, autoPlay: false)
            .scaleXY(
              begin: 0.28,
              end: 1.15,
              duration: 300.ms,
              curve: Curves.elasticOut,
            )
            .shake(
              delay: 120.ms,
              duration: 260.ms,
              hz: 9,
              rotation: 0.065,
            )
            .fadeOut(delay: 620.ms, duration: 220.ms),
      ],
    );
  }
}
