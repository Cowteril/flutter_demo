# Android短剧互动Demo实现计划 v0.1

## Context（背景）

本项目旨在开发一个短剧互动应用的Android demo，核心目标是：
1. **展示创意互动功能**：基于`docs/frontend_creative_ideas.yaml`中定义的27个创意点，选择最适合demo展示的功能
2. **参考红果短剧APP体验**：前端UI设计参考主流短剧APP的沉浸式体验（**不复制具体视觉资产和品牌设计**）
3. **后端缺失情况下的demo方案**：使用mock数据和本地特效，但功能必须完整可用
4. **Android优先**：先完成Android端，使用Flutter框架
5. **真实视频播放**：从现有的mock播放器升级到真实视频播放，包含播放、暂停、进度控制等基础功能
6. **创意特效可见**：不能只有文字描述，必须有实际的视觉特效展示

现有基础：
- Flutter项目框架已搭建（client目录）
- 已实现短剧列表页面（DramaListPage）
- 已实现mock播放器（DramaPlayerPage）
- 已实现高光互动弹层（InteractionOverlay）
- 数据模型已定义（Drama、HighlightPoint、InteractionOption）

---

## 版本规划

### Demo v0.1（本计划）：核心播放器 + 基础互动特效
**目标**：快速验证核心互动体验，聚焦单个播放器的完整互动链路

**包含功能**：
1. ✅ 真实视频播放
2. ✅ 沉浸式播放器UI
3. ✅ 双击爱心爆炸
4. ✅ 高光触发条
5. ✅ 情绪粒子预设（6种）
6. ✅ 分支选择反馈

**不包含**（留给v0.2）：
- ❌ 竖滑Feed（先做好单个播放器）
- ❌ 情绪热力图（需要更多mock数据）
- ❌ 多指连击（v0.2增强互动）
- ❌ 画手势施法（v0.2增强互动）
- ❌ 摇一摇加油（v0.2体感互动）
- ❌ 右侧操作栏（v0.2 HUD完善）

### Demo v0.2（后续）：高级互动 + Feed体验
- 竖滑Feed
- 情绪热力图
- 多指连击
- 画手势施法（圆形、直线、Z字，**不做心形**）
- 摇一摇加油
- 右侧操作栏

---

## 实现方案（v0.1）

### 一、核心功能升级

#### 1. 真实视频播放器实现
**目标**：将mock播放器升级为真实视频播放器

**技术方案**：
- 使用`video_player`包（Flutter官方视频播放插件）
- **准备轻量测试视频**：15-30秒竖屏短视频（避免仓库体积膨胀）
- 视频存放位置：`client/assets/videos/`
- 使用`flutter pub add`命令添加依赖（不写死版本号）

**关键文件修改**：
- `client/pubspec.yaml`：添加assets配置
- `client/lib/features/player/presentation/drama_player_page.dart`：
  - 替换`_MockVideoStage`为`_RealVideoPlayer`
  - 集成`VideoPlayerController`
  - 同步视频进度与高光点触发逻辑
  - 保持现有的播放/暂停/进度条控制

**数据准备**：
- **方案A（推荐）**：使用FFmpeg生成15-30秒测试视频
  ```bash
  # 生成带时间戳的测试视频（竖屏9:16）
  ffmpeg -f lavfi -i color=c=0x2E5EAA:s=1080x1920:d=20 \
    -vf "drawtext=text='%{pts\:hms}':fontsize=120:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2" \
    -c:v libx264 -pix_fmt yuv420p north_treasure_ep01.mp4
  ```
- **方案B**：从Pexels下载免费竖屏短视频（注意版权）
- 更新`mock_drama_repository.dart`中的视频URL指向本地assets
- 确保高光点时间与视频内容对应（如10秒、15秒处）

#### 2. 沉浸式播放器UI优化
**目标**：打造全屏沉浸式观剧体验

