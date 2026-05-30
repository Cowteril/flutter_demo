import 'package:duanju_client/app/duanju_app.dart';
import 'package:duanju_client/features/drama/domain/models/drama.dart';
import 'package:duanju_client/features/drama/domain/models/highlight_point.dart';
import 'package:duanju_client/features/player/domain/models/effect_type.dart';
import 'package:duanju_client/features/player/presentation/drama_player_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows readable drama list copy', (tester) async {
    await tester.pumpWidget(const DuanjuApp());
    await tester.pumpAndSettle();

    expect(find.text('短剧互动客户端'), findsOneWidget);
    expect(find.text('北派寻宝笔记'), findsOneWidget);
    expect(find.text('24 集'), findsOneWidget);
    expect(find.text('2 个高光'), findsOneWidget);
  });

  testWidgets('branch route feedback does not override later effect feedback',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DramaPlayerPage(drama: _feedbackTestDrama)),
    );
    await tester.pump();

    await tester.tap(find.text('走暗道'));
    await tester.pump();

    expect(find.text('你选择了「走暗道」路线'), findsOneWidget);

    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged?.call(6);
    await tester.pump();

    await tester.tap(find.text('反转了'));
    await tester.pump();

    expect(find.text('你选择了「走暗道」路线'), findsNothing);
    expect(find.text('弹出反转徽章并加入同屏互动计数'), findsWidgets);

    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('tap during asset video loading does not start fallback timer',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DramaPlayerPage(drama: _assetLoadingTestDrama)),
    );
    await tester.pump();

    await tester.tapAt(const Offset(200, 200));
    await tester.pump(const Duration(seconds: 1));

    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.value, 0);
    expect(find.text('Mock 舞台 00:01'), findsNothing);
  });
}

const _feedbackTestDrama = Drama(
  id: 'feedback-test',
  title: '反馈测试剧',
  subtitle: '验证分支和普通特效反馈',
  coverColor: 0xFF2E5EAA,
  episodeCount: 1,
  duration: Duration(seconds: 20),
  videoUrl: 'mock://feedback-test',
  highlights: [
    HighlightPoint(
      id: 'branch',
      at: Duration.zero,
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
      ],
    ),
    HighlightPoint(
      id: 'reaction',
      at: Duration(seconds: 6),
      title: '线索突然反转',
      description: '主角发现藏宝图并不完整，弹出即时情绪互动。',
      kind: HighlightKind.reaction,
      options: [
        InteractionOption(
          id: 'shock',
          label: '反转了',
          effectText: '弹出反转徽章并加入同屏互动计数',
          effectType: EffectType.textFly,
        ),
      ],
    ),
  ],
);

const _assetLoadingTestDrama = Drama(
  id: 'asset-loading-test',
  title: '加载测试剧',
  subtitle: '验证真实视频加载期间的点击',
  coverColor: 0xFF2E5EAA,
  episodeCount: 1,
  duration: Duration(seconds: 20),
  videoUrl: 'assets/videos/test_video_20s.mp4',
  highlights: [],
);
