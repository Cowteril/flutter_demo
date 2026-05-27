import 'highlight_point.dart';

class Drama {
  const Drama({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.coverColor,
    required this.episodeCount,
    required this.duration,
    required this.videoUrl,
    required this.highlights,
  });

  final String id;
  final String title;
  final String subtitle;
  final int coverColor;
  final int episodeCount;
  final Duration duration;
  final String videoUrl;
  final List<HighlightPoint> highlights;
}
