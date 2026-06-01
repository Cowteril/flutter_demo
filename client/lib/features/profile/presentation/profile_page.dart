import 'package:flutter/material.dart';

import '../domain/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.controller, super.key});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF080B12),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: const Color(0xFF080B12),
                foregroundColor: Colors.white,
                title: const Text('个人主页'),
                actions: [
                  IconButton(
                    tooltip: '设置',
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileHeader(controller: controller),
                      const SizedBox(height: 18),
                      _StatsGrid(controller: controller),
                      const SizedBox(height: 18),
                      _Section(
                        title: '成就徽章',
                        action: '${controller.achievementCount} 枚',
                        child: _AchievementList(controller: controller),
                      ),
                      const SizedBox(height: 14),
                      _Section(
                        title: '剧情预测',
                        action: '${controller.predictions.length} 条',
                        child: _PredictionList(controller: controller),
                      ),
                      const SizedBox(height: 14),
                      _Section(
                        title: '喜欢的角色',
                        action: '${controller.favoriteCharacters.length} 位',
                        child: _CharacterList(controller: controller),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final avatar =
        _avatarPalette[controller.avatarSeed % _avatarPalette.length];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: avatar,
                ),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: avatar.last.withValues(alpha: 0.5),
                    blurRadius: 26,
                  ),
                ],
              ),
              child: const SizedBox.square(
                dimension: 82,
                child: Icon(Icons.person, color: Colors.white, size: 42),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: IconButton.filled(
                tooltip: '上传头像',
                iconSize: 16,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4F8B),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(30, 30),
                  padding: EdgeInsets.zero,
                ),
                onPressed: controller.uploadDemoAvatar,
                icon: const Icon(Icons.upload),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.nickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '账号：${controller.account}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ProfilePill(icon: Icons.verified, label: '互动先锋'),
                  _ProfilePill(
                      icon: Icons.local_fire_department, label: '高光捕手'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem('关注', controller.followingCount, Icons.add_circle_outline),
      _StatItem('收藏', controller.favoriteCount, Icons.bookmark_border),
      _StatItem('历史', controller.historyCount, Icons.history),
      _StatItem('点赞', controller.likedCount, Icons.favorite_border),
      _StatItem('成就', controller.achievementCount, Icons.emoji_events_outlined),
      _StatItem('角色', controller.favoriteCharacters.length, Icons.groups_2),
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 78,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(stat.icon, color: const Color(0xFFFFD166), size: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${stat.count}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      stat.label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
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

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.action,
    required this.child,
  });

  final String title;
  final String action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            const Spacer(),
            Text(
              action,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.58),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        child,
      ],
    );
  }
}

class _AchievementList extends StatelessWidget {
  const _AchievementList({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.achievements.isEmpty) {
      return const _EmptyPanel(
        icon: Icons.emoji_events_outlined,
        text: '还没有成就，去预测剧情或给角色送礼解锁',
      );
    }

    return Column(
      children: [
        for (final badge in controller.achievements)
          _ListTilePanel(
            icon: _iconForBadge(badge),
            title: badge.title,
            subtitle: badge.subtitle,
            trailing: '已获得',
            color: const Color(0xFFFFD166),
          ),
      ],
    );
  }
}

class _PredictionList extends StatelessWidget {
  const _PredictionList({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.predictions.isEmpty) {
      return const _EmptyPanel(
        icon: Icons.psychology_alt,
        text: '暂无预测记录，预测入口会在关键剧情前出现',
      );
    }

    return Column(
      children: [
        for (final prediction in controller.predictions)
          _ListTilePanel(
            icon: Icons.psychology_alt,
            title: prediction.highlightTitle,
            subtitle: '${prediction.dramaTitle} · 选择 ${prediction.optionLabel}',
            trailing: prediction.status,
            color: const Color(0xFF7DD3FC),
          ),
      ],
    );
  }
}

class _CharacterList extends StatelessWidget {
  const _CharacterList({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.favoriteCharacters.isEmpty) {
      return const _EmptyPanel(
        icon: Icons.groups_2,
        text: '还没有喜欢的角色，去播放页给角色点赞或送礼',
      );
    }

    return Column(
      children: [
        for (final character in controller.favoriteCharacters)
          _ListTilePanel(
            icon: Icons.person,
            title: character.name,
            subtitle:
                '${character.dramaTitle} · 好感度 ${character.score} · 礼物 ${character.gifts}',
            trailing: controller.selectedAiCompanionCharacterId == character.id
                ? 'AI使用中'
                : character.isAiCompanionUnlocked
                    ? 'AI已解锁'
                    : character.isUnlocked
                        ? '已解锁'
                        : '未解锁',
            color: controller.selectedAiCompanionCharacterId == character.id
                ? const Color(0xFFFFD166)
                : character.isUnlocked
                    ? const Color(0xFFFF4F8B)
                    : const Color(0xFF7DD3FC),
          ),
      ],
    );
  }
}

class _ListTilePanel extends StatelessWidget {
  const _ListTilePanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.18),
            foregroundColor: color,
            child: Icon(icon),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.62)),
          ),
          trailing: Text(
            trailing,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFFFD166), size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  const _StatItem(this.label, this.count, this.icon);

  final String label;
  final int count;
  final IconData icon;
}

IconData _iconForBadge(AchievementBadge badge) {
  return switch (badge.id) {
    'avatar_uploaded' => Icons.image,
    'first_watch' => Icons.play_circle_outline,
    'first_follow' => Icons.add_circle_outline,
    'first_favorite' => Icons.bookmark_border,
    'first_like' => Icons.favorite_border,
    'first_prediction' => Icons.psychology_alt,
    'first_character_like' => Icons.favorite,
    'first_gift' => Icons.card_giftcard,
    'ai_companion_unlocked' => Icons.smart_toy_outlined,
    _ => Icons.emoji_events_outlined,
  };
}

const _avatarPalette = [
  [Color(0xFF2E5EAA), Color(0xFFFF4F8B)],
  [Color(0xFF1F7A65), Color(0xFFFFD166)],
  [Color(0xFF7C3AED), Color(0xFF7DD3FC)],
  [Color(0xFFDC2626), Color(0xFFFACC15)],
  [Color(0xFF0F766E), Color(0xFFF472B6)],
  [Color(0xFF334155), Color(0xFFFF7A1A)],
];
