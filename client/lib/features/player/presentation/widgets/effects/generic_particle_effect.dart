import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = switch (widget.type) {
      EffectType.tears => const _ParticleConfig(
          icon: Icons.water_drop,
          color: Color(0xFF60A5FA),
          dy: 150,
        ),
      EffectType.candy => const _ParticleConfig(
          icon: Icons.circle,
          color: Color(0xFFF472B6),
          dy: 130,
        ),
      EffectType.flame => const _ParticleConfig(
          icon: Icons.local_fire_department,
          color: Color(0xFFFF7A1A),
          dy: -150,
        ),
      _ => const _ParticleConfig(
          icon: Icons.auto_awesome,
          color: Color(0xFFFFD166),
          dy: -120,
        ),
    };

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = Curves.easeOutCubic.transform(_controller.value);
          final opacity = (1 - _controller.value).clamp(0, 1).toDouble();

          return Opacity(
            opacity: opacity,
            child: Stack(
              children: [
                for (var index = 0; index < 12; index++)
                  Positioned(
                    left: widget.position.dx +
                        (index - 6) * 18 +
                        (index.isEven ? 12 : -12) * progress,
                    top: widget.position.dy +
                        config.dy * progress +
                        (index % 4) * 18,
                    child: Transform.rotate(
                      angle: progress * (index.isEven ? 1.2 : -1.2),
                      child: Icon(
                        config.icon,
                        color: widget.type == EffectType.candy
                            ? _candyColor(index)
                            : config.color,
                        size: 16 + index % 3 * 6,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ParticleConfig {
  const _ParticleConfig({
    required this.icon,
    required this.color,
    required this.dy,
  });

  final IconData icon;
  final Color color;
  final double dy;
}

Color _candyColor(int index) {
  const colors = [
    Color(0xFFF472B6),
    Color(0xFFFACC15),
    Color(0xFF34D399),
    Color(0xFF60A5FA),
  ];
  return colors[index % colors.length];
}
