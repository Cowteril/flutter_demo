import 'package:flutter/material.dart';

class HeartParticleEffect extends StatefulWidget {
  const HeartParticleEffect({
    required this.position,
    this.duration = const Duration(milliseconds: 1200),
    super.key,
  });

  final Offset position;
  final Duration duration;

  @override
  State<HeartParticleEffect> createState() => _HeartParticleEffectState();
}

class _HeartParticleEffectState extends State<HeartParticleEffect>
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
          final progress = Curves.easeOut.transform(_controller.value);
          final opacity = (1 - progress).clamp(0, 1).toDouble();

          return Opacity(
            opacity: opacity,
            child: Stack(
              children: [
                for (var index = 0; index < 7; index++)
                  Positioned(
                    left: widget.position.dx - 18 + index * 8,
                    top:
                        widget.position.dy - 16 - progress * (120 + index * 10),
                    child: Transform.rotate(
                      angle: (index - 3) * 0.12,
                      child: Icon(
                        Icons.favorite,
                        color: Color.lerp(
                          const Color(0xFFFF3B72),
                          const Color(0xFFFFB3C7),
                          index / 6,
                        ),
                        size: 24 + index % 3 * 8,
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
