import '../../../player/domain/models/effect_type.dart';

enum HighlightKind {
  reaction,
  branch,
  extension,
  prediction,
}

class HighlightPoint {
  const HighlightPoint({
    required this.id,
    required this.at,
    required this.title,
    required this.description,
    required this.kind,
    required this.options,
  });

  final String id;
  final Duration at;
  final String title;
  final String description;
  final HighlightKind kind;
  final List<InteractionOption> options;
}

class InteractionOption {
  const InteractionOption({
    required this.id,
    required this.label,
    required this.effectText,
    required this.effectType,
  });

  final String id;
  final String label;
  final String effectText;
  final EffectType effectType;
}
