import 'package:flutter/widgets.dart';

import '../../drama/domain/models/drama.dart';
import '../../drama/domain/models/highlight_point.dart';
import '../domain/ai_companion_models.dart';

class AiCompanionScriptCatalog {
  const AiCompanionScriptCatalog();

  AiCompanionScript scriptFor(
    Drama drama, {
    String? companionCharacterId,
    String? companionCharacterName,
    String? companionSourceTitle,
  }) {
    final characterName = companionCharacterName ?? _characterNameFor(drama);
    final scenes = [
      for (final highlight in drama.highlights)
        AiCompanionHighlightScene(
          highlightId: highlight.id,
          beforeStory: _beforeStoryFor(drama, highlight),
          line: _lineFor(highlight, characterName),
          target: CompanionPropTarget(
            normalizedPosition: _targetFor(highlight),
            targetCharacterName: characterName,
          ),
        ),
    ];

    return AiCompanionScript(
      dramaId: drama.id,
      characterKey: companionCharacterId ?? '${drama.id}::lead',
      characterName: characterName,
      rolePositioning: _rolePositioningFor(
        drama,
        companionName: characterName,
        companionSourceTitle: companionSourceTitle,
      ),
      persona: '$characterName 会用第一人称陪用户追剧，语气贴近角色，不提前透露后续剧情。',
      previousEpisodes: _previousEpisodesFor(drama),
      highlightScenes: scenes,
      branchHooks: const [
        '记录用户选择，用于后续多分支追踪。',
        '保留角色口吻，可复用到同人续写。',
        '只读取当前高光点之前的剧情上下文。',
      ],
    );
  }

  AiCompanionStoryContext? contextBeforeHighlight({
    required Drama drama,
    required HighlightPoint highlight,
    String? companionCharacterId,
    String? companionCharacterName,
    String? companionSourceTitle,
  }) {
    final script = scriptFor(
      drama,
      companionCharacterId: companionCharacterId,
      companionCharacterName: companionCharacterName,
      companionSourceTitle: companionSourceTitle,
    );
    final scene = _sceneFor(script, highlight.id);
    if (scene == null) {
      return null;
    }

    final priorHighlightStories = <String>[
      for (final prior in drama.highlights)
        if (prior.at < highlight.at) '${prior.title}：${prior.description}',
    ];

    return AiCompanionStoryContext(
      characterName: script.characterName,
      rolePositioning: script.rolePositioning,
      persona: script.persona,
      previousEpisodes: script.previousEpisodes,
      currentEpisodeBeforeHighlight: [
        ...priorHighlightStories,
        scene.beforeStory,
      ],
      line: scene.line,
    );
  }

  CompanionPropTarget? targetFor({
    required Drama drama,
    required HighlightPoint highlight,
  }) {
    final script = scriptFor(drama);
    return _sceneFor(script, highlight.id)?.target;
  }

  AiCompanionHighlightScene? _sceneFor(
    AiCompanionScript script,
    String highlightId,
  ) {
    for (final scene in script.highlightScenes) {
      if (scene.highlightId == highlightId) {
        return scene;
      }
    }
    return null;
  }
}

List<String> _previousEpisodesFor(Drama drama) {
  final count = drama.episodeCount <= 1 ? 0 : drama.episodeCount.clamp(1, 4);
  return [
    for (var index = 1; index < count; index++)
      '第 $index 集前情：${drama.title} 的主线冲突继续推进，${_characterNameFor(drama)}仍处在关键选择中。',
  ];
}

String _beforeStoryFor(Drama drama, HighlightPoint highlight) {
  return '本集已播到「${highlight.title}」之前，观众只知道：${highlight.description}';
}

String _lineFor(HighlightPoint highlight, String characterName) {
  return switch (highlight.kind) {
    HighlightKind.prediction => '$characterName：这里先别急着站队，按你现在知道的线索猜一次就好。',
    HighlightKind.branch => '$characterName：这条路会改变气氛，我想听你选哪边。',
    HighlightKind.extension => '$characterName：气场上来了，接下来这一下值得盯紧。',
    HighlightKind.reaction => '$characterName：我刚刚也被戳到了，这个反应很像角色当下会说的话。',
  };
}

Offset _targetFor(HighlightPoint highlight) {
  return switch (highlight.kind) {
    HighlightKind.prediction => const Offset(0.48, 0.48),
    HighlightKind.branch => const Offset(0.42, 0.52),
    HighlightKind.extension => const Offset(0.58, 0.42),
    HighlightKind.reaction => const Offset(0.52, 0.46),
  };
}

String _rolePositioningFor(
  Drama drama, {
  required String companionName,
  String? companionSourceTitle,
}) {
  if (companionSourceTitle != null && companionSourceTitle != drama.title) {
    return '$companionName 来自《$companionSourceTitle》，作为全局陪看角色，会用自己的角色口吻陪用户观看《${drama.title}》。';
  }
  if (drama.id.contains('xiuxian')) {
    return '战斗型主角，外冷内热，遇到高燃桥段会直接给判断。';
  }
  if (drama.id.contains('winter')) {
    return '情绪型角色，敏感但克制，更擅长捕捉关系变化。';
  }
  return '冒险型主角，行动感强，会提醒用户关注线索和反转。';
}

String _characterNameFor(Drama drama) {
  final title = drama.title.split(RegExp(r'[：:，,]')).first.trim();
  if (title.isEmpty) {
    return '高光主角';
  }
  return '$title 主角';
}
