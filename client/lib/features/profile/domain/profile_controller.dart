import 'package:flutter/foundation.dart';

import '../../drama/domain/models/drama.dart';
import '../../drama/domain/models/highlight_point.dart';

class ProfileController extends ChangeNotifier {
  static const aiCompanionGiftRequirement = 2;

  ProfileController({
    this.nickname = '短剧体验官',
    this.account = 'duanju_2026',
    int avatarSeed = 0,
  }) : _avatarSeed = avatarSeed;

  String nickname;
  String account;
  int _avatarSeed;

  final Set<String> _followingDramaIds = {};
  final Set<String> _favoriteDramaIds = {};
  final Set<String> _historyDramaIds = {};
  final Set<String> _likedDramaIds = {};
  final Set<String> _seenLaterContentDramaIds = {};
  final Map<String, String> _predictionDisqualificationReasons = {};
  final Map<String, PredictionRecord> _predictions = {};
  final Map<String, AchievementBadge> _achievements = {};
  final Map<String, CharacterFavorability> _characters = {};
  FeatureSettings _featureSettings = const FeatureSettings();
  String? _selectedAiCompanionCharacterId;

  int get avatarSeed => _avatarSeed;
  List<String> get followingDramaIds => _followingDramaIds.toList();
  List<String> get favoriteDramaIds => _favoriteDramaIds.toList();
  List<String> get historyDramaIds => _historyDramaIds.toList();
  List<String> get likedDramaIds => _likedDramaIds.toList();
  List<PredictionRecord> get predictions => _predictions.values.toList();
  List<AchievementBadge> get achievements => _achievements.values.toList();
  FeatureSettings get featureSettings => _featureSettings;
  String? get selectedAiCompanionCharacterId =>
      selectedAiCompanionCharacter?.id ?? _selectedAiCompanionCharacterId;
  CharacterFavorability? get selectedAiCompanionCharacter {
    final unlocked = unlockedAiCompanionCharacters;
    if (unlocked.isEmpty) {
      return null;
    }
    for (final character in unlocked) {
      if (character.id == _selectedAiCompanionCharacterId) {
        return character;
      }
    }
    return unlocked.first;
  }

  List<CharacterFavorability> get favoriteCharacters => _characters.values
      .where((character) =>
          character.liked || character.gifts > 0 || character.isUnlocked)
      .toList()
    ..sort((a, b) => b.score.compareTo(a.score));
  List<CharacterFavorability> get unlockedAiCompanionCharacters =>
      _characters.values
          .where((character) => character.isAiCompanionUnlocked)
          .toList()
        ..sort((a, b) => b.gifts.compareTo(a.gifts));

  int get followingCount => _followingDramaIds.length;
  int get favoriteCount => _favoriteDramaIds.length;
  int get historyCount => _historyDramaIds.length;
  int get likedCount => _likedDramaIds.length;
  int get achievementCount => _achievements.length;

  void updateFeatureSettings(FeatureSettings settings) {
    _featureSettings = settings;
    notifyListeners();
  }

  void selectAiCompanionCharacter(String characterId) {
    final character = _characters[characterId];
    if (character == null || !character.isAiCompanionUnlocked) {
      return;
    }
    if (_selectedAiCompanionCharacterId == characterId) {
      return;
    }
    _selectedAiCompanionCharacterId = characterId;
    notifyListeners();
  }

  void uploadDemoAvatar() {
    _avatarSeed = (_avatarSeed + 1) % 6;
    _unlockAchievement(
      const AchievementBadge(
        id: 'avatar_uploaded',
        title: '头像已就位',
        subtitle: '完成一次头像上传',
        iconCodePoint: 0xe3b0,
      ),
    );
    notifyListeners();
  }

  void recordHistory(Drama drama) {
    if (_historyDramaIds.add(drama.id)) {
      _unlockAchievement(
        const AchievementBadge(
          id: 'first_watch',
          title: '开追第一集',
          subtitle: '开始观看短剧内容',
          iconCodePoint: 0xe037,
        ),
        shouldNotify: false,
      );
      notifyListeners();
    }
  }

  void followDrama(Drama drama) {
    if (_followingDramaIds.add(drama.id)) {
      _unlockAchievement(
        const AchievementBadge(
          id: 'first_follow',
          title: '追剧雷达',
          subtitle: '关注一部短剧',
          iconCodePoint: 0xe87d,
        ),
        shouldNotify: false,
      );
      notifyListeners();
    }
  }

