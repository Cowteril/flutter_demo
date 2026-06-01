import 'package:flutter/widgets.dart';

class AiCompanionScript {
  const AiCompanionScript({
    required this.dramaId,
    required this.characterKey,
    required this.characterName,
    required this.rolePositioning,
    required this.persona,
    required this.previousEpisodes,
    required this.highlightScenes,
    required this.branchHooks,
  });

  final String dramaId;
  final String characterKey;
  final String characterName;
  final String rolePositioning;
  final String persona;
  final List<String> previousEpisodes;
  final List<AiCompanionHighlightScene> highlightScenes;
  final List<String> branchHooks;
}

class AiCompanionHighlightScene {
  const AiCompanionHighlightScene({
    required this.highlightId,
    required this.beforeStory,
    required this.line,
    required this.target,
  });

  final String highlightId;
  final String beforeStory;
  final String line;
  final CompanionPropTarget target;
}

class AiCompanionStoryContext {
  const AiCompanionStoryContext({
    required this.characterName,
    required this.rolePositioning,
    required this.persona,
    required this.previousEpisodes,
    required this.currentEpisodeBeforeHighlight,
    required this.line,
  });

  final String characterName;
  final String rolePositioning;
  final String persona;
  final List<String> previousEpisodes;
  final List<String> currentEpisodeBeforeHighlight;
  final String line;
}

class CompanionPropTarget {
  const CompanionPropTarget({
    required this.normalizedPosition,
    required this.targetCharacterName,
  });

  final Offset normalizedPosition;
  final String targetCharacterName;
}

enum CompanionPose {
  idle,
  chat,
  happy,
  surprised,
  throwItem,
  punch,
}

enum CompanionPropType {
  glove,
  flower,
  egg,
}
