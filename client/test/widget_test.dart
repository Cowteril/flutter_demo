import 'dart:convert';

import 'package:duanju_client/app/duanju_app.dart';
import 'package:duanju_client/features/drama/data/local_video_asset_catalog.dart';
import 'package:duanju_client/features/drama/data/mock_drama_repository.dart';
import 'package:duanju_client/features/drama/domain/models/drama.dart';
import 'package:duanju_client/features/drama/domain/models/highlight_point.dart';
import 'package:duanju_client/features/feed/presentation/drama_feed_page.dart';
import 'package:duanju_client/features/player/domain/gesture_classifier.dart';
import 'package:duanju_client/features/player/domain/models/effect_type.dart';
import 'package:duanju_client/features/player/domain/models/gesture_spell.dart';
import 'package:duanju_client/features/player/presentation/drama_player_page.dart';
import 'package:duanju_client/features/player/presentation/widgets/interaction_overlay.dart';
import 'package:duanju_client/features/profile/domain/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows v0.3 feed shell', (tester) async {
    await tester.pumpWidget(const DuanjuApp());
    await tester.pump();
    for (var i = 0; i < 12 && find.byType(PageView).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(PageView), findsOneWidget);
    expect(find.byType(DramaPlayerPage), findsOneWidget);
  });

  testWidgets('falls back to mock feed when local videos are unavailable',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DramaFeedPage(
          repository: MockDramaRepository(),
          localCatalog: const _UnavailableLocalVideoCatalog(),
        ),
      ),
    );
    await tester.pump();
    for (var i = 0; i < 12 && find.text('Mock · 1/3').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(PageView), findsOneWidget);
    expect(find.text('Mock · 1/3'), findsOneWidget);
    expect(find.text('推荐'), findsOneWidget);
    expect(find.text('互动'), findsOneWidget);
    expect(find.text('追剧'), findsOneWidget);
  });

  testWidgets('feed chrome updates when swiping to the next drama',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DramaFeedPage(
          repository: MockDramaRepository(),
          localCatalog: const _UnavailableLocalVideoCatalog(),
        ),
      ),
    );
    await tester.pump();
    for (var i = 0; i < 12 && find.text('Mock · 1/3').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.drag(find.byType(PageView), const Offset(0, -600));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Mock · 2/3'), findsOneWidget);
  });

  testWidgets('profile page opens from feed chrome', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DramaFeedPage(
          repository: MockDramaRepository(),
          localCatalog: const _UnavailableLocalVideoCatalog(),
        ),
      ),
    );
    await tester.pump();
    for (var i = 0;
        i < 12 && find.byIcon(Icons.person_outline).evaluate().isEmpty;
        i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('个人主页'), findsOneWidget);
    expect(find.text('成就徽章'), findsOneWidget);
    expect(find.text('喜欢的角色'), findsOneWidget);
  });

  testWidgets('feed constrains the playback viewport on wide screens',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: DramaFeedPage(
          repository: MockDramaRepository(),
          localCatalog: const _UnavailableLocalVideoCatalog(),
        ),
      ),
    );
    await tester.pump();
    for (var i = 0; i < 12 && find.byType(PageView).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    final pageViewSize = tester.getSize(find.byType(PageView));

    expect(pageViewSize.width, closeTo(450, 0.1));
    expect(pageViewSize.height, 800);
  });

  test('local video catalog builds dramas from asset paths', () {
    const catalog = LocalVideoAssetCatalog();

    final dramas = catalog.dramasFromAssetPaths([
      'assets/local_videos/北往/第2集.mp4',
      'assets/local_videos/北往/第1集.mp4',
      'assets/local_videos/那年冬至/第10集.mp4',
      'assets/videos/test_video_20s.mp4',
    ]);

    expect(dramas, hasLength(3));
    expect(dramas.first.title, '北往');
    expect(dramas.first.videoUrl, 'assets/local_videos/北往/第1集.mp4');
    expect(dramas.first.episodeCount, 2);
    expect(dramas.last.title, '那年冬至');
  });

  test('local video catalog uses local catalog metadata for flat assets', () {
    const catalog = LocalVideoAssetCatalog();

    final dramas = catalog.dramasFromCatalogEntries([
      {
        'asset': 'assets/local_videos/drama01_ep023.mp4',
        'title': '云渺1：我修仙多年强亿点怎么了',
        'episodeNumber': 23,
      },
      {
        'asset': 'assets/local_videos/drama02_ep018.mp4',
        'title': '北往',
        'episodeNumber': 18,
      },
      {
        'asset': 'assets/videos/test_video_20s.mp4',
        'title': '忽略项',
        'episodeNumber': 1,
      },
    ]);

    expect(dramas, hasLength(2));
    final north = dramas.firstWhere((drama) => drama.title == '北往');
    final xiuxian =
        dramas.firstWhere((drama) => drama.title == '云渺1：我修仙多年强亿点怎么了');
    expect(north.videoUrl, 'assets/local_videos/drama02_ep018.mp4');
    expect(xiuxian.episodeCount, 23);
  });

  test('local video catalog ignores stale catalog entries', () {
    const catalog = LocalVideoAssetCatalog();

    final dramas = catalog.dramasFromCatalogEntries(
      [
        {
          'asset': 'assets/local_videos/drama01_ep023.mp4',
          'title': '已删除视频',
          'episodeNumber': 23,
        },
        {
          'asset': 'assets/local_videos/drama02_ep018.mp4',
          'title': '北往',
          'episodeNumber': 18,
        },
      ],
      availableAssetPaths: {'assets/local_videos/drama02_ep018.mp4'},
    );

    expect(dramas, hasLength(1));
    expect(dramas.single.title, '北往');
  });

  testWidgets(
      'prediction choice is recorded as pending without revealing answer',
      (tester) async {
    final profileController = ProfileController();
    addTearDown(profileController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: DramaPlayerPage(
          drama: _predictionTestDrama,
          profileController: profileController,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('预测1'));
    await tester.pump();

    expect(profileController.predictions, hasLength(1));
    expect(profileController.predictions.single.optionLabel, '预测1');
    expect(profileController.predictions.single.status, '待开奖');
    expect(find.text('预测已锁定，开奖后若命中自动发放徽章'), findsWidgets);

    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('prediction is disabled after seeking past its trigger time',
      (tester) async {
    final profileController = ProfileController();
    addTearDown(profileController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: DramaPlayerPage(
          drama: _seekPredictionTestDrama,
          profileController: profileController,
        ),
      ),
    );
    await tester.pump();

    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged?.call(4);
    await tester.pump();

    expect(find.textContaining('提前跳到预测点之后'), findsOneWidget);
    expect(find.text('预测1'), findsNothing);
    await tester.tap(find.text('知道了'));
    await tester.pump(const Duration(milliseconds: 350));
  });

  testWidgets('prediction is disabled after watching past its answer window',
      (tester) async {
    final profileController = ProfileController();
    addTearDown(profileController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: DramaPlayerPage(
          drama: _seekPredictionTestDrama,
          autoPlay: true,
          profileController: profileController,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 9));

    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged?.call(4);
    await tester.pump();

    expect(find.textContaining('看过预测点之后的剧情'), findsOneWidget);
    expect(find.text('预测1'), findsNothing);
    await tester.tap(find.text('知道了'));
    await tester.pump(const Duration(milliseconds: 350));
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

  testWidgets('highlight interaction hides bottom controls while open',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DramaPlayerPage(drama: _feedbackTestDrama)),
    );
    await tester.pump();

    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(Slider), findsNothing);
    final playerStack = tester.widget<Stack>(
      find.ancestor(
        of: find.byType(InteractionOverlay),
        matching: find.byType(Stack),
      ),
    );
    expect(playerStack.children.last, isA<InteractionOverlay>());

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(Slider), findsOneWidget);

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

  testWidgets('inactive feed player does not advance mock playback',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DramaPlayerPage(
          drama: _mockLifecycleTestDrama,
          isActive: false,
          autoPlay: true,
        ),
      ),
    );
    await tester.pump();

    await tester.tapAt(const Offset(200, 200));
    await tester.pump(const Duration(seconds: 1));

    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.value, 0);
    expect(find.text('Mock 舞台 00:01'), findsNothing);
  });

  testWidgets('active feed player auto advances mock playback', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DramaPlayerPage(
          drama: _mockLifecycleTestDrama,
          autoPlay: true,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.value, greaterThan(0));
  });

  testWidgets('v0.2 shell shows emotion telemetry and side actions',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DramaPlayerPage(drama: _sideActionTestDrama)),
    );
    await tester.pump();

    expect(find.text('情绪温度'), findsOneWidget);
    expect(find.textContaining('人在看'), findsOneWidget);
    expect(find.byIcon(Icons.mode_comment_outlined), findsOneWidget);
    expect(find.byIcon(Icons.ios_share), findsOneWidget);

    await tester.tap(find.byIcon(Icons.mode_comment_outlined));
    await tester.pump();

    expect(find.text('386 人正在表达，评论区热度 +1'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('character favorability sheet supports like and gift',
      (tester) async {
    final profileController = ProfileController();
    addTearDown(profileController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: DramaPlayerPage(
          drama: _sideActionTestDrama,
          profileController: profileController,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.groups_2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('点赞 +16'), findsOneWidget);
    expect(find.text('送礼 +28'), findsOneWidget);

    await tester.tap(find.text('点赞 +16'));
    await tester.pump();
    await tester.tap(find.text('送礼 +28'));
    await tester.pump();

    expect(profileController.favoriteCharacters, hasLength(1));
    expect(profileController.favoriteCharacters.single.liked, isTrue);
    expect(profileController.favoriteCharacters.single.gifts, 1);
  });

  testWidgets('gesture classifier assets are bundled', (tester) async {
    final model = await rootBundle.load(
      'assets/models/gesture_classifier.tflite',
    );
    final labelBytes = await rootBundle.load(
      'assets/models/gesture_labels.json',
    );
    final labels = jsonDecode(
      utf8.decode(labelBytes.buffer.asUint8List()),
    ) as Map<String, dynamic>;

    expect(model.lengthInBytes, greaterThan(100000));
    expect(model.lengthInBytes, lessThan(5 * 1024 * 1024));
    expect(
      labels.values,
      containsAll(['lightning', 'fire', 'sword', 'snowflake', 'star']),
    );
  });

  test('dot pattern fallback recognizes a sword spell', () {
    const classifier = DotPatternGestureClassifier();

    final result = classifier.classify([1, 5, 9]);

    expect(result.type, GestureSpellType.sword);
    expect(result.confidence, 1);
    expect(result.source, GestureRecognitionSource.dotPattern);
  });

  testWidgets('gesture spell overlay opens from side action', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DramaPlayerPage(drama: _sideActionTestDrama)),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.auto_fix_high));
    await tester.pump();

    expect(find.text('AI 施法识别'), findsOneWidget);
    expect(find.text('画闪电、火焰、剑、雪花或星星'), findsOneWidget);
    expect(find.byIcon(Icons.mode_comment_outlined), findsNothing);
    expect(find.text('情绪温度'), findsNothing);
    expect(find.byType(Slider), findsNothing);
  });
}