**实现方式**：
- 隐藏系统状态栏和导航栏（使用`SystemChrome.setEnabledSystemUIMode`）
- **重要**：退出播放器页面时恢复系统UI（在`dispose()`中调用`SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)`）
- 视频占据全屏，控件半透明悬浮
- 使用深色主题，减少UI干扰
- 底部信息栏：短剧标题、副标题、集数（半透明背景）

**修改文件**：
- `client/lib/features/player/presentation/drama_player_page.dart`：添加全屏模式和恢复逻辑
- `client/lib/core/theme/app_theme.dart`：优化深色主题配色

---

### 二、创意互动功能实现（v0.1核心功能）

#### 1. 双击爱心爆炸（double_tap_heart_burst）
**优先级**：P0 | **难度**：S | **权限**：无

**实现方式**：
- 在视频区域添加`GestureDetector`捕获`onDoubleTapDown`
- 记录点击坐标，在effect_layer显示爱心动画
- 使用`AnimatedWidget`或`CustomPainter`绘制爱心
- 粒子扩散效果使用`Transform.scale`和`Opacity`动画
- 动画结束后自动移除widget

**新增文件**：
- `client/lib/features/player/presentation/widgets/effect_layer.dart`：特效层容器
- `client/lib/features/player/presentation/widgets/effects/heart_burst_effect.dart`：爱心爆炸特效

**技术细节**：
```dart
// 爱心爆炸动画
- 初始scale: 0.5, 最终scale: 2.0
- 初始opacity: 1.0, 最终opacity: 0.0
- 持续时间: 800ms
- 同时生成5-8个粒子向四周扩散
```

#### 2. 剧情高光触发条（highlight_effect_trigger_bar）
**优先级**：P0 | **难度**：M | **权限**：无

**实现方式**：
- 升级现有的`_HighlightTimeline`组件
- 在进度条上方叠加高光点标记
- 不同类型高光点使用不同颜色/图标
  - reaction: 橙色火焰图标 🔥
  - branch: 紫色分支图标 🌿
  - extension: 金色星星图标 ⭐
- 播放到高光点时自动触发InteractionOverlay
- 添加高光点脉动动画提示

**修改文件**：
- `client/lib/features/player/presentation/drama_player_page.dart`：增强高光触发逻辑

**新增文件**：
- `client/lib/features/player/presentation/widgets/highlight_timeline.dart`：独立的时间轴组件

#### 3. 情绪粒子预设（reaction_particle_presets）
**优先级**：P0 | **难度**：M | **权限**：无

**实现方式**：
- 定义6种基础特效类型枚举（为扩展预留）
- **v0.1优先实现3种高质量特效**：
  - `shockwave`：冲击波扩散（白色闪光）- 最有冲击力
  - `heart`：爱心飘浮（粉色）- 最常用
  - `text_fly`：文字飞出（自定义颜色）- 最灵活
- **v0.1用通用粒子组件实现另外3种**（换颜色/方向）：
  - `tears`：泪滴下落（蓝色）- 复用通用粒子，向下运动
  - `candy`：糖果飘落（彩色）- 复用通用粒子，随机颜色
  - `flame`：火焰上升（橙红色）- 复用通用粒子，向上运动
- 用户选择InteractionOption后触发对应特效
- 使用`CustomPainter`绘制粒子
- 使用`AnimationController`控制粒子运动

**新增文件**：
- `client/lib/features/player/domain/models/effect_type.dart`：特效类型枚举（6种）
- `client/lib/features/player/presentation/widgets/effects/particle_effect.dart`：粒子特效基类
- `client/lib/features/player/presentation/widgets/effects/shockwave_effect.dart`：冲击波特效（高质量）
- `client/lib/features/player/presentation/widgets/effects/heart_particle.dart`：爱心特效（高质量）
- `client/lib/features/player/presentation/widgets/effects/text_fly_effect.dart`：文字飞出特效（高质量）
- `client/lib/features/player/presentation/widgets/effects/generic_particle_effect.dart`：通用粒子特效（支持tears/candy/flame）

**数据关联**：
- 更新`InteractionOption`模型，添加`effectType`字段
- 更新mock数据，为每个选项指定特效类型

