import 'package:flutter/material.dart';

import '../../../companion/domain/ai_companion_models.dart';

class PropThrowPanel extends StatelessWidget {
  const PropThrowPanel({
    required this.highlightTitle,
    required this.onSelect,
    super.key,
  });

  final String highlightTitle;
  final ValueChanged<CompanionPropType> onSelect;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final minTop = padding.top + 96;
    final maxTop = size.height - padding.bottom - 250;
    final top = (size.height * 0.36)
        .clamp(minTop, maxTop < minTop ? minTop : maxTop)
        .toDouble();

    return Positioned(
      top: top,
      right: 74,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF07111F).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.42),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                message: '高光点：$highlightTitle',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.back_hand_outlined,
                      color: Color(0xFFFFD166),
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 104),
                      child: Text(
                        '扔道具',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final type in CompanionPropType.values) ...[
                    _PropButton(type: type, onSelect: onSelect),
                    if (type != CompanionPropType.values.last)
                      const SizedBox(width: 6),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PropButton extends StatelessWidget {
  const _PropButton({required this.type, required this.onSelect});

  final CompanionPropType type;
  final ValueChanged<CompanionPropType> onSelect;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _labelFor(type),
      child: InkResponse(
        onTap: () => onSelect(type),
        radius: 24,
        child: SizedBox.square(
          dimension: 38,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _colorFor(type).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _colorFor(type).withValues(alpha: 0.5)),
            ),
            child: Icon(_iconFor(type), color: _colorFor(type), size: 22),
          ),
        ),
      ),
    );
  }
}

IconData _iconFor(CompanionPropType type) {
  return switch (type) {
    CompanionPropType.glove => Icons.sports_mma,
    CompanionPropType.flower => Icons.local_florist,
    CompanionPropType.egg => Icons.egg_alt,
  };
}

Color _colorFor(CompanionPropType type) {
  return switch (type) {
    CompanionPropType.glove => const Color(0xFFFF7A1A),
    CompanionPropType.flower => const Color(0xFFFF4F8B),
    CompanionPropType.egg => const Color(0xFFFFD166),
  };
}

String _labelFor(CompanionPropType type) {
  return switch (type) {
    CompanionPropType.glove => '拳套',
    CompanionPropType.flower => '鲜花',
    CompanionPropType.egg => '鸡蛋',
  };
}
