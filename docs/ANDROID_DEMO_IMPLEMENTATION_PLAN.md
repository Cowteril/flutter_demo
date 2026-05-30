# Android短剧互动Demo实现计划

## Context（背景）

本项目旨在开发一个短剧互动应用的Android demo，核心目标是：
1. **展示创意互动功能**：基于`docs/frontend_creative_ideas.yaml`中定义的27个创意点，选择最适合demo展示的功能
2. **参考红果短剧APP样式**：前端UI设计参考主流短剧APP的沉浸式体验
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

## 实现方案

### 一、核心功能升级

#### 1. 真实视频播放器实现
**目标**：将mock播放器升级为真实视频播放器

**技术方案**：
- 使用`video_player`包（Flutter官方视频播放插件）
- 准备1-2个示例短剧视频（MP4格式，竖屏9:16比例，时长3-5分钟）
- 视频存放位置：`client/assets/videos/`
- 更新`pubspec.yaml`添加依赖和资源声明

**关键文件修改**：
- `client/pubspec.yaml`：添加`video_player`依赖和assets配置
- `client/lib/features/player/presentation/drama_player_page.dart`：
  - 替换`_MockVideoStage`为`_RealVideoPlayer`
  - 集成`VideoPlayerController`
  - 同步视频进度与高光点触发逻辑
  - 保持现有的播放/暂停/进度条控制

**数据准备**：
- 准备示例视频文件（可使用开源短视频或自制简单视频）
- 更新`mock_drama_repository.dart`中的视频URL指向本地assets
- 确保高光点时间与视频内容对应

#### 2. 沉浸式竖滑短剧流（immersive_vertical_feed）
**优先级**：P0 | **难度**：M | **权限**：无

**实现方式**：
- 使用`PageView.builder`实现竖向翻页
- 每页复用`DramaPlayerPage`的播放器和互动能力
- 自动播放当前页视频，切换时暂停上一页
- 添加页面切换动画和视觉反馈

**新增文件**：
- `client/lib/features/feed/presentation/drama_feed_page.dart`：竖滑feed主页面
- `client/lib/features/feed/presentation/widgets/feed_item.dart`：单个feed项组件

**修改文件**：
- `client/lib/main.dart`：将首页改为feed页面（可选，保留列表页作为入口）

---

### 二、创意互动功能实现（按优先级）

#### P0级功能（必须实现，撑起demo效果）

##### 1. 双击爱心爆炸（double_tap_heart_burst）
**难度**：S | **权限**：无 | **打断级别**：Low

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

##### 2. 剧情高光触发条（highlight_effect_trigger_bar）
**难度**：M | **权限**：无 | **打断级别**：Low

**实现方式**：
- 升级现有的`_HighlightTimeline`组件
- 在进度条上方叠加高光点标记
- 不同类型高光点使用不同颜色/图标
  - reaction: 橙色火焰图标
  - branch: 紫色分支图标
  - extension: 金色星星图标
- 播放到高光点时自动触发InteractionOverlay
- 添加高光点脉动动画提示

**修改文件**：
- `client/lib/features/player/presentation/drama_player_page.dart`：增强高光触发逻辑
- `client/lib/features/player/presentation/widgets/highlight_timeline.dart`（新建）：独立的时间轴组件

##### 3. 情绪粒子预设（reaction_particle_presets）
**难度**：M | **权限**：无 | **打断级别**：Low

**实现方式**：
- 定义6种基础特效类型：
  - `heart`：爱心飘浮（粉色）
  - `shockwave`：冲击波扩散（白色闪光）
  - `tears`：泪滴下落（蓝色）
  - `candy`：糖果飘落（彩色）
  - `flame`：火焰上升（橙红色）
  - `text_fly`：文字飞出（自定义颜色）
- 用户选择InteractionOption后触发对应特效
- 使用`CustomPainter`绘制粒子
- 使用`AnimationController`控制粒子运动