  void favoriteDrama(Drama drama) {
    if (_favoriteDramaIds.add(drama.id)) {
      _unlockAchievement(
        const AchievementBadge(
          id: 'first_favorite',
          title: '名场面收藏家',
          subtitle: '收藏一部短剧',
          iconCodePoint: 0xe866,
        ),
        shouldNotify: false,
      );
      notifyListeners();
    }
  }

  void likeDrama(Drama drama) {
    if (_likedDramaIds.add(drama.id)) {
      _unlockAchievement(
        const AchievementBadge(
          id: 'first_like',
          title: '心动暴击',
          subtitle: '第一次为短剧点赞',
          iconCodePoint: 0xe87d,
        ),
        shouldNotify: false,
      );
      notifyListeners();
    }
  }

  void markSeenLaterContent(String dramaId) {
    if (_seenLaterContentDramaIds.add(dramaId)) {
      notifyListeners();
    }
  }

  void markSeekedPastPrediction({
    required String dramaId,
    required HighlightPoint highlight,
  }) {
    _markPredictionDisqualified(
      dramaId: dramaId,
      highlight: highlight,
      reason: '你曾提前跳到预测点之后，已无法参与本次竞猜。',
    );
  }

  void markWatchedPastPrediction({
    required String dramaId,
    required HighlightPoint highlight,
  }) {
    _markPredictionDisqualified(
      dramaId: dramaId,
      highlight: highlight,
      reason: '你已经看过预测点之后的剧情，已无法参与本次竞猜。',
    );
  }

  void _markPredictionDisqualified({
    required String dramaId,
    required HighlightPoint highlight,
    required String reason,
  }) {
    if (highlight.kind != HighlightKind.prediction) {
      return;
    }
    final key = _predictionKey(dramaId, highlight.id);
    if (_predictions.containsKey(key)) {
      return;
    }
    if (!_predictionDisqualificationReasons.containsKey(key)) {
      _predictionDisqualificationReasons[key] = reason;
      notifyListeners();
    }
  }

  PredictionEligibility predictionEligibility({
    required Drama drama,
    required HighlightPoint highlight,
  }) {
    final key = _predictionKey(drama.id, highlight.id);
    if (_predictions.containsKey(key)) {
      return const PredictionEligibility(
        canPredict: false,
        reason: '你已经提交过本次预测，开奖前不会展示答案。',
      );
    }
    if (_seenLaterContentDramaIds.contains(drama.id)) {
      return const PredictionEligibility(
        canPredict: false,
        reason: '你已经看过后续内容，本次预测仅对未知剧情开放。',
      );
    }
    final disqualificationReason = _predictionDisqualificationReasons[key];
    if (disqualificationReason != null) {
      return PredictionEligibility(
        canPredict: false,
        reason: disqualificationReason,
      );
    }
    return const PredictionEligibility(canPredict: true);
  }

  bool hasPrediction({
    required Drama drama,
    required HighlightPoint highlight,
  }) {
    return _predictions.containsKey(_predictionKey(drama.id, highlight.id));
  }

  void submitPrediction({
    required Drama drama,
    required HighlightPoint highlight,
    required InteractionOption option,
  }) {
    final key = _predictionKey(drama.id, highlight.id);
    if (_predictions.containsKey(key)) {
      return;
    }
    _predictions[key] = PredictionRecord(
      id: key,
      dramaTitle: drama.title,
      highlightTitle: highlight.title,
      optionLabel: option.label,
      status: '待开奖',
      submittedAt: DateTime.now(),
    );
    _unlockAchievement(
      const AchievementBadge(
        id: 'first_prediction',
        title: '剧情预言家',
        subtitle: '完成一次剧情预测',
        iconCodePoint: 0xf04b,
      ),
      shouldNotify: false,
    );
    notifyListeners();
  }

  CharacterFavorability characterFor(Drama drama) {
    final key = _characterKey(drama);
    return _characters.putIfAbsent(
      key,
      () => CharacterFavorability(
        id: key,
        name: _characterNameFor(drama),
        dramaTitle: drama.title,
        score: 24,
        liked: false,
        gifts: 0,
      ),
    );
  }

  void likeCharacter(Drama drama) {
    final character = characterFor(drama);
    if (character.liked) {
      return;
    }
    _characters[character.id] = character.copyWith(
      score: character.score + 16,
      liked: true,
    );
    _unlockAchievement(
      const AchievementBadge(
        id: 'first_character_like',
        title: '角色心动',
        subtitle: '第一次给角色点赞',
        iconCodePoint: 0xe87d,
      ),
      shouldNotify: false,
    );
    notifyListeners();
  }

