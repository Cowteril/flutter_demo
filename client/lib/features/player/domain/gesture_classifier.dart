import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'models/gesture_spell.dart';

abstract class GestureClassifier {
  Future<void> warmUp() async {}

  Future<GestureRecognitionResult> classify(List<Offset> points);

  void dispose() {}
}

class HeuristicGestureClassifier implements GestureClassifier {
  const HeuristicGestureClassifier();

  @override
  Future<void> warmUp() async {}

  @override
  Future<GestureRecognitionResult> classify(List<Offset> points) async {
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

  @override
  void dispose() {}

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

class TfliteGestureClassifier implements GestureClassifier {
  TfliteGestureClassifier({
    this.modelAsset = 'assets/models/gesture_classifier.tflite',
    this.labelsAsset = 'assets/models/gesture_labels.json',
    this.fallback = const HeuristicGestureClassifier(),
  });

  final String modelAsset;
  final String labelsAsset;
  final GestureClassifier fallback;

  Interpreter? _interpreter;
  Future<void>? _initialization;
  List<GestureSpellType>? _labels;
  Object? _lastError;

  bool get isReady => _interpreter != null && _labels != null;

  Object? get lastError => _lastError;

  @override
  Future<void> warmUp() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    try {
      final labelsJson = await rootBundle.loadString(labelsAsset);
      final decoded = jsonDecode(labelsJson) as Map<String, dynamic>;
      final labels = List<GestureSpellType>.generate(
        decoded.length,
        (index) => _spellTypeFromLabel(decoded['$index'] as String?),
        growable: false,
      );
      final interpreter = await Interpreter.fromAsset(modelAsset);
      _validateContract(interpreter, labels);
      _labels = labels;
      _interpreter = interpreter;
    } catch (error, stackTrace) {
      _lastError = error;
      debugPrint('TFLite gesture classifier unavailable: $error\n$stackTrace');
    }
  }

  @override
  Future<GestureRecognitionResult> classify(List<Offset> points) async {
    await warmUp();

    final interpreter = _interpreter;
    final labels = _labels;
    if (interpreter == null || labels == null) {
      return fallback.classify(points);
    }

    try {
      final inputTensor = interpreter.getInputTensor(0);
      final outputTensor = interpreter.getOutputTensor(0);
      final input = _rasterizeGesture(
        points,
        size: inputTensor.shape[1],
        scale: inputTensor.params.scale,
        zeroPoint: inputTensor.params.zeroPoint,
      );
      final output = _outputBuffer(outputTensor);
      interpreter.run(input, output);
      return _resultFromOutput(output, outputTensor, labels);
    } catch (error, stackTrace) {
      _lastError = error;
      debugPrint('TFLite gesture inference failed: $error\n$stackTrace');
      return fallback.classify(points);
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    fallback.dispose();
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

void _validateContract(
  Interpreter interpreter,
  List<GestureSpellType> labels,
) {
  final input = interpreter.getInputTensor(0);
  final output = interpreter.getOutputTensor(0);
  if (!_sameShape(input.shape, const [1, 64, 64, 1])) {
    throw StateError('Unexpected gesture model input shape: ${input.shape}');
  }
  if (!_sameShape(output.shape, [1, labels.length])) {
    throw StateError('Unexpected gesture model output shape: ${output.shape}');
  }
  if (input.type != TensorType.int8) {
    throw StateError('Expected int8 model input, got ${input.type}');
  }
  if (output.type != TensorType.int8 && output.type != TensorType.float32) {
    throw StateError('Unsupported model output type: ${output.type}');
  }
}

bool _sameShape(List<int> actual, List<int> expected) {
  if (actual.length != expected.length) {
    return false;
  }
  for (var i = 0; i < actual.length; i++) {
    if (actual[i] != expected[i]) {
      return false;
    }
  }
  return true;
}

List<List<List<List<int>>>> _rasterizeGesture(
  List<Offset> points, {
  required int size,
  required double scale,
  required int zeroPoint,
}) {
  final pixels = List.generate(
    size,
    (_) => List<double>.filled(size, 0),
    growable: false,
  );
  if (points.length >= 2) {
    final normalized = _normalized(points);
    for (var i = 1; i < normalized.length; i++) {
      _drawSegment(
        pixels,
        normalized[i - 1],
        normalized[i],
        size: size,
      );
    }
  }

  final safeScale = scale == 0 ? 1 / 255 : scale;
  return [
    [
      for (final row in pixels)
        [
          for (final pixel in row)
            [
              (pixel / safeScale + zeroPoint).round().clamp(-128, 127).toInt(),
            ],
        ],
    ],
  ];
}

void _drawSegment(
  List<List<double>> pixels,
  Offset start,
  Offset end, {
  required int size,
}) {
  const padding = 0.1;
  final drawableSize = size * (1 - padding * 2);
  final x1 = padding * size + start.dx * drawableSize;
  final y1 = padding * size + start.dy * drawableSize;
  final x2 = padding * size + end.dx * drawableSize;
  final y2 = padding * size + end.dy * drawableSize;
  final steps = math.max((x2 - x1).abs(), (y2 - y1).abs()).ceil();
  for (var step = 0; step <= steps; step++) {
    final t = steps == 0 ? 0.0 : step / steps;
    final x = (x1 + (x2 - x1) * t).round();
    final y = (y1 + (y2 - y1) * t).round();
    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        final px = x + dx;
        final py = y + dy;
        if (px >= 0 && px < size && py >= 0 && py < size) {
          pixels[py][px] = 1;
        }
      }
    }
  }
}

Object _outputBuffer(Tensor tensor) {
  final length = tensor.shape.last;
  if (tensor.type == TensorType.float32) {
    return [List<double>.filled(length, 0)];
  }
  return [List<int>.filled(length, 0)];
}

GestureRecognitionResult _resultFromOutput(
  Object output,
  Tensor tensor,
  List<GestureSpellType> labels,
) {
  final values = (output as List).first as List;
  final probabilities = <double>[
    for (final value in values)
      tensor.type == TensorType.float32
          ? (value as num).toDouble()
          : ((value as num).toDouble() - tensor.params.zeroPoint) *
              tensor.params.scale,
  ];
  var bestIndex = 0;
  for (var i = 1; i < probabilities.length; i++) {
    if (probabilities[i] > probabilities[bestIndex]) {
      bestIndex = i;
    }
  }
  final confidence = probabilities[bestIndex].clamp(0.0, 1.0).toDouble();
  final type = confidence >= GestureRecognitionResult.confidenceThreshold
      ? labels[bestIndex]
      : GestureSpellType.unknown;
  return GestureRecognitionResult(
    type: type,
    confidence: confidence,
    source: GestureRecognitionSource.tflite,
  );
}

GestureSpellType _spellTypeFromLabel(String? label) {
  return switch (label) {
    'lightning' => GestureSpellType.lightning,
    'fire' => GestureSpellType.fire,
    'sword' => GestureSpellType.sword,
    'snowflake' => GestureSpellType.snowflake,
    'star' => GestureSpellType.star,
    _ => throw StateError('Unknown gesture model label: $label'),
  };
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
