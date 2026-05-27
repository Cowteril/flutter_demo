enum HighlightKind {
  reaction,
  branch,
  extension,
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
  });

  final String id;
  final String label;
  final String effectText;
}
