import '../domain/models/drama.dart';
import '../domain/models/highlight_point.dart';
import '../../player/domain/models/effect_type.dart';
import 'drama_repository.dart';

class MockDramaRepository implements DramaRepository {
  final List<Drama> _dramas = const [
    Drama(
      id: 'north-treasure',
      title: '北派寻宝笔记',
      subtitle: '密室反转不断，适合做爽点互动',
      coverColor: 0xFF2E5EAA,
      episodeCount: 24,
      duration: Duration(seconds: 20),
      videoUrl: 'assets/videos/test_video_20s.mp4',
      highlights: [
        HighlightPoint(
          id: 'h1',
          at: Duration(seconds: 5),
          title: '线索突然反转',
          description: '主角发现藏宝图并不完整，弹出即时情绪互动。',
          kind: HighlightKind.reaction,
          options: [
            InteractionOption(
              id: 'cool',
              label: '爽',
              effectText: '全屏冲击波 + 热度计上涨',
              effectType: EffectType.shockwave,
            ),
            InteractionOption(
              id: 'shock',
              label: '反转了',
              effectText: '弹出反转徽章并加入同屏互动计数',
              effectType: EffectType.textFly,
            ),
          ],
        ),
        HighlightPoint(
          id: 'h2',
          at: Duration(seconds: 12),
          title: '选择追击路线',
          description: '剧情进入分支点，用户选择不同路线。',
          kind: HighlightKind.branch,
          options: [
            InteractionOption(
              id: 'tunnel',
              label: '走暗道',
              effectText: '预加载暗道分支片段',
              effectType: EffectType.flame,
            ),
            InteractionOption(
              id: 'front',
              label: '正面硬刚',
              effectText: '请求生成正面对峙扩展片段',
              effectType: EffectType.shockwave,
            ),
          ],
        ),
      ],
    ),
    Drama(
      id: 'winter-day',
      title: '那年冬至',
      subtitle: '情绪拉满，适合做弹幕替代表达',
      coverColor: 0xFF8B5E34,
      episodeCount: 18,
      duration: Duration(seconds: 20),
      videoUrl: 'assets/videos/test_video_20s.mp4',
      highlights: [
        HighlightPoint(
          id: 'h3',
          at: Duration(seconds: 7),
          title: '误会终于解开',
          description: '用户无需打字即可表达情绪。',
          kind: HighlightKind.reaction,
          options: [
            InteractionOption(
              id: 'cry',
              label: '破防',
              effectText: '触发泪滴粒子和情绪云图',
              effectType: EffectType.tears,
            ),
            InteractionOption(
              id: 'sweet',
              label: '撒糖',
              effectText: '触发糖果飘落和同屏人数',
              effectType: EffectType.candy,
            ),
          ],
        ),
      ],
    ),
    Drama(
      id: 'xiuxian',
      title: '云岚1：我修仙多年，强一点怎么了？',
      subtitle: '战力爆发点密集，适合做加速包和爽点按钮',
      coverColor: 0xFF1F7A65,
      episodeCount: 30,
      duration: Duration(seconds: 20),
      videoUrl: 'assets/videos/test_video_20s.mp4',
      highlights: [
        HighlightPoint(
          id: 'h4',
          at: Duration(seconds: 10),
          title: '战力爆发',
          description: '插入 AIGC 式加速包或技能扩展内容。',
          kind: HighlightKind.extension,
          options: [
            InteractionOption(
              id: 'boost',
              label: '加速包',
              effectText: '请求生成加速战斗片段',
              effectType: EffectType.flame,
            ),
            InteractionOption(
              id: 'combo',
              label: '连招',
              effectText: '展示连续技可视化',
              effectType: EffectType.heart,
            ),
          ],
        ),
      ],
    ),
  ];

  @override
  Future<List<Drama>> listDramas() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _dramas;
  }

  @override
  Future<Drama?> findDrama(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    for (final drama in _dramas) {
      if (drama.id == id) {
        return drama;
      }
    }
    return null;
  }
}
