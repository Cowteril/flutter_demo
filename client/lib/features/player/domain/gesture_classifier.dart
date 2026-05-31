import 'dart:math' as math;
import 'dart:ui';

import 'models/gesture_spell.dart';

abstract class GestureClassifier {
  GestureRecognitionResult classify(List<Offset> points);
}

class HeuristicGestureClassifier implements GestureClassifier {
  const HeuristicGestureClassifier();

  @override
  GestureRecognitionResult classify(List<Offset> points) {
    final normalized = _normalized(points);
    if (normalized.length < 8) {
      return const GestureRecognitionResult(
        type: GestureSpellType.unknown,
        confidence: 0.18,
        source: GestureRecognitionSource.heuristic,
      );
    }

    final features = _GestureFeatures.from(normalized);
    final scores = <GestureSpellType, double>{
      GestureSpellType.lightning: _lightningScore(features),
      GestureSpellType.fire: _fireScore(features),
      GestureSpellType.sword: _swordScore(features),
      GestureSpellType.snowflake: _snowflakeScore(features),
      GestureSpellType.star: _starScore(features),
    };

    final best = scores.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    final type = best.value >= GestureRecognitionResult.confidenceThreshold
        ? best.key
        : GestureSpellType.unknown;

    return GestureRecognitionResult(
      type: type,
      confidence: best.value.clamp(0.0, 0.98).toDouble(),
      source: GestureRecognitionSource.heuristic,
    );
  }

  double _lightningScore(_GestureFeatures f) {
    return _weighted([
      _near(f.turnCount / 4, 0.9),
      _near(f.xDirectionChanges / 3, 0.9),
      1 - f.closure,
      f.verticalSpan,
      f.sharpTurnRatio,
    ]);
  }

  double _fireScore(_GestureFeatures f) {
    return _weighted([
      f.curveRatio,
      f.verticalSpan,
      _near(f.turnCount / 7, 0.8),
      _near(f.xDirectionChanges / 5, 0.8),
      1 - f.linearity,
    ]);
  }

  double _swordScore(_GestureFeatures f) {
    return _weighted([
      f.linearity,
      1 - f.curveRatio,
      1 - (f.turnCount / 8).clamp(0.0, 1.0),
      math.max(f.verticalSpan, f.horizontalSpan),
      1 - f.closure,
    ]);
  }

  double _snowflakeScore(_GestureFeatures f) {
    return _weighted([
      _near(f.turnCount / 10, 0.8),
      _near(f.xDirectionChanges / 7, 0.8),
      _near(f.yDirectionChanges / 7, 0.8),
      f.crossAxisBalance,
      f.sharpTurnRatio,
    ]);
  }

  double _starScore(_GestureFeatures f) {
    return _weighted([
      f.closure,
      f.sharpTurnRatio,
      _near(f.turnCount / 5, 0.95),
      f.crossAxisBalance,
      1 - f.linearity,
    ]);
  }
}

class DotPatternGestureClassifier {
  const DotPatternGestureClassifier();

  GestureRecognitionResult classify(List<int> sequence) {
    final normalized = _dedupe(sequence);
    final type = switch (normalized.join('-')) {
      '1-5-3-7-9' => GestureSpellType.lightning,
      '2-5-8-7-4-1' => GestureSpellType.fire,
      '1-5-9' => GestureSpellType.sword,
      '2-5-8-4-6' => GestureSpellType.snowflake,
      '1-6-7-2-9' => GestureSpellType.star,
      _ => GestureSpellType.unknown,
    };

    return GestureRecognitionResult(
      type: type,
      confidence: type == GestureSpellType.unknown ? 0.0 : 1.0,
      source: GestureRecognitionSource.dotPattern,
    );
  }
}

List<int> _dedupe(List<int> sequence) {
  final result = <int>[];
  for (final dot in sequence) {
    if (result.isEmpty || result.last != dot) {
      result.add(dot);
    }
  }
  return result;
}

