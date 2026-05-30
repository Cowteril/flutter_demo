import 'package:flutter/material.dart';

import 'particle_effect.dart';

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
    count: 9,
    color: const Color(0xFFFF4F8B),
    seed: widget.position.dx.round() + widget.position.dy.round(),
  );

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
          return ParticleBurst(
            progress: _controller.value,
            particles: _particles,
            centerIcon: const Icon(
              Icons.favorite,
              color: Color(0xFFFF3B72),
              size: 72,
              shadows: [
                Shadow(color: Colors.white, blurRadius: 18),
                Shadow(color: Color(0xFFFF84AA), blurRadius: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