#### 4. 剧情分支选择反馈（branch_choice_moment）
**优先级**：P0 | **难度**：S | **权限**：无

**实现方式**：
- 复用现有`InteractionOverlay`展示分支选项
- 选择后播放对应反馈特效
- 记录选择的分支ID（暂不跳转到分支视频）
- 显示"你选择了XX路线"的反馈动画
- 在播放器状态中保存分支选择历史

**修改文件**：
- `client/lib/features/player/presentation/drama_player_page.dart`：添加分支选择状态管理
- `client/lib/features/player/presentation/widgets/interaction_overlay.dart`：增强分支选择UI

**Mock数据**：
- 已有数据中包含branch类型的高光点，直接使用

---

### 三、项目结构调整（v0.1）

#### 新增目录结构
```
client/lib/
├── features/
│   ├── player/
│   │   ├── domain/
│   │   │   └── models/
│   │   │       └── effect_type.dart          # 新增
│   │   ├── presentation/
│   │   │   ├── drama_player_page.dart        # 修改
│   │   │   └── widgets/
│   │   │       ├── effect_layer.dart         # 新增
│   │   │       ├── highlight_timeline.dart   # 新增
│   │   │       ├── interaction_overlay.dart  # 修改
│   │   │       └── effects/                  # 新增：特效组件目录
│   │   │           ├── particle_effect.dart
│   │   │           ├── heart_burst_effect.dart
│   │   │           ├── heart_particle.dart
│   │   │           ├── shockwave_effect.dart
│   │   │           ├── tears_effect.dart
│   │   │           ├── candy_effect.dart
│   │   │           ├── flame_effect.dart
│   │   │           └── text_fly_effect.dart
│   ├── drama/
│   │   ├── data/
│   │   │   └── mock_drama_repository.dart    # 修改：添加effectType
│   │   └── domain/
│   │       └── models/
│   │           └── highlight_point.dart      # 修改：添加effectType
├── assets/                                    # 新增
│   └── videos/                                # 新增：视频资源
│       ├── test_video_20s.mp4                # 轻量测试视频
```

#### 依赖更新（pubspec.yaml）
**不要写死版本号，使用flutter pub add命令**：
```bash
cd client
flutter pub add video_player
```