List<Offset> _normalized(List<Offset> points) {
  if (points.length < 2) {
    return points;
  }
  final minX = points.map((p) => p.dx).reduce(math.min);
  final maxX = points.map((p) => p.dx).reduce(math.max);
  final minY = points.map((p) => p.dy).reduce(math.min);
  final maxY = points.map((p) => p.dy).reduce(math.max);
  final scale = math.max(maxX - minX, maxY - minY);
  if (scale <= 0) {
    return points;
  }
  return [
    for (final p in points)
      Offset((p.dx - minX) / scale, (p.dy - minY) / scale),
  ];
}

double _weighted(List<double> values) =>
    values.reduce((a, b) => a + b) / values.length;

double _near(double value, double target) =>
    (1 - (value - target).abs()).clamp(0.0, 1.0).toDouble();

class _GestureFeatures {
  const _GestureFeatures({
    required this.turnCount,
    required this.xDirectionChanges,
    required this.yDirectionChanges,
    required this.closure,
    required this.curveRatio,
    required this.linearity,
    required this.verticalSpan,
    required this.horizontalSpan,
    required this.crossAxisBalance,
    required this.sharpTurnRatio,
  });

  final int turnCount;
  final int xDirectionChanges;
  final int yDirectionChanges;
  final double closure;
  final double curveRatio;
  final double linearity;
  final double verticalSpan;
  final double horizontalSpan;
  final double crossAxisBalance;
  final double sharpTurnRatio;

  static _GestureFeatures from(List<Offset> points) {
    var length = 0.0;
    var turnCount = 0;
    var sharpTurns = 0;
    var xChanges = 0;
    var yChanges = 0;
    var previousAngle = 0.0;
    var previousXSign = 0;
    var previousYSign = 0;
    var hasAngle = false;

    for (var i = 1; i < points.length; i++) {
      final delta = points[i] - points[i - 1];
      final segmentLength = delta.distance;
      if (segmentLength < 0.012) {
        continue;
      }
      length += segmentLength;

      final xSign = delta.dx.sign.toInt();
      final ySign = delta.dy.sign.toInt();
      if (previousXSign != 0 && xSign != 0 && previousXSign != xSign) {
        xChanges++;
      }
      if (previousYSign != 0 && ySign != 0 && previousYSign != ySign) {
        yChanges++;
      }
      if (xSign != 0) {
        previousXSign = xSign;
      }
      if (ySign != 0) {
        previousYSign = ySign;
      }

      final angle = math.atan2(delta.dy, delta.dx);
      if (hasAngle) {
        final diff = _angleDiff(previousAngle, angle).abs();
        if (diff > 0.72) {
          turnCount++;
        }
        if (diff > 1.08) {
          sharpTurns++;
        }
      }
      previousAngle = angle;
      hasAngle = true;
    }

    final start = points.first;
    final end = points.last;
    final directDistance = (end - start).distance;
    final closure = (1 - directDistance / math.max(length, 0.01))
        .clamp(0.0, 1.0)
        .toDouble();
    final linearity =
        (directDistance / math.max(length, 0.01)).clamp(0.0, 1.0).toDouble();
    final xs = points.map((p) => p.dx);
    final ys = points.map((p) => p.dy);
    final width = xs.reduce(math.max) - xs.reduce(math.min);
    final height = ys.reduce(math.max) - ys.reduce(math.min);
    final maxSpan = math.max(width, height).clamp(0.01, double.infinity);

    return _GestureFeatures(
      turnCount: turnCount,
      xDirectionChanges: xChanges,
      yDirectionChanges: yChanges,
      closure: closure,
      curveRatio: (length / math.max(directDistance, 0.01) / 5)
          .clamp(0.0, 1.0)
          .toDouble(),
      linearity: linearity,
      verticalSpan: (height / maxSpan).clamp(0.0, 1.0).toDouble(),
      horizontalSpan: (width / maxSpan).clamp(0.0, 1.0).toDouble(),
      crossAxisBalance:
          (math.min(width, height) / maxSpan).clamp(0.0, 1.0).toDouble(),
      sharpTurnRatio:
          (sharpTurns / math.max(turnCount, 1)).clamp(0.0, 1.0).toDouble(),
    );
  }
}

double _angleDiff(double a, double b) {
  var diff = b - a;
  while (diff > math.pi) {
    diff -= math.pi * 2;
  }
  while (diff < -math.pi) {
    diff += math.pi * 2;
  }
  return diff;
}
