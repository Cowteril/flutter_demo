import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';

import '../../player/domain/models/effect_type.dart';
import '../domain/models/drama.dart';
import '../domain/models/highlight_point.dart';

class LocalVideoAssetCatalog {
  const LocalVideoAssetCatalog({
    this.assetPrefix = 'assets/local_videos/',
  });

  final String assetPrefix;

  Future<List<Drama>> loadDramas() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assetPaths = manifest.listAssets();
    final catalogDramas = await _loadCatalogDramas(assetPaths.toSet());
    if (catalogDramas.isNotEmpty) {
      return catalogDramas;
    }

    return dramasFromAssetPaths(assetPaths);
  }

  Future<List<Drama>> _loadCatalogDramas(
      Set<String> availableAssetPaths) async {
    try {
      final text = await rootBundle.loadString('${assetPrefix}catalog.json');
      final decoded = jsonDecode(text);
      final videos =
          decoded is Map<String, dynamic> ? decoded['videos'] : decoded;
      if (videos is! Iterable) {
        return const [];
      }
      return dramasFromCatalogEntries(
        videos.whereType<Map<String, dynamic>>(),
        availableAssetPaths: availableAssetPaths,
      );
    } on Object {
      return const [];
    }
  }

  List<Drama> dramasFromCatalogEntries(Iterable<Map<String, dynamic>> entries,
      {Set<String>? availableAssetPaths}) {
    final episodes = <_LocalEpisode>[];
    for (final entry in entries) {
      final assetPath = _stringValue(entry['asset']);
      if (assetPath == null ||
          !assetPath.startsWith(assetPrefix) ||
          !assetPath.toLowerCase().endsWith('.mp4')) {
        continue;
      }
      if (availableAssetPaths != null &&
          !availableAssetPaths.contains(assetPath)) {
        continue;
      }

      final fileName = assetPath.split('/').last.trim();
      final title = _stringValue(entry['title']) ?? _titleFromPath(assetPath);
      if (title.isEmpty || fileName.isEmpty) {
        continue;
      }

      episodes.add(
        _LocalEpisode(
          title: title,
          fileName: fileName,
          episodeNumber: _intValue(entry['episodeNumber']) ??
              _episodeNumber(_stringValue(entry['displayEpisode']) ?? fileName),
          assetPath: assetPath,
        ),
      );
    }
    return _dramasFromEpisodes(episodes);
  }

  List<Drama> dramasFromAssetPaths(Iterable<String> assetPaths) {
    final episodes = <_LocalEpisode>[];
    for (final path in assetPaths) {
      final normalized = path.replaceAll('\\', '/');
      if (!normalized.startsWith(assetPrefix) ||
          !normalized.toLowerCase().endsWith('.mp4')) {
        continue;
      }
      final relative = normalized.substring(assetPrefix.length);
      final parts = relative.split('/');
      final fileName = parts.last.trim();
      final title = parts.length >= 2
          ? parts.first.trim()
          : _titleFromFlatFileName(fileName).trim();
      if (title.isEmpty || fileName.isEmpty) {
        continue;
      }
      episodes.add(
        _LocalEpisode(
          title: title,
          fileName: fileName,
          episodeNumber: _episodeNumber(fileName),
          assetPath: normalized,
        ),
      );
    }

    return _dramasFromEpisodes(episodes);
  }

  List<Drama> _dramasFromEpisodes(List<_LocalEpisode> episodes) {
    episodes.sort((a, b) {
      final titleCompare = a.title.compareTo(b.title);
      if (titleCompare != 0) {
        return titleCompare;
      }
      final episodeCompare = a.episodeNumber.compareTo(b.episodeNumber);
      if (episodeCompare != 0) {
        return episodeCompare;
      }
      return a.fileName.compareTo(b.fileName);
    });

    final counts = <String, int>{};
    for (final episode in episodes) {
      counts[episode.title] = (counts[episode.title] ?? 0) + 1;
    }

    return [
      for (var i = 0; i < episodes.length; i++)
        _dramaFromEpisode(
          episodes[i],
          index: i,
          episodeCount: counts[episodes[i].title] ?? 1,
        ),
    ];
  }

  Drama _dramaFromEpisode(
    _LocalEpisode episode, {
    required int index,
    required int episodeCount,
  }) {
    final color = _palette[index % _palette.length];
    final highPointOffset = 6 + index % 5;

    return Drama(
      id: 'local-${_stableId(episode.assetPath)}',
      title: episode.title,
      subtitle: '本地视频 · ${episode.displayEpisode} · v0.3 竖滑 Feed',
      coverColor: color,
      episodeCount: math.max(episodeCount, episode.episodeNumber),
      duration: const Duration(seconds: 45),
      videoUrl: episode.assetPath,
      highlights: [
        HighlightPoint(
          id: 'local-${episode.episodeNumber}-reaction',
          at: Duration(seconds: highPointOffset),
          title: '剧情高光触发',
          description: '本地短剧片段高光点，用于验证互动层叠加。',
          kind: HighlightKind.reaction,
          options: const [
            InteractionOption(
              id: 'burst',
              label: '爽',
              effectText: '本地片段触发高光爆发',
              effectType: EffectType.shockwave,
            ),
            InteractionOption(
              id: 'comment',
              label: '上头',
              effectText: '加入同屏情绪反馈',
              effectType: EffectType.textFly,
            ),
          ],
        ),
      ],
    );
  }
}

class _LocalEpisode {
  const _LocalEpisode({
    required this.title,
    required this.fileName,
    required this.episodeNumber,
    required this.assetPath,
  });

  final String title;
  final String fileName;
  final int episodeNumber;
  final String assetPath;

  String get displayEpisode =>
      episodeNumber > 0 ? '第$episodeNumber集' : fileName;
}

String? _stringValue(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return null;
}

int? _intValue(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

String _titleFromPath(String assetPath) {
  final relative = assetPath.replaceAll('\\', '/');
  final parts = relative.split('/');
  if (parts.length >= 3) {
    return parts[parts.length - 2].trim();
  }
  return _titleFromFlatFileName(parts.last);
}

String _titleFromFlatFileName(String fileName) {
  final match =
      RegExp(r'^drama(\d+)_', caseSensitive: false).firstMatch(fileName.trim());
  if (match == null) {
    return '本地短剧';
  }
  return '本地短剧 ${int.tryParse(match.group(1) ?? '') ?? 0}';
}

int _episodeNumber(String fileName) {
  final match = RegExp(
    r'(?:第(\d+)集|_ep(\d+))',
    caseSensitive: false,
  ).firstMatch(fileName);
  if (match == null) {
    return 0;
  }
  return int.tryParse(match.group(1) ?? match.group(2) ?? '') ?? 0;
}

String _stableId(String value) {
  var hash = 0;
  for (final unit in value.codeUnits) {
    hash = 0x1fffffff & (hash * 31 + unit);
  }
  return hash.toRadixString(16);
}

const _palette = <int>[
  0xFF2E5EAA,
  0xFF1F7A65,
  0xFF8B5E34,
  0xFF7C3AED,
  0xFFDC2626,
  0xFF0F766E,
  0xFFB45309,
  0xFF4338CA,
  0xFFBE185D,
  0xFF334155,
];
