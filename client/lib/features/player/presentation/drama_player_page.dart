import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart' hide EffectEntry;
import 'package:video_player/video_player.dart';

import '../../drama/domain/models/drama.dart';
import '../../drama/domain/models/highlight_point.dart';
import '../domain/models/effect_type.dart';
import '../domain/models/gesture_spell.dart';
import 'widgets/effect_layer.dart';
import 'widgets/effects/generic_particle_effect.dart';
import 'widgets/effects/heart_burst_effect.dart';
import 'widgets/effects/heart_particle.dart';
import 'widgets/effects/shockwave_effect.dart';
import 'widgets/effects/text_fly_effect.dart';
import 'widgets/emotion_temperature_overlay.dart';
import 'widgets/gesture_spell_overlay.dart';
import 'widgets/highlight_timeline.dart';
import 'widgets/interaction_overlay.dart';
import 'widgets/side_action_bar.dart';

class DramaPlayerPage extends StatefulWidget {
  const DramaPlayerPage({required this.drama, super.key});

  final Drama drama;

  @override
  State<DramaPlayerPage> createState() => _DramaPlayerPageState();
}

class _DramaPlayerPageState extends State<DramaPlayerPage>
    with WidgetsBindingObserver {
  final _effectLayerKey = GlobalKey<EffectLayerState>();
  final List<String> _branchChoiceHistory = [];

  Timer? _mockTimer;
  Timer? _feedbackTimer;
  Timer? _emotionDecayTimer;
  VideoPlayerController? _videoController;
  var _isPlaying = false;
  var _isVideoReady = false;
  var _videoFailed = false;
  var _resumePlaybackOnForeground = false;
  var _isGestureSpellOpen = false;
  var _position = Duration.zero;
  var _emotionBoost = 0.0;
  String? _handledHighlightId;
  String? _feedbackText;

  bool get _usesAssetVideo => widget.drama.videoUrl.startsWith('assets/');

  bool get _isAssetVideoUnavailable => _usesAssetVideo && !_isVideoReady;

  Duration get _duration {
    final controller = _videoController;
    if (_isVideoReady && controller != null) {
      return controller.value.duration;
    }
    return widget.drama.duration;
  }

  HighlightPoint? get _activeHighlight {
    for (final highlight in widget.drama.highlights) {
      final isInWindow = _position >= highlight.at &&
          _position < highlight.at + const Duration(seconds: 5);
      if (isInWindow && _handledHighlightId != highlight.id) {
        return highlight;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    unawaited(_initializeVideo());
  }

  Future<void> _initializeVideo() async {
    if (!_usesAssetVideo) {
      setState(() => _videoFailed = true);
      return;
    }

    final controller = VideoPlayerController.asset(widget.drama.videoUrl);
    _videoController = controller;
    controller.addListener(_syncVideoState);

    try {
      await controller.initialize();
      if (!mounted) {
        return;
      }
      _mockTimer?.cancel();
      setState(() {
        _isVideoReady = true;
        _isPlaying = controller.value.isPlaying;
        _position = controller.value.position;
      });
    } catch (error, stackTrace) {
      if (error is! UnimplementedError) {
        debugPrint(
          'Video initialization failed for ${widget.drama.videoUrl}: '
          '$error\n$stackTrace',
        );
      }
      if (!mounted) {
        return;
      }
      setState(() => _videoFailed = true);
    }
  }

  void _syncVideoState() {
    final controller = _videoController;
    if (!mounted || controller == null || !controller.value.isInitialized) {
      return;
    }

    final nextPosition = controller.value.position;
    final nextPlaying = controller.value.isPlaying;
    final didComplete = nextPosition >= controller.value.duration &&
        controller.value.duration > Duration.zero;

    if (_position.inMilliseconds != nextPosition.inMilliseconds ||
        _isPlaying != nextPlaying ||
        didComplete) {
      setState(() {
        _position = nextPosition;
        _isPlaying = didComplete ? false : nextPlaying;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mockTimer?.cancel();
    _feedbackTimer?.cancel();
    _emotionDecayTimer?.cancel();
    _videoController?.removeListener(_syncVideoState);
    _videoController?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _videoController;
    if (state == AppLifecycleState.resumed) {
      if (_resumePlaybackOnForeground &&
          controller != null &&
          controller.value.isInitialized) {
        _resumePlaybackOnForeground = false;
        unawaited(controller.play());
      }
      return;
    }

    if ((state == AppLifecycleState.inactive ||
            state == AppLifecycleState.hidden ||
            state == AppLifecycleState.paused) &&
        controller != null &&
        controller.value.isPlaying) {
      _resumePlaybackOnForeground = true;
      unawaited(controller.pause());
    }
  }

  void _togglePlayback() {
    if (_isAssetVideoUnavailable) {
      return;
    }

    final controller = _videoController;
    if (_isVideoReady && controller != null) {
      if (controller.value.isPlaying) {
        _resumePlaybackOnForeground = false;
        unawaited(controller.pause());
      } else {
        if (_position >= controller.value.duration) {
          unawaited(controller.seekTo(Duration.zero));
        }
        unawaited(controller.play());
      }
      return;
    }

    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _mockTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
        setState(() {
          if (_position >= _duration) {
            _isPlaying = false;
            _mockTimer?.cancel();
            return;
          }
          _position += const Duration(milliseconds: 250);
        });
      });
    } else {
      _mockTimer?.cancel();
    }
  }

  void _seek(double seconds) {
    final nextPosition = Duration(milliseconds: (seconds * 1000).round());
    final controller = _videoController;
    if (_isVideoReady && controller != null) {
      unawaited(controller.seekTo(nextPosition));
    }

    _feedbackTimer?.cancel();
    setState(() {
      _position = nextPosition;
      _handledHighlightId = null;
      _feedbackText = null;
    });
  }

  void _dismissHighlight(HighlightPoint highlight) {
    setState(() => _handledHighlightId = highlight.id);
  }

  void _selectOption(HighlightPoint highlight, InteractionOption option) {
    final size = MediaQuery.sizeOf(context);
    final center = Offset(size.width / 2, size.height / 2);

    setState(() {
      _handledHighlightId = highlight.id;
      if (highlight.kind == HighlightKind.branch) {
        _branchChoiceHistory.add('${highlight.id}:${option.id}');
      }
    });

    _showFeedback(
      highlight.kind == HighlightKind.branch
          ? '你选择了「${option.label}」路线'
          : option.effectText,
    );
    _boostEmotion(option.effectType == EffectType.shockwave ? 18 : 12);
    _triggerOptionEffect(option, center);
  }

  void _boostEmotion(double amount) {
    _emotionDecayTimer?.cancel();
    setState(() {
      _emotionBoost = (_emotionBoost + amount).clamp(0.0, 34.0).toDouble();
    });

    _emotionDecayTimer = Timer.periodic(const Duration(milliseconds: 420), (
      timer,
    ) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _emotionBoost = (_emotionBoost - 5).clamp(0.0, 34.0).toDouble();
      });
      if (_emotionBoost <= 0) {
        timer.cancel();
      }
    });
  }

  void _showFeedback(String text) {
    _feedbackTimer?.cancel();
    setState(() => _feedbackText = text);
    _feedbackTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) {
        return;
      }
      setState(() => _feedbackText = null);
    });
  }

  void _onDoubleTap(TapDownDetails details) {
    _effectLayerKey.currentState?.addEffect(
      EffectEntry(
        id: 'heart-burst-${DateTime.now().microsecondsSinceEpoch}',
        duration: const Duration(milliseconds: 900),
        child: HeartBurstEffect(position: details.localPosition),
      ),
    );
    _boostEmotion(7);
  }

  void _onSideLike() {
    final size = MediaQuery.sizeOf(context);
    final position = Offset(size.width - 70, size.height * 0.46);
    _effectLayerKey.currentState?.addEffect(
      EffectEntry(
        id: 'side-like-${DateTime.now().microsecondsSinceEpoch}',
        duration: const Duration(milliseconds: 900),
        child: HeartBurstEffect(position: position),
      ),
    );
    _boostEmotion(9);
  }

  void _onSideComment() {
    _showFeedback('386 人正在表达，评论区热度 +1');
    _boostEmotion(5);
  }

  void _onSideShare() {
    _showFeedback('已生成分享卡片，热度继续发酵');
    _boostEmotion(6);
  }

  void _openGestureSpell() {
    setState(() => _isGestureSpellOpen = true);
    _boostEmotion(4);
  }

  void _closeGestureSpell() {
    setState(() => _isGestureSpellOpen = false);
  }

  void _onGestureRecognized(GestureRecognitionResult result) {
    if (!result.isAccepted) {
      return;
    }

    _showFeedback(result.type.effectText);
    _boostEmotion(
      result.source == GestureRecognitionSource.dotPattern ? 14 : 18,
    );
    _triggerGestureSpellEffect(result);
  }

  void _triggerOptionEffect(InteractionOption option, Offset position) {
    late final Widget child;
    switch (option.effectType) {
      case EffectType.shockwave:
        child = ShockwaveEffect(position: position);
      case EffectType.heart:
        child = HeartParticleEffect(position: position);
      case EffectType.textFly:
        child = TextFlyEffect(
          text: option.effectText,
          position: position.translate(-80, -24),
        );
      case EffectType.tears:
      case EffectType.candy:
      case EffectType.flame:
        child =
            GenericParticleEffect(type: option.effectType, position: position);
    }

    _effectLayerKey.currentState?.addEffect(
      EffectEntry(
        id: 'option-${DateTime.now().microsecondsSinceEpoch}',
        duration: const Duration(milliseconds: 1300),
        child: child,
      ),
    );
  }

  void _triggerGestureSpellEffect(GestureRecognitionResult result) {
    final size = MediaQuery.sizeOf(context);
    final center = Offset(size.width / 2, size.height * 0.45);

    late final Widget child;
    switch (result.type) {
      case GestureSpellType.lightning:
        child = ShockwaveEffect(position: center);
      case GestureSpellType.fire:
        child = GenericParticleEffect(type: EffectType.flame, position: center);
      case GestureSpellType.sword:
        child = TextFlyEffect(
          text: result.type.effectText,
          position: center.translate(-88, -24),
        );
      case GestureSpellType.snowflake:
        child = GenericParticleEffect(type: EffectType.tears, position: center);
      case GestureSpellType.star:
        child = HeartParticleEffect(position: center);
      case GestureSpellType.unknown:
        return;
    }

    _effectLayerKey.currentState?.addEffect(
      EffectEntry(
        id: 'gesture-${DateTime.now().microsecondsSinceEpoch}',
        duration: const Duration(milliseconds: 1300),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final highlight = _activeHighlight;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _VideoStage(
            drama: widget.drama,
            controller: _videoController,
            isVideoReady: _isVideoReady,
            videoFailed: _videoFailed,
            position: _position,
            feedbackText: _feedbackText,
          ),
          EmotionTemperatureOverlay(
            position: _position,
            duration: _duration,
            highlights: widget.drama.highlights,
            userBoost: _emotionBoost,
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onDoubleTapDown: _onDoubleTap,
              onTap: _togglePlayback,
            ),
          ),
          EffectLayer(key: _effectLayerKey),
          if (highlight != null)
            InteractionOverlay(
              highlight: highlight,
              onDismiss: () => _dismissHighlight(highlight),
              onSelect: (option) => _selectOption(highlight, option),
            ),
          _TopBar(title: widget.drama.title),
          _BottomHud(
            drama: widget.drama,
            isPlaying: _isPlaying,
            position: _position,
            duration: _duration,
            highlights: widget.drama.highlights,
            branchChoiceCount: _branchChoiceHistory.length,
            onToggle: _togglePlayback,
            onSeek: _seek,
          ),
          SideActionBar(
            drama: widget.drama,
            onLike: _onSideLike,
            onComment: _onSideComment,
            onShare: _onSideShare,
            onCast: _openGestureSpell,
          ),
          if (_isGestureSpellOpen)
            GestureSpellOverlay(
              onClose: _closeGestureSpell,
              onRecognized: _onGestureRecognized,
            ),
        ],
      ),
    );
  }
}

