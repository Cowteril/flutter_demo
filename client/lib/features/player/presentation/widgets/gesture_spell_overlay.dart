import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/gesture_classifier.dart';
import '../../domain/models/gesture_spell.dart';

class GestureSpellOverlay extends StatefulWidget {
  const GestureSpellOverlay({
    required this.onClose,
    required this.onRecognized,
    required this.classifier,
    super.key,
  });

  final VoidCallback onClose;
  final ValueChanged<GestureRecognitionResult> onRecognized;
  final GestureClassifier classifier;

  @override
  State<GestureSpellOverlay> createState() => _GestureSpellOverlayState();
}

class _GestureSpellOverlayState extends State<GestureSpellOverlay> {
  final _points = <Offset>[];
  final _dotSequence = <int>[];
  final _dotClassifier = const DotPatternGestureClassifier();
  GestureRecognitionResult? _lastResult;
  var _showDotFallback = false;
  var _isClassifying = false;

  void _startStroke(DragStartDetails details) {
    setState(() {
      _points
        ..clear()
        ..add(details.localPosition);
      _lastResult = null;
      _showDotFallback = false;
    });
  }

  void _appendStroke(DragUpdateDetails details) {
    setState(() => _points.add(details.localPosition));
  }

  Future<void> _finishStroke(DragEndDetails details) async {
    setState(() => _isClassifying = true);
    final result = await widget.classifier.classify(_points);
    if (!mounted) {
      return;
    }
    setState(() {
      _lastResult = result;
      _showDotFallback = !result.isAccepted;
      _isClassifying = false;
    });
    if (result.isAccepted) {
      widget.onRecognized(result);
    }
  }

  void _clear() {
    setState(() {
      _points.clear();
      _dotSequence.clear();
      _lastResult = null;
      _showDotFallback = false;
      _isClassifying = false;
    });
  }

  void _appendDot(int dot) {
    setState(() {
      if (_dotSequence.isEmpty || _dotSequence.last != dot) {
        _dotSequence.add(dot);
      }
    });
  }

  void _submitDots() {
    final result = _dotClassifier.classify(_dotSequence);
    setState(() => _lastResult = result);
    if (result.isAccepted) {
      widget.onRecognized(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _lastResult;
    final color = result?.type.color ?? const Color(0xFF7DD3FC);

    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.72),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              children: [
                _Header(onClose: widget.onClose),
                const SizedBox(height: 12),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.36),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color.withValues(alpha: 0.6),
                      ),
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: _startStroke,
                      onPanUpdate: _appendStroke,
                      onPanEnd: _finishStroke,
                      child: CustomPaint(
                        painter: _GestureCanvasPainter(
                          points: _points,
                          color: color,
                        ),
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: _points.isEmpty ? 1 : 0,
                            duration: const Duration(milliseconds: 160),
                            child: const _GestureHint(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ResultPanel(
                  result: result,
                  isClassifying: _isClassifying,
                  onClear: _clear,
                ),
                if (_showDotFallback) ...[
                  const SizedBox(height: 12),
                  _DotPatternPanel(
                    sequence: _dotSequence,
                    onDot: _appendDot,
                    onSubmit: _submitDots,
                    onClear: () => setState(_dotSequence.clear),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.auto_fix_high, color: Color(0xFFFFD166)),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'AI 施法识别',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
        IconButton(
          tooltip: '关闭',
          onPressed: onClose,
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ],
    );
  }
}

class _GestureHint extends StatelessWidget {
  const _GestureHint();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.gesture,
          color: Colors.white.withValues(alpha: 0.78),
          size: 48,
        ),
        const SizedBox(height: 10),
        const Text(
          '画闪电、火焰、剑、雪花或星星',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '抬手后立即识别，低置信度自动进入点阵兜底',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.result,
    required this.isClassifying,
    required this.onClear,
  });

  final GestureRecognitionResult? result;
  final bool isClassifying;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final result = this.result;
    final text = isClassifying
        ? '识别中'
        : result == null
            ? '等待绘制'
            : '${result.type.label} · ${(result.confidence * 100).round()}%';
    final source = switch (result?.source) {
      GestureRecognitionSource.tflite => 'TFLite 模型',
      GestureRecognitionSource.dotPattern => '点阵兜底',
      GestureRecognitionSource.heuristic => '启发式兜底',
      null => '',
    };

    return Row(
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                result == null ? text : '$text · $source',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filledTonal(
          tooltip: '重画',
          onPressed: onClear,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}

class _DotPatternPanel extends StatelessWidget {
  const _DotPatternPanel({
    required this.sequence,
    required this.onDot,
    required this.onSubmit,
    required this.onClear,
  });

  final List<int> sequence;
  final ValueChanged<int> onDot;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 128,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final dot = index + 1;
                  final selected = sequence.contains(dot);
                  return IconButton.filled(
                    tooltip: 'dot $dot',
                    style: IconButton.styleFrom(
                      backgroundColor: selected
                          ? const Color(0xFFFFD166)
                          : Colors.white.withValues(alpha: 0.16),
                      foregroundColor: selected ? Colors.black : Colors.white,
                    ),
                    onPressed: () => onDot(dot),
                    icon: Text('$dot'),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '点阵兜底',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sequence.isEmpty ? '示例：1-5-9 是突进' : sequence.join('-'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: sequence.isEmpty ? null : onSubmit,
                        child: const Text('确认'),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: '清空点阵',
                        onPressed: onClear,
                        icon: const Icon(Icons.backspace_outlined),
                      ),
                    ],
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

class _GestureCanvasPainter extends CustomPainter {
  const _GestureCanvasPainter({required this.points, required this.color});

  final List<Offset> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      final y = size.height * i / 4;
      canvas
        ..drawLine(Offset(x, 0), Offset(x, size.height), gridPaint)
        ..drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (points.length < 2) {
      return;
    }

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white, color],
      ).createShader(Offset.zero & size)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final control = Offset(
        (previous.dx + current.dx) / 2,
        (previous.dy + current.dy) / 2,
      );
      path.quadraticBezierTo(previous.dx, previous.dy, control.dx, control.dy);
    }

    canvas
      ..drawPath(path, glowPaint)
      ..drawPath(path, linePaint);

    final headPaint = Paint()..color = color;
    final head = points.last;
    canvas.drawCircle(head, 8 + math.sin(points.length * 0.7) * 2, headPaint);
  }

  @override
  bool shouldRepaint(covariant _GestureCanvasPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}
