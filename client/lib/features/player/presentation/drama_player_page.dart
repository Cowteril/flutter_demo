import 'dart:async';

import 'package:flutter/material.dart';

import '../../drama/domain/models/drama.dart';
import '../../drama/domain/models/highlight_point.dart';
import 'widgets/interaction_overlay.dart';

class DramaPlayerPage extends StatefulWidget {
  const DramaPlayerPage({required this.drama, super.key});

  final Drama drama;

  @override
  State<DramaPlayerPage> createState() => _DramaPlayerPageState();
}

class _DramaPlayerPageState extends State<DramaPlayerPage> {
  Timer? _timer;
  var _isPlaying = false;
  var _position = Duration.zero;
  String? _handledHighlightId;
  String? _latestEffect;

  HighlightPoint? get _activeHighlight {
    for (final highlight in widget.drama.highlights) {
      final isInWindow = _position >= highlight.at &&
          _position < highlight.at + const Duration(seconds: 18);
      if (isInWindow && _handledHighlightId != highlight.id) {
        return highlight;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() => _isPlaying = !_isPlaying);

    if (_isPlaying) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          if (_position >= widget.drama.duration) {
            _isPlaying = false;
            _timer?.cancel();
            return;
          }
          _position += const Duration(seconds: 1);
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  void _seek(double seconds) {
    setState(() {
      _position = Duration(seconds: seconds.round());
      _handledHighlightId = null;
      _latestEffect = null;
    });
  }

  void _selectOption(HighlightPoint highlight, InteractionOption option) {
    setState(() {
      _handledHighlightId = highlight.id;
      _latestEffect = option.effectText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final highlight = _activeHighlight;

    return Scaffold(
      appBar: AppBar(title: Text(widget.drama.title)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _MockVideoStage(
                    drama: widget.drama,
                    position: _position,
                    effectText: _latestEffect,
                  ),
                  if (highlight != null)
                    InteractionOverlay(
                      highlight: highlight,
                      onDismiss: () {
                        setState(() => _handledHighlightId = highlight.id);
                      },
                      onSelect: (option) => _selectOption(highlight, option),
                    ),
                ],
              ),
            ),
            _PlayerControls(
              isPlaying: _isPlaying,
              position: _position,
              duration: widget.drama.duration,
              onToggle: _togglePlayback,
              onSeek: _seek,
            ),
            _HighlightTimeline(
              duration: widget.drama.duration,
              highlights: widget.drama.highlights,
              onJump: (highlight) => _seek(highlight.at.inSeconds.toDouble()),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockVideoStage extends StatelessWidget {
  const _MockVideoStage({
    required this.drama,
    required this.position,
    required this.effectText,
  });

  final Drama drama;
  final Duration position;
  final String? effectText;

  @override
  Widget build(BuildContext context) {
    final accent = Color(drama.coverColor);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: accent, width: 4)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle_outline, color: accent, size: 64),
              const SizedBox(height: 16),
              Text(
                drama.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                _formatDuration(position),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFE5E7EB),
                    ),
              ),
              if (effectText != null) ...[
                const SizedBox(height: 22),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Text(
                      effectText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerControls extends StatelessWidget {
  const _PlayerControls({
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onToggle,
    required this.onSeek,
  });

  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final VoidCallback onToggle;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Tooltip(
            message: isPlaying ? '暂停' : '播放',
            child: IconButton.filled(
              onPressed: onToggle,
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            ),
          ),
          Text(_formatDuration(position)),
          Expanded(
            child: Slider(
              min: 0,
              max: duration.inSeconds.toDouble(),
              value: position.inSeconds.clamp(0, duration.inSeconds).toDouble(),
              onChanged: onSeek,
            ),
          ),
          Text(_formatDuration(duration)),
        ],
      ),
    );
  }
}

class _HighlightTimeline extends StatelessWidget {
  const _HighlightTimeline({
    required this.duration,
    required this.highlights,
    required this.onJump,
  });

  final Duration duration;
  final List<HighlightPoint> highlights;
  final ValueChanged<HighlightPoint> onJump;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        scrollDirection: Axis.horizontal,
        itemCount: highlights.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final highlight = highlights[index];

          return OutlinedButton.icon(
            onPressed: () => onJump(highlight),
            icon: const Icon(Icons.bolt_outlined, size: 18),
            label: Text('${_formatDuration(highlight.at)} ${highlight.title}'),
          );
        },
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