const _predictionTestDrama = Drama(
  id: 'prediction-test',
  title: '预测测试剧',
  subtitle: '验证预测竞猜记录不会剧透',
  coverColor: 0xFF2E5EAA,
  episodeCount: 1,
  duration: Duration(seconds: 20),
  videoUrl: 'mock://prediction-test',
  highlights: [
    HighlightPoint(
      id: 'prediction',
      at: Duration.zero,
      title: '剧情预测竞猜',
      description: '关键剧情前先锁定判断，奖励延后开奖。',
      kind: HighlightKind.prediction,
      options: [
        InteractionOption(
          id: 'predict-1',
          label: '预测1',
          effectText: '预测已锁定，开奖后若命中自动发放徽章',
          effectType: EffectType.textFly,
        ),
        InteractionOption(
          id: 'predict-2',
          label: '预测2',
          effectText: '预测已锁定，开奖后若命中自动发放徽章',
          effectType: EffectType.shockwave,
        ),
      ],
    ),
  ],
);

const _seekPredictionTestDrama = Drama(
  id: 'prediction-seek-test',
  title: '预测跳转测试剧',
  subtitle: '验证跳过预测点后不能参与',
  coverColor: 0xFF1F7A65,
  episodeCount: 1,
  duration: Duration(seconds: 20),
  videoUrl: 'mock://prediction-seek-test',
  highlights: [
    HighlightPoint(
      id: 'prediction',
      at: Duration(seconds: 3),
      title: '剧情预测竞猜',
      description: '跳到本节点之后将失去预测资格。',
      kind: HighlightKind.prediction,
      options: [
        InteractionOption(
          id: 'predict-1',
          label: '预测1',
          effectText: '预测已锁定，开奖后若命中自动发放徽章',
          effectType: EffectType.textFly,
        ),
        InteractionOption(
          id: 'predict-2',
          label: '预测2',
          effectText: '预测已锁定，开奖后若命中自动发放徽章',
          effectType: EffectType.shockwave,
        ),
      ],
    ),
  ],
);

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

const _sideActionTestDrama = Drama(
  id: 'side-action-test',
  title: '短剧产品壳测试',
  subtitle: '验证右侧操作栏和情绪温度计',
  coverColor: 0xFF1F7A65,
  episodeCount: 12,
  duration: Duration(seconds: 20),
  videoUrl: 'mock://side-action-test',
  highlights: [],
);

const _mockLifecycleTestDrama = Drama(
  id: 'mock-lifecycle-test',
  title: '生命周期测试剧',
  subtitle: '验证 Feed 当前页播放控制',
  coverColor: 0xFF334155,
  episodeCount: 1,
  duration: Duration(seconds: 20),
  videoUrl: 'mock://lifecycle',
  highlights: [],
);

class _UnavailableLocalVideoCatalog extends LocalVideoAssetCatalog {
  const _UnavailableLocalVideoCatalog();

  @override
  Future<List<Drama>> loadDramas() async {
    throw StateError('local videos unavailable in this test');
  }
}