**新增文件**：
- `client/lib/features/player/domain/models/effect_type.dart`：特效类型枚举
- `client/lib/features/player/presentation/widgets/effects/particle_effect.dart`：粒子特效基类
- `client/lib/features/player/presentation/widgets/effects/heart_particle.dart`
- `client/lib/features/player/presentation/widgets/effects/shockwave_effect.dart`
- `client/lib/features/player/presentation/widgets/effects/tears_effect.dart`
- `client/lib/features/player/presentation/widgets/effects/candy_effect.dart`
- `client/lib/features/player/presentation/widgets/effects/flame_effect.dart`
- `client/lib/features/player/presentation/widgets/effects/text_fly_effect.dart`

**数据关联**：
- 更新`InteractionOption`模型，添加`effectType`字段
- 更新mock数据，为每个选项指定特效类型

##### 4. 同屏观众情绪热力图（real_time_audience_heatmap）
**难度**：M | **权限**：无 | **打断级别**：Low

**实现方式**：
- 在进度条上方叠加半透明柱状图
- 使用本地模拟数据生成情绪分布
- 不同情绪用不同颜色：
  - 爽：红色 (#FF4444)
  - 破防：蓝色 (#4444FF)
  - 笑：黄色 (#FFAA00)
  - 反转：紫色 (#AA44FF)
- 用户互动实时加入热力图
- 使用`CustomPaint`绘制柱状图

**新增文件**：
- `client/lib/features/player/presentation/widgets/heatmap_overlay.dart`：热力图组件
- `client/lib/features/player/domain/models/emotion_data.dart`：情绪数据模型

**Mock数据结构**：
```dart
class EmotionHeatPoint {
  final int timeMs;
  final Map<EmotionType, double> emotions; // 情绪类型 -> 百分比
}
```

#### P1级功能（增强体验，展示差异化）

##### 5. 多指连点连击（multi_finger_tap_combo）
**难度**：S | **权限**：无 | **打断级别**：Low

**实现方式**：
- 检测单位时间内的触摸点数量
- 每次点击触发打击特效（闪光+震动）
- 显示实时连击数和DPS
- 连击数达到阈值触发特殊效果（全屏闪光）
- 使用`Listener`widget监听多点触摸

**新增文件**：
- `client/lib/features/player/presentation/widgets/combo_counter.dart`：连击计数器UI
- `client/lib/features/player/presentation/widgets/effects/tap_impact_effect.dart`：点击冲击特效

**触发场景**：
- 在特定高光点（如战斗场景）提示用户多指连点
- 显示"疯狂点击助攻！"提示

##### 6. 画手势施放技能（draw_gesture_cast_spell）
**难度**：M | **权限**：无 | **打断级别**：Medium

**实现方式**：
- 使用`GestureDetector`捕获触摸轨迹
- 实现简单手势识别算法：
  - 圆形：计算轨迹点到中心的距离方差
  - 心形：检测两个弧形+底部尖角
  - Z字形：检测3个转折点
  - 直线：检测起点终点距离与轨迹总长度比例
- 画手势时显示轨迹反馈（半透明线条）
- 识别成功触发对应技能特效

**新增文件**：
- `client/lib/features/player/presentation/widgets/gesture_canvas.dart`：手势绘制画布
- `client/lib/features/player/domain/gesture_recognizer.dart`：手势识别算法
- `client/lib/features/player/domain/models/gesture_type.dart`：手势类型枚举

**支持的手势**：
- Circle（圆形）→ 防御护盾特效
- Heart（心形）→ 治疗光环特效
- ZigZag（Z字）→ 闪电攻击特效
- Line（直线）→ 剑气斩击特效

##### 7. 摇一摇为角色加油（shake_phone_to_cheer）
**难度**：S | **权限**：无（使用加速度传感器） | **打断级别**：Medium

**实现方式**：
- 使用`sensors_plus`包检测加速度
- 计算加速度变化幅度判断摇动
- 摇动时触发：
  - 屏幕闪光效果
  - 震动反馈（使用`vibration`包）
  - 能量条上涨动画
  - 显示摇动次数
- 降级方案：点击按钮加油

**新增依赖**：
- `sensors_plus: ^5.0.0`
- `vibration: ^2.0.0`

**新增文件**：
- `client/lib/features/player/presentation/widgets/shake_detector.dart`：摇动检测组件
- `client/lib/features/player/presentation/widgets/energy_bar.dart`：能量条UI

##### 8. 剧情分支选择时刻（branch_choice_moment）
**难度**：M | **权限**：无 | **打断级别**：Medium

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

### 三、UI样式优化（参考红果短剧APP）

#### 1. 沉浸式全屏体验
- 隐藏系统状态栏和导航栏
- 视频占据全屏，控件半透明悬浮
- 使用深色主题，减少UI干扰

#### 2. 右侧操作栏（HUD Layer）
**新增组件**：
- 点赞按钮（带数字）
- 评论按钮（带数字）
- 分享按钮
- 角色头像（点击查看角色信息）

**新增文件**：
- `client/lib/features/player/presentation/widgets/side_action_bar.dart`

#### 3. 底部信息栏
- 短剧标题和副标题
- 当前集数信息
- 半透明背景，不遮挡视频核心内容

#### 4. 动画和过渡
- 页面切换使用淡入淡出+位移动画
- 按钮点击有缩放反馈
- 特效出现有弹性动画（Curves.elasticOut）

---

### 四、数据准备

#### 1. 示例视频准备
**方案A（推荐）**：使用开源短视频
- 从Pexels、Pixabay等免费视频网站下载3个竖屏短视频
- 时长控制在3-5分钟
- 分辨率：1080x1920（9:16）
- 格式：MP4（H.264编码）

**方案B**：使用纯色+文字的模拟视频
- 使用FFmpeg生成带时间戳的测试视频
- 不同颜色背景代表不同短剧

**视频文件命名**：
- `north_treasure_ep01.mp4`
- `winter_day_ep01.mp4`
- `xiuxian_ep01.mp4`

#### 2. Mock数据增强
**更新文件**：`client/lib/features/drama/data/mock_drama_repository.dart`

**增强内容**：
- 为每个InteractionOption添加effectType字段
- 添加情绪热力图mock数据
- 添加角色信息（头像、名称、简介）
- 添加点赞/评论/分享的mock数据

**新增数据模型**：
```dart
// client/lib/features/drama/domain/models/character.dart
class Character {
  final String id;
  final String name;
  final String avatar;
  final String description;
}

// client/lib/features/player/domain/models/effect_type.dart
enum EffectType {
  heart, shockwave, tears, candy, flame, textFly
}
```

---

### 五、项目结构调整

#### 新增目录结构
```
client/lib/
├── features/
│   ├── feed/                          # 新增：竖滑feed功能
│   │   ├── presentation/
│   │   │   ├── drama_feed_page.dart
│   │   │   └── widgets/
│   │   │       └── feed_item.dart
│   ├── player/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── effect_type.dart   # 新增
│   │   │   │   └── gesture_type.dart  # 新增
│   │   │   └── gesture_recognizer.dart # 新增
│   │   ├── presentation/
│   │   │   ├── widgets/
│   │   │   │   ├── effect_layer.dart  # 新增
│   │   │   │   ├── side_action_bar.dart # 新增
│   │   │   │   ├── heatmap_overlay.dart # 新增
│   │   │   │   ├── combo_counter.dart # 新增
│   │   │   │   ├── energy_bar.dart    # 新增
│   │   │   │   ├── gesture_canvas.dart # 新增
│   │   │   │   ├── shake_detector.dart # 新增
│   │   │   │   └── effects/           # 新增：特效组件目录
│   │   │   │       ├── heart_burst_effect.dart
│   │   │   │       ├── particle_effect.dart
│   │   │   │       ├── shockwave_effect.dart
│   │   │   │       ├── tears_effect.dart
│   │   │   │       ├── candy_effect.dart
│   │   │   │       ├── flame_effect.dart
│   │   │   │       ├── text_fly_effect.dart
│   │   │   │       └── tap_impact_effect.dart
│   ├── drama/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── character.dart     # 新增
│   │   │   │   └── emotion_data.dart  # 新增
├── assets/                             # 新增
│   └── videos/                         # 新增：视频资源
│       ├── north_treasure_ep01.mp4
│       ├── winter_day_ep01.mp4
│       └── xiuxian_ep01.mp4
```

#### 依赖更新（pubspec.yaml）
```yaml
dependencies:
  flutter:
    sdk: flutter
  video_player: ^2.8.0          # 视频播放
  sensors_plus: ^5.0.0          # 加速度传感器（摇一摇）
  vibration: ^2.0.0             # 震动反馈

assets:
  - assets/videos/
```

---

### 六、实现步骤（按顺序）

#### 阶段1：基础设施（1-2天）
1. 更新`pubspec.yaml`，添加依赖
2. 准备3个示例视频，放入assets目录
3. 实现真实视频播放器，替换mock播放器
4. 测试视频播放、暂停、进度控制功能
5. 确保高光点触发逻辑与视频进度同步

#### 阶段2：核心特效系统（2-3天）
1. 创建`effect_layer.dart`特效层容器
2. 实现`particle_effect.dart`粒子特效基类
3. 实现6种情绪粒子特效（heart, shockwave, tears, candy, flame, text_fly）
4. 实现双击爱心爆炸功能
5. 更新InteractionOption数据模型，关联特效类型
6. 测试特效触发和显示

#### 阶段3：高光互动增强（1-2天）
1. 升级高光触发条，添加可视化标记
2. 实现情绪热力图组件
3. 准备mock情绪数据
4. 实现分支选择反馈动画
5. 测试高光点触发和互动流程

#### 阶段4：手势互动功能（2-3天）
1. 实现多指连点连击功能
2. 实现连击计数器UI
3. 实现手势识别算法
4. 实现手势绘制画布
5. 实现4种手势对应的技能特效
6. 实现摇一摇检测和反馈
7. 测试各种手势互动

#### 阶段5：UI优化和沉浸式体验（1-2天）
1. 实现右侧操作栏
2. 优化底部信息栏样式
3. 实现沉浸式竖滑feed
4. 添加页面切换动画
5. 优化全屏体验（隐藏系统栏）
6. 调整主题和配色，参考红果短剧APP

#### 阶段6：数据完善和测试（1天）
1. 完善mock数据（角色、情绪、互动数据）
2. 为每个短剧配置完整的高光点和特效
3. 端到端测试所有功能
4. 修复bug和优化性能
5. 准备demo演示脚本

---

### 七、验证方案

#### 功能验证清单
- [ ] 视频能正常播放、暂停、拖动进度
- [ ] 双击屏幕出现爱心爆炸特效
- [ ] 到达高光点自动弹出互动选项
- [ ] 选择互动选项触发对应粒子特效
- [ ] 进度条上显示高光点标记和情绪热力图
- [ ] 多指连点显示连击数和冲击特效
- [ ] 画手势能识别并触发技能特效
- [ ] 摇动手机触发加油特效和震动反馈
- [ ] 选择分支显示反馈动画
- [ ] 竖滑切换不同短剧
- [ ] 右侧操作栏显示点赞/评论/分享按钮
- [ ] 全屏沉浸式体验，UI不遮挡核心内容

#### 性能验证
- 视频播放流畅，无卡顿（60fps）
- 特效动画流畅，无掉帧
- 多个特效同时显示不影响性能
- 内存占用合理（<200MB）

#### 设备测试
- 在至少2台不同Android设备上测试
- 测试不同屏幕尺寸的适配
- 测试低端设备的性能表现

---

### 八、关键技术点

#### 1. 视频与互动层的叠加
```dart
Stack(
  children: [
    VideoPlayer(_controller),           // 视频层
    GestureDetector(...),                // 手势层
    EffectLayer(effects: _effects),      // 特效层
    InteractionOverlay(...),             // 互动层
    SideActionBar(...),                  // HUD层
  ],
)
```

#### 2. 特效生命周期管理
```dart
class EffectLayer extends StatefulWidget {
  final List<Effect> effects;

  void addEffect(Effect effect) {
    // 添加特效
    // 自动在动画结束后移除
  }
}
```

#### 3. 手势识别算法示例
```dart
class GestureRecognizer {
  GestureType recognize(List<Offset> points) {
    if (_isCircle(points)) return GestureType.circle;
    if (_isHeart(points)) return GestureType.heart;
    if (_isZigZag(points)) return GestureType.zigzag;
    if (_isLine(points)) return GestureType.line;
    return GestureType.unknown;
  }

  bool _isCircle(List<Offset> points) {
    // 计算点到中心的距离方差
    // 方差小于阈值则为圆形
  }
}
```

#### 4. 情绪热力图绘制
```dart
class HeatmapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 遍历每个时间点的情绪数据
    // 绘制半透明柱状图
    // 不同情绪用不同颜色叠加
  }
}
```

---

### 九、注意事项

1. **视频版权**：使用开源或自制视频，避免版权问题
2. **性能优化**：特效数量控制在合理范围，避免同时显示过多特效
3. **降级方案**：对于传感器功能，提供点击按钮的降级方案
4. **用户引导**：首次使用时显示功能引导，教用户如何互动
5. **数据格式**：为后续与后端对接预留扩展性，使用JSON格式的数据结构
6. **代码规范**：遵循Flutter最佳实践，使用StatefulWidget管理状态
7. **注释文档**：关键算法和复杂逻辑添加注释，方便后续维护

---

### 十、Demo演示脚本

#### 演示流程（5分钟）
1. **启动应用**（10秒）
   - 展示短剧列表页面
   - 点击进入第一个短剧

2. **基础播放功能**（30秒）
   - 展示视频播放
   - 演示播放/暂停
   - 演示进度拖动

3. **双击爱心互动**（20秒）
   - 双击屏幕多次
   - 展示爱心爆炸特效

4. **高光点互动**（60秒）
   - 等待第一个高光点触发
   - 展示互动弹窗
   - 选择"爽"选项，展示冲击波特效
   - 等待第二个高光点
   - 选择分支选项，展示分支反馈

5. **情绪热力图**（20秒）
   - 展示进度条上的情绪分布
   - 说明不同颜色代表不同情绪

6. **多指连点**（30秒）
   - 在战斗场景多指疯狂点击
   - 展示连击数和冲击特效

7. **画手势施法**（40秒）
   - 画圆形，触发防御护盾
   - 画心形，触发治疗光环
   - 画Z字，触发闪电攻击

8. **摇一摇加油**（30秒）
   - 摇动手机
   - 展示屏幕闪光和能量条上涨

9. **竖滑切换短剧**（30秒）
   - 向上滑动切换到下一个短剧
   - 展示自动播放

10. **总结**（20秒）
    - 回顾展示的创意功能
    - 说明后续扩展方向

---

## 预期成果

完成后的demo将具备：
1. ✅ 真实视频播放功能（播放、暂停、进度控制）
2. ✅ 8个创意互动功能（双击爱心、高光触发、情绪粒子、热力图、多指连点、画手势、摇一摇、分支选择）
3. ✅ 沉浸式竖滑feed体验
4. ✅ 参考红果短剧APP的UI样式
5. ✅ 所有特效可见可用，不是文字描述
6. ✅ 使用mock数据，为后端对接预留接口
7. ✅ 完整的Android APK可安装运行

编码者可以直接按照本计划的步骤和文件结构开始实现，无需额外的需求澄清。
