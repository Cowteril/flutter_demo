import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../drama/domain/models/highlight_point.dart';
import '../../domain/models/effect_type.dart';

class InteractionOverlay extends StatefulWidget {
  const InteractionOverlay({
    required this.highlight,
    required this.onDismiss,
    required this.onSelect,
    this.disabledReason,
    super.key,
  });

  final HighlightPoint highlight;
  final VoidCallback onDismiss;
  final ValueChanged<InteractionOption> onSelect;
  final String? disabledReason;

  @override
  State<InteractionOverlay> createState() => _InteractionOverlayState();
}

class _InteractionOverlayState extends State<InteractionOverlay> {
  @override
  Widget build(BuildContext context) {
    final visual = _visualForKind(widget.highlight.kind);

    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _InteractionBackdropPainter(color: visual.color),
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 18,
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 560,
                    maxHeight: MediaQuery.sizeOf(context).height - 36,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF121826).withValues(alpha: 0.96),
                            const Color(0xFF05070D).withValues(alpha: 0.94),
                          ],
                        ),
                        border: Border.all(
                          color: visual.color.withValues(alpha: 0.58),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: visual.color.withValues(alpha: 0.42),
                            blurRadius: 34,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.58),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: _PanelEnergyPainter(
                                    color: visual.color,
                                  ),
                                ),
                              ),
                            ),
                            SingleChildScrollView(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 12, 14, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _KindBadge(visual: visual),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.highlight.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                                height: 1.12,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              widget.highlight.description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withValues(alpha: 0.76),
                                                height: 1.22,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      IconButton.filledTonal(
                                        tooltip: '关闭',
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.white
                                              .withValues(alpha: 0.12),
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: widget.onDismiss,
                                        icon: const Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (widget.disabledReason == null)
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 8,
                                      children: [
                                        for (var index = 0;
                                            index <
                                                widget.highlight.options.length;
                                            index++)
                                          _AnimatedOptionButton(
                                            option:
                                                widget.highlight.options[index],
                                            index: index,
                                            accent: visual.color,
                                            onSelect: widget.onSelect,
                                          )
                                              .animate(delay: (index * 55).ms)
                                              .fadeIn(
                                                duration: 180.ms,
                                                curve: Curves.easeOut,
                                              )
                                              .slideY(
                                                begin: 0.22,
                                                end: 0,
                                                duration: 240.ms,
                                                curve: Curves.easeOutCubic,
                                              ),
                                      ],
                                    )
                                  else
                                    _DisabledPredictionNotice(
                                      reason: widget.disabledReason!,
                                      accent: visual.color,
                                      onDismiss: widget.onDismiss,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
              .animate(key: ValueKey(widget.highlight.id))
              .fadeIn(duration: 160.ms, curve: Curves.easeOut)
              .slideY(
                begin: 0.14,
                end: 0,
                duration: 260.ms,
                curve: Curves.easeOutCubic,
              )
              .scaleXY(
                begin: 0.97,
                end: 1,
                duration: 260.ms,
                curve: Curves.easeOutBack,
              ),
        ],
      ),
    );
  }
}

class _KindBadge extends StatelessWidget {
  const _KindBadge({required this.visual});

  final _HighlightVisual visual;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: visual.color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: visual.color.withValues(alpha: 0.62)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(visual.icon, color: visual.color, size: 18),
            const SizedBox(width: 5),
            Text(
              visual.label,
              style: TextStyle(
                color: visual.color,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractionBackdropPainter extends CustomPainter {
  const _InteractionBackdropPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final vignette = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0.72),
        radius: 0.86,
        colors: [
          color.withValues(alpha: 0.22),
          Colors.black.withValues(alpha: 0.28),
          Colors.black.withValues(alpha: 0.58),
        ],
        stops: const [0, 0.42, 1],
      ).createShader(rect);

    canvas.drawRect(rect, vignette);
  }

