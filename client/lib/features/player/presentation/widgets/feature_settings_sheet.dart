import 'package:flutter/material.dart';

import '../../../profile/domain/profile_controller.dart';

class FeatureSettingsSheet extends StatelessWidget {
  const FeatureSettingsSheet({
    required this.profileController,
    super.key,
  });

  final ProfileController profileController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: profileController,
      builder: (context, _) {
        final settings = profileController.featureSettings;
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
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
                const Text(
                  '功能设置',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                _SwitchRow(
                  icon: Icons.favorite_border,
                  title: '互动功能栏',
                  subtitle: '关注、点赞、评论、分享、收藏',
                  value: settings.socialActionsEnabled,
                  onChanged: (value) => _update(
                    settings.copyWith(socialActionsEnabled: value),
                  ),
                ),
                _SwitchRow(
                  icon: Icons.groups_2,
                  title: '角色好感度',
                  subtitle: '角色入口和送礼解锁',
                  value: settings.characterFavorabilityEnabled,
                  onChanged: (value) => _update(
                    settings.copyWith(characterFavorabilityEnabled: value),
                  ),
                ),
                _SwitchRow(
                  icon: Icons.smart_toy_outlined,
                  title: 'AI 陪看',
                  subtitle: settings.aiCompanionEnabled
                      ? _aiCompanionSubtitle(profileController)
                      : '右下角 Q 版小人和角色弹幕',
                  value: settings.aiCompanionEnabled,
                  onChanged: (value) => _update(
                    settings.copyWith(aiCompanionEnabled: value),
                  ),
                ),
                if (settings.aiCompanionEnabled)
                  _AiCompanionSelector(profileController: profileController),
                _SwitchRow(
                  icon: Icons.back_hand_outlined,
                  title: '扔东西',
                  subtitle: '高光点附近出现道具选择',
                  value: settings.propThrowEnabled,
                  onChanged: (value) => _update(
                    settings.copyWith(propThrowEnabled: value),
                  ),
                ),
                _SwitchRow(
                  icon: Icons.auto_fix_high,
                  title: 'AI 施法',
                  subtitle: '手势识别和特效入口',
                  value: settings.gestureCastEnabled,
                  onChanged: (value) => _update(
                    settings.copyWith(gestureCastEnabled: value),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _update(FeatureSettings settings) {
    profileController.updateFeatureSettings(settings);
  }

  String _aiCompanionSubtitle(ProfileController controller) {
    final selected = controller.selectedAiCompanionCharacter;
    if (selected == null) {
      return '送礼 ${ProfileController.aiCompanionGiftRequirement} 次解锁可选陪看角色';
    }
    return '当前使用：${selected.name}';
  }
}

class _AiCompanionSelector extends StatelessWidget {
  const _AiCompanionSelector({required this.profileController});

  final ProfileController profileController;

  @override
  Widget build(BuildContext context) {
    final unlocked = profileController.unlockedAiCompanionCharacters;
    if (unlocked.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 40, bottom: 8),
        child: Text(
          '暂无已解锁角色，给喜欢的角色送礼后可在所有剧中使用。',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.58),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final selectedId = profileController.selectedAiCompanionCharacterId;
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 0, 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final character in unlocked)
            _AiCompanionChoice(
              label: character.name,
              selected: character.id == selectedId,
              onTap: () {
                profileController.selectAiCompanionCharacter(character.id);
              },
            ),
        ],
      ),
    );
  }
}

class _AiCompanionChoice extends StatelessWidget {
  const _AiCompanionChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? const Color(0xFF07111F)
        : Colors.white.withValues(alpha: 0.9);
    return Tooltip(
      message: selected ? '当前 AI 陪看角色' : '切换 AI 陪看角色',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF7DD3FC) : const Color(0xFF111827),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? const Color(0xFFBAE6FD)
                  : Colors.white.withValues(alpha: 0.18),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF7DD3FC).withValues(alpha: 0.28),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? Icons.check_circle : Icons.smart_toy_outlined,
                  color: foreground,
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: const Color(0xFF7DD3FC)),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.64)),
      ),
      value: value,
      activeThumbColor: const Color(0xFF7DD3FC),
      onChanged: onChanged,
    );
  }
}
