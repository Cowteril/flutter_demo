import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../drama/data/drama_repository.dart';
import '../../drama/data/local_video_asset_catalog.dart';
import '../../drama/domain/models/drama.dart';
import '../../player/presentation/drama_player_page.dart';
import '../../profile/domain/profile_controller.dart';
import '../../profile/presentation/profile_page.dart';

class DramaFeedPage extends StatefulWidget {
  const DramaFeedPage({
    required this.repository,
    this.localCatalog = const LocalVideoAssetCatalog(),
    this.profileController,
    super.key,
  });

  final DramaRepository repository;
  final LocalVideoAssetCatalog localCatalog;
  final ProfileController? profileController;

  @override
  State<DramaFeedPage> createState() => _DramaFeedPageState();
}

class _DramaFeedPageState extends State<DramaFeedPage> {
  late Future<_FeedLoadResult> _feedFuture;
  late final PageController _pageController = PageController();
  late final ProfileController _profileController =
      widget.profileController ?? ProfileController();
  var _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _feedFuture = _loadFeed();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    if (widget.profileController == null) {
      _profileController.dispose();
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<_FeedLoadResult> _loadFeed() async {
    final local = await widget.localCatalog.loadDramas().catchError((_) {
      return <Drama>[];
    });
    if (local.isNotEmpty) {
      return _FeedLoadResult(dramas: local, source: _FeedSource.local);
    }

    final fallback = await widget.repository.listDramas();
    return _FeedLoadResult(dramas: fallback, source: _FeedSource.mock);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_FeedLoadResult>(
      future: _feedFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final result = snapshot.data!;
        if (result.dramas.isEmpty) {
          return _FeedEmptyState(onRetry: _retryLoad);
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final viewportWidth = _feedViewportWidth(constraints);
              return Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: SizedBox(
                      width: viewportWidth,
                      height: constraints.maxHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: viewportWidth < constraints.maxWidth
                              ? Border.symmetric(
                                  vertical: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                )
                              : null,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              scrollDirection: Axis.vertical,
                              itemCount: result.dramas.length,
                              onPageChanged: (index) {
                                _markLaterContentSeen(result.dramas, index);
                                setState(() => _currentIndex = index);
                              },
                              itemBuilder: (context, index) {
                                final isActive = index == _currentIndex;
                                return TickerMode(
                                  enabled: (index - _currentIndex).abs() <= 1,
                                  child: DramaPlayerPage(
                                    key: ValueKey(result.dramas[index].id),
                                    drama: result.dramas[index],
                                    isActive: isActive,
                                    autoPlay: true,
                                    manageSystemUi: false,
                                    showTopBar: false,
                                    profileController: _profileController,
                                    feedPositionLabel:
                                        '第 ${index + 1}/${result.dramas.length} 部',
                                  ),
                                );
                              },
                            ),
                            _FeedChrome(
                              source: result.source,
                              currentIndex: _currentIndex,
                              count: result.dramas.length,
                              onProfileTap: _openProfile,
                            ),
                            if (_currentIndex < result.dramas.length - 1)
                              const _NextCue(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _retryLoad() {
    setState(() {
      _currentIndex = 0;
      _feedFuture = _loadFeed();
    });
  }

  void _markLaterContentSeen(List<Drama> dramas, int nextIndex) {
    if (nextIndex <= _currentIndex) {
      return;
    }
    final lastSeenIndex = math.min(nextIndex, dramas.length);
    for (var index = 0; index < lastSeenIndex; index++) {
      _profileController.markSeenLaterContent(dramas[index].id);
    }
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfilePage(controller: _profileController),
      ),
    );
  }
}

double _feedViewportWidth(BoxConstraints constraints) {
  if (constraints.maxHeight <= 0 || constraints.maxWidth <= 0) {
    return constraints.maxWidth;
  }
  return math.min(constraints.maxWidth, constraints.maxHeight * 9 / 16);
}

class _FeedChrome extends StatelessWidget {
  const _FeedChrome({
    required this.source,
    required this.currentIndex,
    required this.count,
    required this.onProfileTap,
  });

  final _FeedSource source;
  final int currentIndex;
  final int count;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          child: Row(
            children: [
              const Expanded(
                child: IgnorePointer(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: NeverScrollableScrollPhysics(),
                    child: _FeedTabs(),
                  ),
                ),
              ),
              IgnorePointer(
                child: _FeedSourcePill(
                    label: source == _FeedSource.local ? '本地' : 'Mock',
                    progress: '${currentIndex + 1}/$count'),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: '个人主页',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.42),
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onProfileTap,
                icon: const Icon(Icons.person_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedTabs extends StatelessWidget {
  const _FeedTabs();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FeedTab(label: '推荐', selected: true),
        _FeedTab(label: '互动', selected: false),
        _FeedTab(label: '追剧', selected: false, trailingGap: 0),
      ],
    );
  }
}

class _FeedTab extends StatelessWidget {
  const _FeedTab({
    required this.label,
    required this.selected,
    this.trailingGap = 8,
  });

  final String label;
  final bool selected;
  final double trailingGap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: trailingGap),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontSize: selected ? 16 : 14,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 20 : 0,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedSourcePill extends StatelessWidget {
  const _FeedSourcePill({required this.label, required this.progress});

  final String label;
  final String progress;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          '$label · $progress',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _NextCue extends StatelessWidget {
  const _NextCue();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: SafeArea(
          top: false,
          child: Icon(
            Icons.keyboard_arrow_up,
            color: Colors.white.withValues(alpha: 0.58),
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _FeedEmptyState extends StatelessWidget {
  const _FeedEmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.video_library_outlined,
                  color: Colors.white70, size: 54),
              const SizedBox(height: 14),
              const Text(
                '暂无可播放内容',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('刷新'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedLoadResult {
  const _FeedLoadResult({required this.dramas, required this.source});

  final List<Drama> dramas;
  final _FeedSource source;
}

enum _FeedSource {
  local,
  mock,
}