**assets配置**：
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/videos/
```

---

### 四、实现步骤（v0.1按顺序）

**调整后的实施顺序**（避免被视频依赖拖住）：

#### 阶段1：统一Stack结构 + Mock舞台（0.5天）
1. 重构`DramaPlayerPage`，建立统一的Stack层次结构
2. 保持Mock视频舞台可用
3. 为后续视频播放器和特效层预留位置
4. 测试现有功能不受影响

#### 阶段2：特效系统 + 双击爱心（1天）
1. 创建`effect_type.dart`枚举定义（6种）
2. 创建`effect_layer.dart`特效层容器（使用GlobalKey模式）
3. 实现`particle_effect.dart`粒子特效基类
4. 实现双击爱心爆炸功能
5. **在Mock舞台上测试特效**（不依赖真实视频）

#### 阶段3：真实视频播放器（1天）
1. 使用`flutter pub add video_player`添加依赖
2. 生成或下载1个15-30秒测试视频，放入assets目录
3. 实现真实视频播放器，替换mock播放器
4. 测试视频播放、暂停、进度控制功能
5. 确保高光点触发逻辑与视频进度同步

#### 阶段4：InteractionOption -> EffectType（1天）
1. 更新`InteractionOption`模型，添加`effectType`字段
2. 实现3种高质量特效（shockwave, heart, text_fly）
3. 实现通用粒子组件（支持tears/candy/flame）
4. 更新mock数据，为每个选项指定特效类型
5. 测试每种特效的显示效果

#### 阶段5：高光触发条 + 分支反馈（1天）
1. 升级高光触发条，添加可视化标记
2. 实现高光点脉动动画
3. 实现分支选择反馈动画
4. 测试高光点触发和互动流程

#### 阶段6：沉浸式UI + APK测试（0.5-1天）
1. 实现全屏沉浸式UI（进入时隐藏系统栏，退出时恢复）
2. 优化底部信息栏样式
3. 端到端测试所有功能
4. 修复bug和优化性能
5. 构建APK并在真机测试

**总计：5-6天**

**优势**：即使video_player或视频资源临时卡住，特效系统也能先在mock舞台上跑起来，不会整个v0.1被视频依赖拖住。

---

### 五、验证方案（v0.1）

#### 功能验证清单
- [ ] 视频能正常播放、暂停、拖动进度
- [ ] 全屏沉浸式体验，系统栏隐藏
- [ ] 双击屏幕出现爱心爆炸特效
- [ ] 到达高光点自动弹出互动选项
- [ ] 进度条上显示高光点标记（不同类型不同颜色）
- [ ] 选择互动选项触发对应粒子特效（6种都能正常显示）
- [ ] 选择分支显示反馈动画
- [ ] 特效动画流畅，无明显卡顿

#### 性能目标
- **调整后的目标**：无明显卡顿，关键动画稳定（不强求60fps和<200MB）
- 视频播放流畅
- 特效动画不掉帧
- 单个特效显示不影响性能
- 内存占用合理

#### 设备测试
- 在至少1台Android设备上测试
- 测试基本的屏幕尺寸适配

---

### 六、关键技术点

#### 1. 视频与互动层的叠加
```dart
Stack(
  children: [
    VideoPlayer(_controller),           // 视频层
    GestureDetector(                    // 手势层（双击检测）
      onDoubleTapDown: _onDoubleTap,
      child: Container(color: Colors.transparent),
    ),
    EffectLayer(effects: _effects),     // 特效层
    InteractionOverlay(...),            // 互动层
    Positioned(                         // 底部信息栏
      bottom: 0,
      child: _BottomInfoBar(...),
    ),
  ],
)
```

#### 2. 特效生命周期管理
```dart
// 使用GlobalKey或Controller模式，避免调用入口太绕
class EffectLayer extends StatefulWidget {
  const EffectLayer({super.key});

  @override
  State<EffectLayer> createState() => EffectLayerState();
}

class EffectLayerState extends State<EffectLayer> {
  final List<Effect> _effects = [];

