import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../drama/domain/models/highlight_point.dart';

class EmotionTemperatureOverlay extends StatelessWidget {
  const EmotionTemperatureOverlay({
    required this.position,
    required this.duration,
    required this.highlights,
    required this.userBoost,
    super.key,
  });

  final Duration position;
  final Duration duration;
  final List<HighlightPoint> highlights;
  final double userBoost;

  @override
  Widget build(BuildContext context) {
    final telemetry = EmotionTelemetry.from(
      position: position,
      duration: duration,
      highlights: highlights,
      userBoost: userBoost,
    );

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: 16,
            right: 16,
            top: 52,
            child: SafeArea(
              bottom: false,
              child: _TemperatureBar(telemetry: telemetry),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 178,
            child: SafeArea(
              top: false,
              child: _AudienceBadge(telemetry: telemetry),
            ),
          ),
          if (telemetry.isBoiling)
            Center(
              child: _BoilingBadge(temperature: telemetry.temperature),
            ),
        ],
      ),
    );
  }
}

class EmotionTelemetry {
  const EmotionTelemetry({
    required this.temperature,
    required this.audienceCount,
    required this.expressionCount,
    required this.dominantLabel,
    required this.dominantColor,
    required this.isBoiling,
  });

  final double temperature;
  final int audienceCount;
  final int expressionCount;
  final String dominantLabel;
  final Color dominantColor;
  final bool isBoiling;

  static EmotionTelemetry from({
    required Duration position,
    required Duration duration,
    required List<HighlightPoint> highlights,
    required double userBoost,
  }) {
    final seconds = position.inMilliseconds / 1000;
    final total = math.max(duration.inMilliseconds / 1000, 1);
    final wave = math.sin(seconds * 0.9) * 6 + math.cos(seconds * 0.37) * 4;
    var spike = 0.0;
    var boiling = false;

    for (final highlight in highlights) {
      final distance = (position - highlight.at).inMilliseconds.abs() / 1000;
      if (distance < 2.3) {
        spike = math.max(spike, (1 - distance / 2.3) * 38);
      }
      final after = (position - highlight.at).inMilliseconds / 1000;
      if (after >= 0 && after < 1.25) {
        boiling = true;
      }
    }

    final progress = (seconds / total).clamp(0.0, 1.0).toDouble();
    final temperature = (46 + progress * 10 + wave + spike + userBoost)
        .clamp(0.0, 100.0)
        .toDouble();
    final audience = 11800 + (temperature * 38).round();
    final expression = 260 + (temperature * 4.6).round();
    final emotion = _emotionForTemperature(temperature);

    return EmotionTelemetry(
      temperature: temperature,
      audienceCount: audience,
      expressionCount: expression,
      dominantLabel: emotion.label,
      dominantColor: emotion.color,
      isBoiling: boiling || temperature >= 86,
    );
  }
}

class _TemperatureBar extends StatelessWidget {
  const _TemperatureBar({required this.telemetry});

  final EmotionTelemetry telemetry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Color(0xFFFFD166),
                  size: 16,
                ),
                const SizedBox(width: 5),
                const Text(
                  '情绪温度',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  '${telemetry.temperature.round()}° · ${telemetry.dominantLabel}',
                  style: TextStyle(
                    color: telemetry.dominantColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      end: telemetry.temperature / 100,
                    ),
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    builder: (context, widthFactor, child) {
                      return FractionallySizedBox(
                        widthFactor: widthFactor,
                        alignment: Alignment.centerLeft,
                        child: child,
                      );
                    },
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF35E0A1),
                            Color(0xFFFFD166),
                            Color(0xFFFF4F8B),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                telemetry.dominantColor.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const SizedBox(height: 8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudienceBadge extends StatelessWidget {
  const _AudienceBadge({required this.telemetry});

  final EmotionTelemetry telemetry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          '火热 ${_compactWan(telemetry.audienceCount)} 人在看 · '
          '${telemetry.expressionCount} 人正在表达',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            shadows: [
              Shadow(color: Colors.black, blurRadius: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoilingBadge extends StatelessWidget {
  const _BoilingBadge({required this.temperature});

  final double temperature;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFF3B72).withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Color(0xFFFF3B72), blurRadius: 34),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '全场沸腾',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              '情绪温度 ${temperature.round()}°',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

({String label, Color color}) _emotionForTemperature(double temperature) {
  if (temperature >= 84) {
    return (label: '爽点爆发', color: const Color(0xFFFF4F8B));
  }
  if (temperature >= 70) {
    return (label: '反转上头', color: const Color(0xFFFFD166));
  }
  if (temperature >= 58) {
    return (label: '弹幕沸腾', color: const Color(0xFF7DD3FC));
  }
  return (label: '稳步升温', color: const Color(0xFF35E0A1));
}

String _compactWan(int value) {
  if (value >= 10000) {
    return '${(value / 10000).toStringAsFixed(1)}w';
  }
  return '$value';
}
