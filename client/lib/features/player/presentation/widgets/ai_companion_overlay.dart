import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../companion/domain/ai_companion_models.dart';

class AiCompanionOverlay extends StatelessWidget {
  const AiCompanionOverlay({
    required this.position,
    required this.screenSize,
    required this.characterName,
    required this.pose,
    required this.onPositionChanged,
    required this.onTap,
    this.message,
    super.key,
  });

  static const petSize = Size(78, 86);
  static const toolbarReserveWidth = 124.0;
  static const bottomReserveHeight = 184.0;

  final Offset position;
  final Size screenSize;
  final String characterName;
  final CompanionPose pose;
  final ValueChanged<Offset> onPositionChanged;
  final VoidCallback onTap;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onPanUpdate: (details) {
          onPositionChanged(_clampPosition(position + details.delta));
        },
        child: SizedBox(
          width: petSize.width,
          height: petSize.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (message != null)
                Positioned(
                  right: 0,
                  bottom: petSize.height + 6,
                  width: 182,
                  child: _CompanionBubble(
                    key: ValueKey(message),
                    text: message!,
                  )
                      .animate()
                      .fadeIn(duration: 160.ms)
                      .slideY(begin: 0.12, end: 0),
                ),
              Positioned.fill(
                child: _CompanionAvatar(
                  pose: pose,
                  characterName: characterName,
                )
                    .animate(key: ValueKey(pose))
                    .scaleXY(
                      begin: pose == CompanionPose.surprised ? 1.08 : 0.98,
                      end: 1,
                      duration: 220.ms,
                      curve: Curves.easeOutBack,
                    )
                    .shake(
                      duration: pose == CompanionPose.punch ? 260.ms : 1.ms,
                      hz: 7,
                      offset: const Offset(2, 0),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Offset _clampPosition(Offset next) {
    final maxX = (screenSize.width - petSize.width - toolbarReserveWidth - 8)
        .clamp(12.0, screenSize.width);
    final maxY = (screenSize.height - petSize.height - bottomReserveHeight)
        .clamp(12.0, screenSize.height);
    return Offset(
      next.dx.clamp(12.0, maxX).toDouble(),
      next.dy.clamp(12.0, maxY).toDouble(),
    );
  }
}

class _CompanionBubble extends StatelessWidget {
  const _CompanionBubble({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF07111F).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF7DD3FC)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7DD3FC).withValues(alpha: 0.32),
              blurRadius: 18,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              height: 1.25,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanionAvatar extends StatelessWidget {
  const _CompanionAvatar({
    required this.pose,
    required this.characterName,
  });

  final CompanionPose pose;
  final String characterName;

  @override
  Widget build(BuildContext context) {
    final accent = switch (pose) {
      CompanionPose.happy => const Color(0xFFFFD166),
      CompanionPose.surprised => const Color(0xFFFF7A1A),
      CompanionPose.throwItem => const Color(0xFF7DD3FC),
      CompanionPose.punch => const Color(0xFFFF4F8B),
      CompanionPose.chat => const Color(0xFFB56CFF),
      CompanionPose.idle => const Color(0xFF7DD3FC),
    };

    return CustomPaint(
      painter: _CompanionPainter(
        accent: accent,
        pose: pose,
      ),
      child: Align(
        alignment: const Alignment(0, 0.92),
        child: Text(
          characterName.characters.first,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            shadows: [Shadow(color: Colors.black, blurRadius: 8)],
          ),
        ),
      ),
    );
  }
}

class _CompanionPainter extends CustomPainter {
  const _CompanionPainter({
    required this.accent,
    required this.pose,
  });

  final Color accent;
  final CompanionPose pose;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height - 8),
        width: size.width * 0.72,
        height: 12,
      ),
      shadow,
    );

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accent, const Color(0xFFFF4F8B)],
      ).createShader(Offset.zero & size);
    final facePaint = Paint()..color = const Color(0xFFFFE2C6);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.66),
          width: 46,
          height: 40,
        ),
        const Radius.circular(18),
      ),
      bodyPaint,
    );

    final armLift =
        pose == CompanionPose.throwItem || pose == CompanionPose.punch;
    canvas.drawLine(
      Offset(size.width * 0.26, size.height * 0.6),
      Offset(
          size.width * 0.12, armLift ? size.height * 0.42 : size.height * 0.68),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.74, size.height * 0.6),
      Offset(
          size.width * 0.9, armLift ? size.height * 0.44 : size.height * 0.68),
      stroke,
    );

    canvas.drawCircle(center, 28, facePaint);
    canvas.drawArc(
      Rect.fromCircle(center: center.translate(0, -5), radius: 30),
      3.2,
      3.0,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF1F2937),
    );

    final eyePaint = Paint()..color = const Color(0xFF111827);
    final leftEye = center.translate(-9, -2);
    final rightEye = center.translate(9, -2);
    if (pose == CompanionPose.happy) {
      canvas.drawArc(
        Rect.fromCircle(center: leftEye, radius: 4),
        0,
        3.14,
        false,
        stroke..strokeWidth = 1.8,
      );
      canvas.drawArc(
        Rect.fromCircle(center: rightEye, radius: 4),
        0,
        3.14,
        false,
        stroke..strokeWidth = 1.8,
      );
    } else {
      canvas.drawCircle(leftEye, 3.2, eyePaint);
      canvas.drawCircle(rightEye, 3.2, eyePaint);
    }

    final mouthPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFB45309);
    if (pose == CompanionPose.surprised) {
      canvas.drawCircle(center.translate(0, 10), 4, mouthPaint);
    } else {
      canvas.drawArc(
        Rect.fromCenter(center: center.translate(0, 8), width: 16, height: 10),
        0.2,
        2.7,
        false,
        mouthPaint,
      );
    }

    if (pose == CompanionPose.punch) {
      canvas.drawCircle(
        Offset(size.width * 0.93, size.height * 0.42),
        9,
        Paint()..color = const Color(0xFFFFD166),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CompanionPainter oldDelegate) {
    return oldDelegate.accent != accent || oldDelegate.pose != pose;
  }
}
