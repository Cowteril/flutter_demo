import 'package:flutter/material.dart';

import '../../../drama/domain/models/drama.dart';
import '../../../profile/domain/profile_controller.dart';

class CharacterFavorabilitySheet extends StatelessWidget {
  const CharacterFavorabilitySheet({
    required this.drama,
    required this.profileController,
    super.key,
  });

  final Drama drama;
  final ProfileController profileController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: profileController,
      builder: (context, _) {
        final character = profileController.characterFor(drama);
        final progress = (character.score / 100).clamp(0.0, 1.0).toDouble();
        final accent = Color(drama.coverColor);
        final isSelectedAiCompanion =
            profileController.selectedAiCompanionCharacterId == character.id;

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accent,
                            const Color(0xFFFFD166),
                            const Color(0xFFFF4F8B),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.45),
                            blurRadius: 22,
                          ),
                        ],
                      ),
                      child: const SizedBox.square(
                        dimension: 58,
                        child:
                            Icon(Icons.person, color: Colors.white, size: 34),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            character.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            character.dramaTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.68),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${character.score}',
                      style: const TextStyle(
                        color: Color(0xFFFFD166),
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(
                    children: [
                      Container(
                        height: 12,
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 12,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF7DD3FC),
                                Color(0xFFFFD166),
                                Color(0xFFFF4F8B),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  character.isUnlocked
                      ? '已解锁专属内容：角色独白与隐藏名场面'
                      : '好感度达到 68 解锁角色独白与隐藏名场面',
                  style: TextStyle(
                    color: character.isUnlocked
                        ? const Color(0xFFFFD166)
                        : Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSelectedAiCompanion
                      ? '当前 AI 陪看角色，可在所有剧中使用'
                      : character.isAiCompanionUnlocked
                          ? 'AI 陪看已解锁，可在设置中切换使用'
                          : '送礼 ${ProfileController.aiCompanionGiftRequirement} 次解锁 AI 陪看角色',
                  style: TextStyle(
                    color: character.isAiCompanionUnlocked
                        ? const Color(0xFF7DD3FC)
                        : Colors.white.withValues(alpha: 0.68),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: character.liked
                            ? null
                            : () => profileController.likeCharacter(drama),
                        icon: Icon(
                          character.liked
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                        label: Text(character.liked ? '已点赞' : '点赞 +16'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => profileController.giftCharacter(drama),
                        icon: const Icon(Icons.card_giftcard),
                        label: const Text('送礼 +28'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
