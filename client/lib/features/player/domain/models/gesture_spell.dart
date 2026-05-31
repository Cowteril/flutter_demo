import 'dart:ui';

enum GestureSpellType {
  lightning,
  fire,
  sword,
  snowflake,
  star,
  unknown,
}

extension GestureSpellTypeLabels on GestureSpellType {
  String get label {
    switch (this) {
      case GestureSpellType.lightning:
        return '雷击';
      case GestureSpellType.fire:
        return '火焰';
      case GestureSpellType.sword:
        return '突进';
      case GestureSpellType.snowflake:
        return '冰封';
      case GestureSpellType.star:
        return '星芒';
      case GestureSpellType.unknown:
        return '未识别';
    }
  }

  String get effectText {
    switch (this) {
      case GestureSpellType.lightning:
        return '雷击命中，剧情能量爆发';
      case GestureSpellType.fire:
        return '火焰符文点燃全场';
      case GestureSpellType.sword:
        return '突进斩触发高光反击';
      case GestureSpellType.snowflake:
        return '冰封领域展开';
      case GestureSpellType.star:
        return '星芒治愈完成';
      case GestureSpellType.unknown:
        return 'AI 没认准，进入点阵兜底';
    }
  }

  Color get color {
    switch (this) {
      case GestureSpellType.lightning:
        return const Color(0xFFFFD166);
      case GestureSpellType.fire:
        return const Color(0xFFFF4F4F);
      case GestureSpellType.sword:
        return const Color(0xFF7DD3FC);
      case GestureSpellType.snowflake:
        return const Color(0xFF67E8F9);
      case GestureSpellType.star:
        return const Color(0xFFFF8BD1);
      case GestureSpellType.unknown:
        return const Color(0xFFE5E7EB);
    }
  }
}

class GestureRecognitionResult {
  const GestureRecognitionResult({
    required this.type,
    required this.confidence,
    required this.source,
  });

  final GestureSpellType type;
  final double confidence;
  final GestureRecognitionSource source;

  bool get isAccepted =>
      type != GestureSpellType.unknown && confidence >= confidenceThreshold;

  static const confidenceThreshold = 0.64;
}

enum GestureRecognitionSource {
  heuristic,
  dotPattern,
}
