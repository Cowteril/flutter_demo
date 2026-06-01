import 'package:flutter/material.dart';

import '../../drama/data/drama_repository.dart';
import '../../drama/data/local_video_asset_catalog.dart';
import '../../drama/domain/models/drama.dart';
import '../../feed/presentation/drama_feed_page.dart';
import '../../player/presentation/drama_player_page.dart';
import '../../profile/domain/profile_controller.dart';
import '../../profile/presentation/profile_page.dart';

class DramaHomePage extends StatefulWidget {
  const DramaHomePage({
    required this.repository,
    this.localCatalog = const LocalVideoAssetCatalog(),
    super.key,
  });

  final DramaRepository repository;
  final LocalVideoAssetCatalog localCatalog;

  @override
  State<DramaHomePage> createState() => _DramaHomePageState();
}

class _DramaHomePageState extends State<DramaHomePage> {
  late Future<_HomeLoadResult> _homeFuture;
  late final ProfileController _profileController = ProfileController();
  final _searchController = TextEditingController();
  var _query = '';
  var _selectedFilter = _HomeFilter.all;

  @override
  void initState() {
    super.initState();
    _homeFuture = _loadHome();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  Future<_HomeLoadResult> _loadHome() async {
    final local = await widget.localCatalog.loadDramas().catchError((_) {
      return <Drama>[];
    });
    if (local.isNotEmpty) {
      return _HomeLoadResult(dramas: local, sourceLabel: '本地片库');
    }
    final fallback = await widget.repository.listDramas();
    return _HomeLoadResult(dramas: fallback, sourceLabel: '演示片库');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      body: FutureBuilder<_HomeLoadResult>(
        future: _homeFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final result = snapshot.data!;
          final filtered = _filterDramas(result.dramas);
          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _HomeHeader(
                    sourceLabel: result.sourceLabel,
                    searchController: _searchController,
                    onProfileTap: _openProfile,
                    onOpenFeed: _openFeed,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _FilterBar(
                    selected: _selectedFilter,
                    onChanged: (filter) {
                      setState(() => _selectedFilter = filter);
                    },
                  ),
                ),
                if (_query.isEmpty && result.dramas.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _FeaturedRail(
                      dramas: result.dramas.take(5).toList(),
                      onOpen: _openDrama,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: _query.isEmpty ? '全部短剧' : '搜索结果',
                    trailing: '${filtered.length} 部',
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  sliver: filtered.isEmpty
                      ? SliverToBoxAdapter(
                          child: _EmptySearchState(
                            query: _query,
                            onClear: _searchController.clear,
                          ),
                        )
                      : SliverList.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _DramaBrowseTile(
                              drama: filtered[index],
                              rank: index + 1,
                              onOpen: () => _openDrama(filtered[index]),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Drama> _filterDramas(List<Drama> dramas) {
    final lowerQuery = _query.toLowerCase();
    return [
      for (final drama in dramas)
        if (_matchesQuery(drama, lowerQuery) && _matchesFilter(drama)) drama,
    ];
  }

  bool _matchesQuery(Drama drama, String lowerQuery) {
    if (lowerQuery.isEmpty) {
      return true;
    }
    return drama.title.toLowerCase().contains(lowerQuery) ||
        drama.subtitle.toLowerCase().contains(lowerQuery);
  }

  bool _matchesFilter(Drama drama) {
    return switch (_selectedFilter) {
      _HomeFilter.all => true,
      _HomeFilter.hot => drama.highlights.length >= 2,
      _HomeFilter.interactive =>
        drama.highlights.any((highlight) => highlight.options.length >= 2),
      _HomeFilter.longSeries => drama.episodeCount >= 20,
    };
  }

  void _openDrama(Drama drama) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DramaPlayerPage(
          drama: drama,
          profileController: _profileController,
        ),
      ),
    );
  }

  void _openFeed() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DramaFeedPage(
          repository: widget.repository,
          localCatalog: widget.localCatalog,
          profileController: _profileController,
        ),
      ),
    );
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfilePage(controller: _profileController),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.sourceLabel,
    required this.searchController,
    required this.onProfileTap,
    required this.onOpenFeed,
  });

  final String sourceLabel;
  final TextEditingController searchController;
  final VoidCallback onProfileTap;
  final VoidCallback onOpenFeed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '短剧广场',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$sourceLabel · 搜索、筛选、继续竖滑观看',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: '个人主页',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onProfileTap,
                icon: const Icon(Icons.person_outline),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SearchBar(
                  controller: searchController,
                  hintText: '搜索短剧、题材、关键词',
                  leading: const Icon(Icons.search),
                  trailing: [
                    if (searchController.text.isNotEmpty)
                      IconButton(
                        tooltip: '清空',
                        onPressed: searchController.clear,
                        icon: const Icon(Icons.close),
                      ),
                  ],
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  hintStyle: WidgetStateProperty.all(
                    TextStyle(color: Colors.white.withValues(alpha: 0.58)),
                  ),
                  backgroundColor: WidgetStateProperty.all(
                    const Color(0xFF111827),
                  ),
                  side: WidgetStateProperty.all(
                    BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  elevation: WidgetStateProperty.all(0),
                ),
              ),
              const SizedBox(width: 10),
              Tooltip(
                message: '进入竖滑观看',
                child: SizedBox.square(
                  dimension: 52,
                  child: IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4F8B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onOpenFeed,
                    icon: const Icon(Icons.smart_display),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selected,
    required this.onChanged,
  });

  final _HomeFilter selected;
  final ValueChanged<_HomeFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _HomeFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _HomeFilter.values[index];
          final isSelected = selected == filter;
          return ChoiceChip(
            label: Text(filter.label),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onChanged(filter),
            color: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF7DD3FC);
              }
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFF223148);
              }
              return const Color(0xFF151B27);
            }),
            labelStyle: TextStyle(
              color: isSelected
                  ? const Color(0xFF07111F)
                  : const Color(0xFFE8EEF8),
              fontWeight: FontWeight.w900,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF7DD3FC)
                  : const Color(0xFF2A3445),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            surfaceTintColor: Colors.transparent,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.trailing,
  });

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF151B27),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF263244)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                trailing,
                style: const TextStyle(
                  color: Color(0xFFB7C2D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedRail extends StatelessWidget {
  const _FeaturedRail({
    required this.dramas,
    required this.onOpen,
  });

  final List<Drama> dramas;
  final ValueChanged<Drama> onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '精选推荐',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 188,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: dramas.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final drama = dramas[index];
                return _FeaturedCard(
                  drama: drama,
                  index: index,
                  onTap: () => onOpen(drama),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.drama,
    required this.index,
    required this.onTap,
  });

  final Drama drama;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Color(drama.coverColor);
    return SizedBox(
      width: 136,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PosterBlock(
                  accent: accent,
                  title: drama.title,
                  compact: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
                child: Text(
                  drama.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DramaBrowseTile extends StatelessWidget {
  const _DramaBrowseTile({
    required this.drama,
    required this.rank,
    required this.onOpen,
  });

  final Drama drama;
  final int rank;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final accent = Color(drama.coverColor);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onOpen,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                height: 96,
                child: _PosterBlock(accent: accent, title: drama.title),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _RankPill(rank: rank),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            drama.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      drama.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.66),
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _MetaTag(
                          icon: Icons.video_library_outlined,
                          label: '${drama.episodeCount} 集',
                        ),
                        _MetaTag(
                          icon: Icons.bolt_outlined,
                          label: '${drama.highlights.length} 高光',
                        ),
                        const _MetaTag(
                          icon: Icons.touch_app_outlined,
                          label: '互动',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

class _PosterBlock extends StatelessWidget {
  const _PosterBlock({
    required this.accent,
    required this.title,
    this.compact = false,
  });

  final Color accent;
  final String title;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent,
            const Color(0xFF111827),
            const Color(0xFFFF4F8B),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 8,
            top: 8,
            child: Icon(
              Icons.movie_creation_outlined,
              color: Colors.white.withValues(alpha: 0.72),
              size: compact ? 24 : 22,
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Text(
              title.characters.take(4).toString(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Colors.black, blurRadius: 8)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankPill extends StatelessWidget {
  const _RankPill({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFD166),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          '$rank',
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  const _MetaTag({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF7DD3FC), size: 14),
            const SizedBox(width: 4),
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

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({
    required this.query,
    required this.onClear,
  });

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            color: Colors.white.withValues(alpha: 0.62),
            size: 54,
          ),
          const SizedBox(height: 12),
          Text(
            '没有找到「$query」',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.close),
            label: const Text('清空搜索'),
          ),
        ],
      ),
    );
  }
}

class _HomeLoadResult {
  const _HomeLoadResult({
    required this.dramas,
    required this.sourceLabel,
  });

  final List<Drama> dramas;
  final String sourceLabel;
}

enum _HomeFilter {
  all('全部'),
  hot('高光多'),
  interactive('强互动'),
  longSeries('长剧集');

  const _HomeFilter(this.label);

  final String label;
}