  @override
  bool shouldRepaint(covariant _InteractionBackdropPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _PanelEnergyPainter extends CustomPainter {
  const _PanelEnergyPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.82, -0.74),
        radius: 1.05,
        colors: [
          color.withValues(alpha: 0.35),
          color.withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, glowPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: 0.18);

    for (var i = 0; i < 5; i++) {
      final dy = size.height * (0.22 + i * 0.17);
      canvas.drawLine(
        Offset(size.width * 0.58, dy),
        Offset(size.width + 18, dy - 28),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PanelEnergyPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _HighlightVisual {
  const _HighlightVisual({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

_HighlightVisual _visualForKind(HighlightKind kind) {
  return switch (kind) {
    HighlightKind.reaction => const _HighlightVisual(
        label: '情绪爆点',
        icon: Icons.local_fire_department,
        color: Color(0xFFFF7A1A),
      ),
    HighlightKind.branch => const _HighlightVisual(
        label: '剧情分支',
        icon: Icons.account_tree_outlined,
        color: Color(0xFFB56CFF),
      ),
    HighlightKind.extension => const _HighlightVisual(
        label: '高能扩展',
        icon: Icons.auto_awesome,
        color: Color(0xFFFFD166),
      ),
    HighlightKind.prediction => const _HighlightVisual(
        label: '剧情预测',
        icon: Icons.psychology_alt,
        color: Color(0xFF7DD3FC),
      ),
  };
}

IconData _iconForEffect(EffectType type) {
  return switch (type) {
    EffectType.heart => Icons.favorite,
    EffectType.shockwave => Icons.bolt,
    EffectType.tears => Icons.water_drop,
    EffectType.candy => Icons.auto_awesome,
    EffectType.flame => Icons.local_fire_department,
    EffectType.textFly => Icons.text_fields,
  };
}

Color _colorForEffect(EffectType type, Color fallback) {
  return switch (type) {
    EffectType.heart => const Color(0xFFFF4F8B),
    EffectType.shockwave => const Color(0xFFFFD166),
    EffectType.tears => const Color(0xFF60A5FA),
    EffectType.candy => const Color(0xFFF472B6),
    EffectType.flame => const Color(0xFFFF7A1A),
    EffectType.textFly => fallback,
  };
}

String _effectCaption(EffectType type) {
  return switch (type) {
    EffectType.heart => '情绪共振',
    EffectType.shockwave => '冲击爆发',
    EffectType.tears => '情绪破防',
    EffectType.candy => '甜度撒场',
    EffectType.flame => '战力燃烧',
    EffectType.textFly => '名场面弹射',
  };
}

class _DisabledPredictionNotice extends StatelessWidget {
  const _DisabledPredictionNotice({
    required this.reason,
    required this.accent,
    required this.onDismiss,
  });

  final String reason;
  final Color accent;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.42)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.lock_clock, color: accent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                reason,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onDismiss,
              child: const Text('知道了'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedOptionButton extends StatefulWidget {
  const _AnimatedOptionButton({
    required this.option,
    required this.index,
    required this.accent,
    required this.onSelect,
  });

  final InteractionOption option;
  final int index;
  final Color accent;
  final ValueChanged<InteractionOption> onSelect;

  @override
  State<_AnimatedOptionButton> createState() => _AnimatedOptionButtonState();
}

class _AnimatedOptionButtonState extends State<_AnimatedOptionButton> {
  var _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final effectColor =
        _colorForEffect(widget.option.effectType, widget.accent);
    final maxWidth = MediaQuery.sizeOf(context).width - 56;

    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1,
        duration: 90.ms,
        curve: Curves.easeOutCubic,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: maxWidth >= 420 ? 188 : maxWidth,
            maxWidth: maxWidth >= 420 ? 246 : maxWidth,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: effectColor.withValues(alpha: _isPressed ? 0.4 : 0.22),
                  blurRadius: _isPressed ? 18 : 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                backgroundColor: Color.lerp(
                  effectColor,
                  const Color(0xFF0B1020),
                  0.36,
                ),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
              ),
              onPressed: () => widget.onSelect(widget.option),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SizedBox.square(
                      dimension: 32,
                      child: Icon(
                        _iconForEffect(widget.option.effectType),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.option.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _effectCaption(widget.option.effectType),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_double_arrow_right,
                    color: Colors.white.withValues(alpha: 0.86),
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