class _VideoStage extends StatelessWidget {
  const _VideoStage({
    required this.drama,
    required this.controller,
    required this.isVideoReady,
    required this.videoFailed,
    required this.position,
    required this.feedbackText,
  });

  final Drama drama;
  final VideoPlayerController? controller;
  final bool isVideoReady;
  final bool videoFailed;
  final Duration position;
  final String? feedbackText;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;

    return DecoratedBox(
      decoration: const BoxDecoration(color: Colors.black),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isVideoReady && controller != null)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            )
          else
            _MockVideoStage(
              drama: drama,
              position: position,
              isLoading: !videoFailed,
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.54),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.76),
                ],
                stops: const [0, 0.42, 1],
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: feedbackText == null
                ? const SizedBox.shrink()
                : Align(
                    key: ValueKey(feedbackText),
                    alignment: const Alignment(0, -0.22),
                    child: _EffectToast(
                      text: feedbackText!,
                      color: Color(drama.coverColor),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MockVideoStage extends StatelessWidget {
  const _MockVideoStage({
    required this.drama,
    required this.position,
    required this.isLoading,
  });

  final Drama drama;
  final Duration position;
  final bool isLoading;

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
              Icon(Icons.play_circle_outline, color: accent, size: 72),
              const SizedBox(height: 18),
              Text(
                drama.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                isLoading ? '视频加载中...' : 'Mock 舞台 ${_formatDuration(position)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFE5E7EB),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                tooltip: '返回',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
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

class _BottomHud extends StatelessWidget {
  const _BottomHud({
    required this.drama,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.highlights,
    required this.branchChoiceCount,
    required this.onToggle,
    required this.onSeek,
  });

  final Drama drama;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final List<HighlightPoint> highlights;
  final int branchChoiceCount;
  final VoidCallback onToggle;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final maxSeconds = duration.inMilliseconds / 1000;
    final maxSliderValue = maxSeconds <= 0 ? 1.0 : maxSeconds;
    final currentSeconds =
        position.inMilliseconds.clamp(0, duration.inMilliseconds) / 1000;
    final subtitle = '${drama.subtitle} · 第 1/${drama.episodeCount} 集'
        '${branchChoiceCount == 0 ? '' : ' · 已选 $branchChoiceCount 条路线'}';

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                drama.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              HighlightTimeline(
                duration: duration,
                position: position,
                highlights: highlights,
                onJump: (highlight) =>
                    onSeek(highlight.at.inMilliseconds / 1000),
              ),
              Row(
                children: [
                  Tooltip(
                    message: isPlaying ? '暂停' : '播放',
                    child: IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: onToggle,
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    ),
                  ),
                  Text(
                    _formatDuration(position),
                    style: const TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 5,
                        ),
                      ),
                      child: Slider(
                        min: 0,
                        max: maxSliderValue,
                        value:
                            currentSeconds.clamp(0, maxSliderValue).toDouble(),
                        onChanged: onSeek,
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EffectToast extends StatelessWidget {
  const _EffectToast({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 48,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 20),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    )
        .animate(key: ValueKey(text))
        .fadeIn(duration: 160.ms, curve: Curves.easeOut)
        .scaleXY(
          begin: 0.88,
          end: 1,
          duration: 240.ms,
          curve: Curves.easeOutBack,
        )
        .shake(
          delay: 130.ms,
          duration: 220.ms,
          hz: 7,
          offset: const Offset(2, 0),
          rotation: 0.018,
        );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