  void addEffect(Effect effect) {
    setState(() {
      _effects.add(effect);
    });

    // 动画结束后自动移除
    Future.delayed(effect.duration, () {
      if (mounted) {
        setState(() {
          _effects.remove(effect);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _effects.map((e) => e.build(context)).toList(),
    );
  }
}

// 父组件通过GlobalKey调用
final _effectLayerKey = GlobalKey<EffectLayerState>();

// 触发特效
_effectLayerKey.currentState?.addEffect(HeartBurstEffect(...));
```

#### 3. 粒子特效基类设计
```dart
abstract class ParticleEffect extends StatefulWidget {
  final Offset position;
  final Duration duration;
  final VoidCallback? onComplete;

  const ParticleEffect({
    required this.position,
    this.duration = const Duration(milliseconds: 800),
    this.onComplete,
    super.key,
  });
}

class ParticleEffectState<T extends ParticleEffect> extends State<T>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

### 七、数据准备（v0.1）

#### 1. 测试视频准备
**推荐方案**：使用FFmpeg生成轻量测试视频

```bash
# 方案1：纯色背景 + 时间戳（最轻量）
ffmpeg -f lavfi -i color=c=0x2E5EAA:s=1080x1920:d=20 \
  -vf "drawtext=text='北派寻宝笔记 EP01 %{pts\:hms}':fontsize=80:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2" \
  -c:v libx264 -pix_fmt yuv420p test_video_20s.mp4

# 方案2：渐变背景 + 动态文字
ffmpeg -f lavfi -i "color=c=0x2E5EAA:s=1080x1920:d=20,format=rgb24,geq='r=128+128*sin(2*PI*T/10):g=128+128*sin(2*PI*T/10+2*PI/3):b=128+128*sin(2*PI*T/10+4*PI/3)'" \
  -vf "drawtext=text='%{pts\:hms}':fontsize=120:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2" \
  -c:v libx264 -pix_fmt yuv420p test_video_gradient_20s.mp4
```

**视频规格**：
- 时长：15-30秒
- 分辨率：1080x1920（9:16竖屏）
- 格式：MP4（H.264编码）
- 文件大小：<5MB

#### 2. Mock数据增强
**更新文件**：`client/lib/features/drama/data/mock_drama_repository.dart`

**增强内容**：
```dart
// 为InteractionOption添加effectType
class InteractionOption {
  const InteractionOption({
    required this.id,
    required this.label,
    required this.effectText,
    required this.effectType,  // 新增
  });

  final String id;
  final String label;
  final String effectText;
  final EffectType effectType;  // 新增
}

// 示例数据
InteractionOption(
  id: 'cool',
  label: '爽',
  effectText: '全屏冲击波 + 热度计上涨',
  effectType: EffectType.shockwave,  // 新增
),
InteractionOption(
  id: 'shock',
  label: '反转了',
  effectText: '弹出反转徽章并加入同屏互动计数',
  effectType: EffectType.textFly,  // 新增
),
```

**高光点时间调整**：
- 将高光点时间调整到测试视频的合理位置（如5秒、10秒、15秒）
- 确保有足够时间展示互动效果

---

### 八、Demo演示脚本（v0.1）

#### 演示流程（3分钟）
1. **启动应用**（10秒）
   - 展示短剧列表页面
   - 点击进入第一个短剧

2. **基础播放功能**（30秒）
   - 展示全屏沉浸式视频播放
   - 演示播放/暂停
   - 演示进度拖动

3. **双击爱心互动**（20秒）
   - 双击屏幕多次
   - 展示爱心爆炸特效
   - 说明：低成本高反馈的互动方式

4. **高光点互动**（60秒）
   - 展示进度条上的高光点标记
   - 等待第一个高光点触发
   - 展示互动弹窗
   - 选择"爽"选项，展示冲击波特效
   - 等待第二个高光点
   - 选择分支选项，展示分支反馈

5. **情绪粒子展示**（40秒）
   - 依次触发不同高光点
   - 展示6种情绪粒子特效：
     - 爱心飘浮
     - 冲击波扩散
     - 泪滴下落
     - 糖果飘落
     - 火焰上升
     - 文字飞出

6. **总结**（20秒）
   - 回顾v0.1展示的核心功能
   - 说明v0.2将增加的高级互动（竖滑Feed、手势、摇一摇等）

---

## 预期成果（v0.1）

完成后的demo将具备：
1. ✅ 真实视频播放功能（播放、暂停、进度控制）
2. ✅ 全屏沉浸式播放器UI
3. ✅ 双击爱心爆炸特效
4. ✅ 高光点可视化触发条
5. ✅ 6种情绪粒子特效（heart, shockwave, tears, candy, flame, text_fly）
6. ✅ 剧情分支选择反馈
7. ✅ 使用轻量mock数据，为后端对接预留接口
8. ✅ 完整的Android APK可安装运行

**不包含**（留给v0.2）：
- ❌ 竖滑Feed
- ❌ 情绪热力图
- ❌ 多指连击
- ❌ 画手势施法
- ❌ 摇一摇加油
- ❌ 右侧操作栏

编码者可以直接按照本计划的步骤和文件结构开始实现v0.1，完成后再规划v0.2的扩展功能。

---

## 注意事项

1. **视频资源**：使用FFmpeg生成测试视频，避免版权问题和仓库体积膨胀
2. **依赖管理**：使用`flutter pub add`命令，不写死版本号
3. **性能目标**：调整为"无明显卡顿，关键动画稳定"，不强求60fps
4. **特效数量**：v0.1控制特效复杂度，单个特效优先，避免同时显示过多
5. **代码规范**：遵循Flutter最佳实践，使用StatefulWidget管理状态
6. **注释文档**：关键算法和复杂逻辑添加注释，方便后续维护
7. **版本迭代**：v0.1聚焦核心体验，v0.2再扩展高级功能
