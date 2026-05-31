import 'package:flutter/material.dart';

import '../../drama/data/drama_repository.dart';
import '../../drama/data/local_video_asset_catalog.dart';
import '../../drama/domain/models/drama.dart';
import '../../player/presentation/drama_player_page.dart';

class DramaFeedPage extends StatefulWidget {
  const DramaFeedPage({
    required this.repository,
    this.localCatalog = const LocalVideoAssetCatalog(),
    super.key,
  });

  final DramaRepository repository;
  final LocalVideoAssetCatalog localCatalog;

  @override
  State<DramaFeedPage> createState() => _DramaFeedPageState();
}

class _DramaFeedPageState extends State<DramaFeedPage> {
  late final Future<_FeedLoadResult> _feedFuture = _loadFeed();

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
        return Stack(
          children: [
            PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: result.dramas.length,
              itemBuilder: (context, index) {
                return DramaPlayerPage(
                  key: ValueKey(result.dramas[index].id),
                  drama: result.dramas[index],
                );
              },
            ),
            _FeedSourceBadge(
                source: result.source, count: result.dramas.length),
          ],
        );
      },
    );
  }
}

class _FeedSourceBadge extends StatelessWidget {
  const _FeedSourceBadge({required this.source, required this.count});

  final _FeedSource source;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 12,
      child: SafeArea(
        bottom: false,
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                source == _FeedSource.local
                    ? '本地短剧 $count'
                    : 'Mock Feed $count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
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