  void giftCharacter(Drama drama) {
    final character = characterFor(drama);
    final updated = character.copyWith(
      score: character.score + 28,
      gifts: character.gifts + 1,
    );
    _characters[character.id] = updated;
    _unlockAchievement(
      const AchievementBadge(
        id: 'first_gift',
        title: '投喂名场面',
        subtitle: '第一次给角色送礼',
        iconCodePoint: 0xe8f6,
      ),
      shouldNotify: false,
    );
    if (updated.isAiCompanionUnlocked) {
      _selectedAiCompanionCharacterId ??= updated.id;
      _unlockAchievement(
        const AchievementBadge(
          id: 'ai_companion_unlocked',
          title: 'AI 陪看搭子',
          subtitle: '为角色送礼解锁 AI 陪看',
          iconCodePoint: 0xe7fd,
        ),
        shouldNotify: false,
      );
    }
    notifyListeners();
  }

  void _unlockAchievement(
    AchievementBadge badge, {
    bool shouldNotify = true,
  }) {
    _achievements.putIfAbsent(badge.id, () => badge);
    if (shouldNotify) {
      notifyListeners();
    }
  }
}

class PredictionEligibility {
  const PredictionEligibility({
    required this.canPredict,
    this.reason,
  });

  final bool canPredict;
  final String? reason;
}

class PredictionRecord {
  const PredictionRecord({
    required this.id,
    required this.dramaTitle,
    required this.highlightTitle,
    required this.optionLabel,
    required this.status,
    required this.submittedAt,
  });

  final String id;
  final String dramaTitle;
  final String highlightTitle;
  final String optionLabel;
  final String status;
  final DateTime submittedAt;
}

class AchievementBadge {
  const AchievementBadge({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconCodePoint,
  });

  final String id;
  final String title;
  final String subtitle;
  final int iconCodePoint;
}

class FeatureSettings {
  const FeatureSettings({
    this.socialActionsEnabled = true,
    this.characterFavorabilityEnabled = true,
    this.gestureCastEnabled = true,
    this.aiCompanionEnabled = true,
    this.propThrowEnabled = true,
  });

  final bool socialActionsEnabled;
  final bool characterFavorabilityEnabled;
  final bool gestureCastEnabled;
  final bool aiCompanionEnabled;
  final bool propThrowEnabled;

  FeatureSettings copyWith({
    bool? socialActionsEnabled,
    bool? characterFavorabilityEnabled,
    bool? gestureCastEnabled,
    bool? aiCompanionEnabled,
    bool? propThrowEnabled,
  }) {
    return FeatureSettings(
      socialActionsEnabled: socialActionsEnabled ?? this.socialActionsEnabled,
      characterFavorabilityEnabled:
          characterFavorabilityEnabled ?? this.characterFavorabilityEnabled,
      gestureCastEnabled: gestureCastEnabled ?? this.gestureCastEnabled,
      aiCompanionEnabled: aiCompanionEnabled ?? this.aiCompanionEnabled,
      propThrowEnabled: propThrowEnabled ?? this.propThrowEnabled,
    );
  }
}

class CharacterFavorability {
  const CharacterFavorability({
    required this.id,
    required this.name,
    required this.dramaTitle,
    required this.score,
    required this.liked,
    required this.gifts,
  });

  final String id;
  final String name;
  final String dramaTitle;
  final int score;
  final bool liked;
  final int gifts;

  bool get isUnlocked => score >= 68;
  bool get isAiCompanionUnlocked =>
      gifts >= ProfileController.aiCompanionGiftRequirement;

  CharacterFavorability copyWith({
    int? score,
    bool? liked,
    int? gifts,
  }) {
    return CharacterFavorability(
      id: id,
      name: name,
      dramaTitle: dramaTitle,
      score: score ?? this.score,
      liked: liked ?? this.liked,
      gifts: gifts ?? this.gifts,
    );
  }
}

String _predictionKey(String dramaId, String highlightId) {
  return '$dramaId::$highlightId';
}

String _characterKey(Drama drama) {
  return '${drama.id}::lead';
}

String _characterNameFor(Drama drama) {
  final title = drama.title.split(RegExp(r'[：:，,]')).first.trim();
  if (title.isEmpty) {
    return '高光主角';
  }
  return '$title 主角';
}
