# Android Demo v0.2 计划

## 1. 背景与定位

v0.1 完成了单屏播放器 + 6 类情绪粒子的核心闭环，v0.1 打磨在主题层、主页改造、HUD 重做、shader 招牌镜头上完成了"产品感"升级。

v0.2 的定位是：**从"沉浸式单屏播放器"升级为"短剧 App 形态"**，叠加两件 v0.1 没有的事——**可视化的数据感**和**深度互动**。这是把 demo 从"播放器原型"推到"产品原型"的关键一跃。

v0.2 不再是 v0.1 列表里的"剩余功能池"，而是围绕一个明确主题展开：

> **短剧 Feed 化 + 互动数据可视化 + 招牌交互三件套**

## 2. 前置条件与并行模式

v0.2 与 v0.1 打磨**并行推进**，不是串行依赖。两条流的边界：

- **v0.1 打磨流**：主题层、Hero 主页、底部 HUD 重做、shader 招牌镜头（独立、不阻塞 v0.2）
- **v0.2 主流**：本计划 §5 全部内容

并行可行的理由：v0.1 打磨集中在"视觉表达层"（主题色、字体、Hero 卡片、shader），v0.2 集中在"架构与交互层"（Feed、操作栏、ML 推理、多指识别），两条流的代码改动面基本不重叠。

**硬前置（无论谁先做都必须先解决）**：

- 真机黑屏问题完成根因诊断（见 §6.1）—— 阻塞所有真机演示
- 当前 v0.1 已实现的功能链路在主测设备上全程跑通无崩溃 —— 阻塞 Feed 内嵌播放器组件

真机黑屏未根因清楚之前，v0.2 §5.2（Feed 架构）不启动；其他 v0.2 子项（§5.3 操作栏、§5.4 温度计、§5.6 stub 施法 UI）可以先行。

## 3. 目标

### 3.1 产品目标

- 评委第一帧看到产品时识别为"短剧 App"，不是"播放器 demo"
- 录屏中出现 **至少 3 个独立的招牌镜头**（v0.1 已有 1 个 shader 爆发，v0.2 新增至少 2 个）
- 互动维度从"点 + 双击"扩展到"多指 + 手势"，体现"激发即时表达"题目要求

### 3.2 技术目标

- 解决 `video_player` 在 `PageView` 中的生命周期管理（预加载、释放、音频焦点）
- 用 **dot-pattern 手势识别** 替代连续曲线识别，作为技术选型亮点
- 多指连击和现有手势体系不互相污染
- 情绪数据可视化在无后端的前提下呈现"有后端"假象

### 3.3 合规目标

继承 v0.1：素材使用遵循"许可证可查、可商用、可留证据"原则，新增素材记录到 `docs/ASSET_LICENSES.md`。

## 4. 非目标

- 摇一摇 / 任何传感器类交互（录屏不友好、真机差异大、答辩演示困难）
- 真实后端服务（本课题 demo 全部用 mock 数据 + 本地状态）
- 完整的用户系统（评论/点赞数据是静态 mock，不做发表/查看互动）
- 视频内容真实理解或 AIGC 生成（v0.1 高光点已经是 mock 标注，v0.2 不扩展）
- Free-form 手势识别（被 dot-pattern 方案替代，见 §6.2）

## 5. 范围

按"基础稳定 → 架构升级 → UI 升级 → 数据感 → 深度互动"五段组织，全部 P0，无 P1/P2。

### 5.1 真机黑屏修复（基础稳定）

诊断当前真机黑屏问题，可能根因优先级：

1. `video_player` 在某些 Android 版本上 SurfaceView 渲染失败
2. v0.1 shader 叠加视频层导致黑屏
3. 应用进入后台再回前台时 controller 状态丢失
4. 模拟器 vs 真机 codec 差异

修复策略按根因决定：

- 若是 SurfaceView 问题，切到 `media_kit` 或 `video_player_media_kit` backend
- 若是 shader 兼容性，shader 改为非叠加模式（独立层而非视频后处理）
- 若是生命周期，加入 `WidgetsBindingObserver` 处理 pause/resume

### 5.2 沉浸式竖滑 Feed（架构升级）

v0.2 最大架构改动，技术风险最高。

**关键决策：保留列表页作为兜底入口**

不替换 `drama_list_page.dart`，而是新增 `drama_feed_page.dart` 作为主入口，列表页作为 secondary entry（顶部右上角"剧库"按钮）。理由：

- Feed 万一在演示设备上出问题，列表页可立即接管
- 答辩演示路径多了一条："Feed 浏览"或"剧库选择"
- 现有 `drama_list_page.dart` 投入的 UI 升级不浪费

**技术方案**：

```text
DramaFeedPage
  └─ PageView.builder(scrollDirection: Axis.vertical)
       └─ FeedItem (复用 DramaPlayerPage 的核心组件)
            ├─ Video Layer
            ├─ EffectLayer
            ├─ 右侧操作栏 (5.3)
            ├─ 底部信息区
            ├─ 顶部细线进度条
            └─ 右上角集数角标（极简 "01" 或 "01/24"，沉浸不破画面）
```

**生命周期策略**：

- 当前页：`play()`
- 上一页/下一页：`pause()` 但保留 controller
- N-2 / N+2：`dispose()` controller
- 滑动切换时：先 pause 当前，再 play 目标，避免双音
- audio focus：使用 `AudioSession` 协调

### 5.3 右侧操作栏（UI 升级）

短剧 App 的核心身份标识控件。位置：竖向浮在播放器右下角，自下而上：

- 选集（chip stack icon）
- 分享（带数字）
- 评论（带数字）
- 点赞（爱心，带数字，点击触发现有 HeartBurstEffect）
- 角色头像 + 关注按钮（最上）

全部 mock 数据：点赞数静态、评论数静态、关注状态静态。点击仅触发本地动效（数字 +1、关注变"已关注"），不入库。

**头像素材方案：AI 生成**

每部 mock 剧生成 1 张角色头像（共 3-6 张），放进 `client/assets/avatars/`。素材合规链路：

- 用图像生成模型（即梦 / SDXL 等）按角色描述 prompt 生成
- 在 `docs/ASSET_LICENSES.md` 记录生成模型、prompt、生成日期
- 不使用真实剧集封面截图（避免版权问题）
- 不使用纯几何色块兜底（观感弱）

**和 v0.1 现有底部 HUD 的整合**：

- v0.1 打磨过的底部 HUD（标题/温度计/集数胶囊）保留
- 右侧操作栏与底部 HUD 不重叠（z-index 检查）

### 5.4 招牌交互 A：情绪温度计 + 同屏热力图（数据感）

这是 v0.2 的"数据可视化"招牌，对应课题题面"激发即时情绪表达"。

**组件分层**：

1. **顶部温度计 bar**：横向 30px 高的渐变 bar，根据当前"全网情绪值"实时跳动（mock）
2. **左下角同屏人数**：`🔥 1.2w 人在看 · 386 人正在表达`，每隔几秒小幅波动
3. **高光时刻全场沸腾**：高光点触发后温度计爆满 → 触发全屏径向波纹 + 数字快速跳 + 副标题"全场沸腾"
4. **用户互动联动**：用户每次触发情绪选项，温度计涨一格，全屏闪一下对应色

**Mock 数据生成策略**：

- 后台运行一个伪随机 generator（基于时间戳 + 当前高光点）
- 输出：温度值 0-100、同屏人数、情绪类型分布（爽/破防/撒糖等比例）
- 接近高光点时间窗时 spike，远离时回落
- 用户主动触发时 +10 立刻反馈

**为什么这个是 v0.2 的核心招牌**：

- 录屏能看见（永远在屏幕上）
- 答辩能讲（"即时情绪可视化"——直接对应课题原话）
- 视觉差异化（v0.1 没做过的数据驱动元素）
- 假象效果强（看起来后端在工作）

### 5.5 招牌交互 B：多指连击（爽点深度互动）

**触发模式：gated by 高光点**

不全局开启多指识别，只在特定 `HighlightKind`（战斗/爽点类）激活的高光窗口内启用，避免和现有点击/双击冲突。

**视觉反馈（分层连击）**：

- 屏幕中心实时显示"COMBO ×N"大数字（弹性缩放）
- 每次触摸点位置爆出小粒子
- **N < 10**：仅粒子 + 数字递增，无特殊层级
- **N ≥ 10**：触发**完美连击**——屏幕轻微抖动 + 大字数字 + 副标题"完美 PERFECT"
- **N ≥ 20**：触发**神级连击**——全屏闪光 + 副标题"神级 GODLIKE" + 粒子色由白转金
- 1s 无新触摸 → 结算 toast：本次连击 N 次（10/20 上方分别有彩条提示等级达成）

阈值选 10/20 的理由：双档制比单档有层次；阈值低则演示者稳稳触发，录屏不至于"看着累"。

**技术实现**：

- 用 `Listener` 监听 raw pointer events（不用 `GestureDetector` 避免冲突）
- 维护活跃 pointer 集合，按 pointer down 计数
- 时间窗口 1s 滚动统计
- 当前播放/暂停手势在 combo 模式期间临时屏蔽

**冲突解决**：

- v0.1 的 `onTap` 切播放/暂停 → combo 模式期间 disable
- v0.1 的 `onDoubleTapDown` 爱心爆炸 → 仍然保留（爱心爆炸本身就是 combo 视觉的一部分）
- 进度条 slider 拖动 → 不受影响（combo 区不覆盖底部 HUD）

### 5.6 招牌交互 C：手势施法（TFLite + Quick Draw 端侧 AI + dot-pattern 兜底）

**核心技术决策：端侧深度学习模型主路径 + dot-pattern 兜底的混合方案**

主路径用端侧 TFLite 模型识别用户的自由手绘，兜底用锁屏式 dot-pattern 提供 100% 准确率的引导式输入。两条路径不是 A/B 选择，而是分层降级的整体设计。

**为什么是混合而不是单选**：

| 维度 | free-form 算法识别 | dot-pattern 单方案 | 端侧 ML + dot-pattern 兜底 |
| --- | --- | --- | --- |
| 识别准确度 | 70-90% | 100%（受限输入） | 主路径 85-95%，兜底 100% |
| 创新维度 | 中 | 中 | 高（端侧 AI + 工程兜底） |
| 答辩话术维度 | 算法实现 | 技术迁移 | **AI 模型 + 工程兜底**（双线） |
| Demo 失败处理 | 尴尬，重画 | 不适用 | **降级是 UX 设计一部分**，不是 bug |
| 课题命中维度 | 技术选型 | 创新探索 | 技术选型 + 创新 + AI 辅助 三杀 |

**开发期与生产期分离：Stub 优先，TFLite 模型作为后续 swap 项**

- App 端集成只依赖 `GestureClassifier` 抽象接口（见 §6.2）
- 开发期使用 `StubGestureClassifier`（基于笔画启发式：宽高比、笔画断点数、是否 Z 字），UX 流程完全通用
- TFLite 版本作为后续 swap 项，模型导出后只换实现、不动调用方
- 即使最终未训练出自有模型，可降级到：(a) 现成开源 Quick Draw 预训练模型（Plan A），(b) 启发式 Stub 作为"轻量端侧识别"重新叙事（Plan B）

**主路径目标态：TFLite + Quick Draw**

- 数据集：Google 开源的 Quick, Draw! 数据集（5000 万张涂鸦，345 类）
- 模型：MobileNetV2 backbone + 5 类分类头，通过 transfer learning 训练
- 类别选择（5 类，剧情贴合）：
  - `lightning` → 雷击（战斗剧）
  - `fire` → 火焰爆发（修仙、爽剧）
  - `sword` → 突进连击（武侠、寻宝）
  - `snowflake` → 冰封停滞（特殊场景）
  - `star` → 闪光治愈（情感戏）
- 模型规格：int8 量化后 < 5MB，输入 64×64 灰度图
- 推理延迟目标：< 100ms（主测设备）

**兜底路径：dot-pattern**

主路径置信度低于阈值或用户连续画错后自动激活：

- 屏幕浮现 3×3 发光点阵，提示"沿点连线施法"
- 用户拖动连点 → 100% 准确识别
- 4 个预设序列（对应 5 个 ML 类别中的 4 个）：
  - `[1,5,9]` 或 `[3,5,7]` → 雷击（直线）
  - `[1,2,3,6,9,8,7,4]` → 火焰（围圈）
  - `[1,2,3,5,7,8,9]` → 突进（Z 字）
  - `[2,5,8,5,4,5,6]` → 治愈（十字）

兜底比主路径少 1 类（`snowflake`）是有意为之：兜底是为了保 demo 不翻车，不需要覆盖全部技能。

**触发与降级流程**：

1. 高光点（修仙/战斗/爽剧类）激活"施法模式"
2. **画布范围：全屏暗化 + 半透明自由画布出现，覆盖整屏**
3. 用户自由绘制 → 抬手时模型推理
4. 推理结果分支：
   - **置信度 ≥ 0.7** → 触发对应技能特效 → 退出施法模式
   - **0.4 ≤ 置信度 < 0.7** → toast 提示"再画一次"，重置画布
   - **置信度 < 0.4** 或连续 2 次失败 → 自动切换到 dot-pattern 模式
5. dot-pattern 模式：发光点阵引导，必中
6. 退出条件：技能触发完成 / 用户点 ESC 区 / 持续 3s 无动作自动退出

画布选全屏的理由：施法模式接管全屏触摸已经没有冲突顾虑，全屏画布带来最强视觉冲击；同时 Quick Draw 训练样本本身就是全屏画板上画的，输入分布更接近训练集。

**UI 文案规范（半显式游戏化）**：

不直接使用"AI 识别中"这类直白措辞（"AI"在 2026 已经被严重稀释），而是用沉浸式游戏化语言包装，把技术标识藏在 flavor 文本里——让普通用户感受到沉浸，技术评审/评委一眼看穿背后技术栈。

| 时机 | 显示文字 | 隐藏的技术信号 |
| --- | --- | --- |
| 进入施法模式加载 | `灵识引擎载入中... (TFLite Runtime v2.x)` | 技术栈明示 |
| 模式标题 | `灵识感应` | 游戏化 |
| 高置信度命中 | `灵识感应：雷击之术` | 自然 |
| 中置信度提示 | `灵识不清，再画一次` | 隐式说明置信度不够 |
| 切兜底激活 | `灵识失灵，沿点连线施法` | 暗示降级 |
| dot-pattern 兜底提示 | `沿光点连线（古法施法）` | 区分主路径与兜底 |

**和现有手势体系的冲突解决**：

- 施法模式是显式进入态，进入后接管全屏触摸事件，播放控制临时屏蔽
- 退出后还原所有 GestureDetector
- 与多指连击不并存（同一高光点只激活其中一种，由 highlight 数据决定该激活哪种）

## 6. 技术选型重点

### 6.1 video_player 在 PageView 中的生命周期

最大技术风险点。建议方案：

```dart
class FeedItem extends StatefulWidget {
  final bool isActive;  // 由 PageView.onPageChanged 控制
  // ...
}

// 状态管理
- isActive 变 true: initialize (若未初始化) + play
- isActive 变 false: pause（不 dispose）
- 距离当前页 >= 2: dispose controller
- App 进入后台: pause all，记录当前页
- App 回前台: resume 当前页
```

提前评估 `media_kit`（基于 mpv，性能更稳）作为 `video_player` 的备选 backend。

### 6.2 端侧 AI 模型集成（TFLite + Quick Draw）

**模型接口契约（锁定优先于训练）**：

App 端集成只针对抽象接口编写，具体实现可在 Stub / 开源预训练 / 自训 TFLite 三者之间无缝替换。

```dart
abstract class GestureClassifier {
  Future<void> init();
  Future<GestureResult> classify(List<Offset> strokes);
  void dispose();
}

class GestureResult {
  final String label;       // 'lightning' | 'fire' | 'sword' | 'snowflake' | 'star'
  final double confidence;  // [0.0, 1.0]
  final Duration inferenceTime;

  const GestureResult({
    required this.label,
    required this.confidence,
    required this.inferenceTime,
  });
}
```

DI 层（如 `main.dart` 或 service locator）一处切换实现：

```dart
final GestureClassifier classifier = kUseStub
    ? StubGestureClassifier()
    : TFLiteGestureClassifier();
```

**StubGestureClassifier 实现要点**：

- 输入笔画分析三个特征：宽高比（瘦长 vs 圆润）、笔画断点数（一笔 vs 多笔）、是否有 Z 字转折
- 输出可控的高/中/低置信度分布，用于演示与 §5.6 降级路径测试
- 推理延迟模拟为 60-120ms（接近 TFLite 真实分布），避免后续 swap 时 UX 时序突变
- 价值：(a) 开发期解耦模型训练，(b) 应急演示兜底，(c) 验收清单中的"降级到 dot-pattern"路径可以在没有真模型时被测试

**离线训练与模型导出**（独立离线工作，可后于 App 集成、随时 swap）：

1. 从 Quick, Draw! 公开数据集下载所选 5 类的 `.ndjson` 数据（每类约 10-15 万条样本）
2. 预处理：把每条样本的笔迹时序渲染成 64×64 灰度图，居中归一化笔画粗细
3. 训练：MobileNetV2 backbone + transfer learning，5 类分类头，目标 top-1 准确率 ≥ 90%
4. 导出：转 TFLite，int8 量化，模型最终 < 5MB
5. 打包：`client/assets/models/gesture_classifier.tflite`

**Flutter 集成结构**：

```dart
class GestureClassifier {
  late Interpreter _interpreter;

  Future<void> init() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/gesture_classifier.tflite',
    );
    await _warmUp();  // 跑一次 dummy 推理，避免冷启动延迟
  }

  Future<GestureResult> classify(List<Offset> strokes) async {
    final bitmap = _renderStrokesToBitmap(strokes, 64, 64);
    final input = _bitmapToTensor(bitmap);
    final output = List.filled(5, 0.0).reshape([1, 5]);
    _interpreter.run(input, output);
    return _topK(output, k: 1);
  }
}
```

**关键实现要点**：

- Interpreter 在进入施法模式前预热（init 一次 + 跑一次 dummy inference 避免冷启动 jank）
- 输入预处理：抗锯齿渲染、笔画粗细 normalize、bounding box 居中后填充到 64×64
- 推理放 `compute()` isolate 不阻塞 UI（即使 < 100ms 也避免渲染抖动）
- 置信度阈值：`[0.7, 1.0]` 触发，`[0.4, 0.7)` 提示重画，`[0, 0.4)` 切兜底

**依赖**：

- `tflite_flutter: ^0.10.4` 或当前最新稳定版
- 不引入 `tflite_flutter_helper`（API 已废弃，直接用基础 Interpreter）

### 6.3 dot-pattern 兜底实现

作为模型识别失败时的引导式输入：

- `GestureDetector` 包住 `CustomPaint`，监听 pan 事件
- 用 `hitTest` 检测当前指尖是否进入某个 dot 的判定圆
- 已连接的 dot 序列存在 `List<int>`，CustomPaint 重绘连线
- 释放时比对序列与预设手势 map（精确匹配，无近似）
- 连线视觉：Bezier 平滑 + 发光描边 + 残影粒子
- 兜底激活时，画布上半部分显示提示"AI 没认出来，沿点试试"

### 6.4 多指连击冲突解决

不用 `GestureDetector` 体系，直接用 `Listener`：

```dart
Listener(
  onPointerDown: (event) => _registerTouch(event.pointer, event.position),
  onPointerUp: (event) => _releaseTouch(event.pointer),
  // ...
)
```

时间窗口判定用 `Timer.periodic` 滚动统计，combo 模式期间向上覆盖现有 GestureDetector，模式退出时还原。

### 6.5 情绪温度计 mock 数据生成

```dart
class EmotionDataSource {
  // 基于时间戳 + 当前高光点距离的伪随机
  double getCurrentTemperature(Duration position, List<HighlightPoint> hps);

  // 触发后立刻 spike
  void onUserReaction(EmotionType type);

  // 高光点附近自动 spike + 全场沸腾事件
  Stream<EmotionEvent> events;
}
```

输出流给温度计组件 + 同屏人数 + 全场沸腾触发器订阅。

### 6.6 依赖清单

**新增**：

- `tflite_flutter: ^0.10.4`（端侧 ML 推理）
- 模型文件 `assets/models/gesture_classifier.tflite`（约 2-5MB，纳入 APK）

**不引入**：

- `sensors_plus`（摇一摇 out of scope）
- `tflite_flutter_helper`（API 已废弃，用基础 Interpreter）
- 手写曲线匹配算法库（$1 recognizer / DTW 等，被 ML 模型替代）
- `google_mlkit_digital_ink_recognition`（与 TFLite 路线二选一，已选 TFLite）
- 额外 video player 包，除非 §5.1 诊断确认 `video_player` 不可用

## 7. 落地顺序（按依赖关系，不按时间）

强制顺序，因为后项依赖前项的架构稳定：

1. **真机黑屏修复** —— 一切后续工作的前置，未稳定不开始任何架构改动
2. **竖滑 Feed 架构** —— 后续所有交互依赖 Feed 中的播放器组件稳定
3. **右侧操作栏 mock** —— Feed 架构内嵌组件，Feed 稳定后立刻做
4. **情绪温度计 + 热力图** —— 独立组件，可与 5 并行；但需要 Feed 中的播放器组件作为挂载点
5. **多指连击 gating** —— 改 GestureDetector 体系，需要 Feed 中的播放器组件已稳定
6. **端侧 AI 手势施法 + dot-pattern 兜底** —— 最依赖前面所有组件稳定，放最后；但**只依赖 `GestureClassifier` 接口**，不依赖真实 TFLite 模型

并行机会：
- 步骤 4（温度计）可在步骤 2（Feed）完成基本可跑后并行
- 步骤 6 用 `StubGestureClassifier` 即可完成全部 UX 链路开发与验收（包括降级路径）
- dot-pattern 兜底 UI 组件可在 Stub 阶段先做（独立 widget）
- **模型训练为独立 swap 项**：可在项目任意阶段启动，导出后只换 DI 层实现，不动调用方。最终可能形态：(a) 自训 TFLite，(b) 开源预训练 Quick Draw 模型，(c) 保留 Stub 作为"轻量端侧识别"叙事
- v0.1 打磨流（主题层、Hero 主页、底部 HUD、shader 招牌镜头）全程与上述 6 步并行，互不阻塞

## 8. 技术验收清单

- [ ] 真机黑屏问题在主测设备上不复现
- [ ] 竖滑 Feed 上下切换流畅，无双音、无残留播放
- [ ] Feed 内播放器 60fps 稳定（frame time < 16.67ms）
- [ ] 右侧操作栏点击有反馈（数字 +1、关注态切换）
- [ ] 情绪温度计在视频播放期间一直可见，高光点附近有 spike
- [ ] 全场沸腾效果至少触发 1 次完整循环
- [ ] 多指连击在指定高光点正确激活，N≥10 触发完美连击、N≥20 触发神级连击
- [ ] TFLite 模型成功加载，主测设备上推理延迟 < 100ms
- [ ] 5 类手势模型 top-1 准确率 ≥ 90%（离线评估集）
- [ ] 自由画 → 高置信度时触发技能，低置信度时正确降级到 dot-pattern
- [ ] dot-pattern 兜底 4 种序列全部可识别，错误序列正确忽略
- [ ] 施法模式进入/退出不污染播放控制
- [ ] 模型推理放在 isolate，施法期间主线程 fps 不掉
- [ ] 列表页作为兜底入口可正常切换到播放
- [ ] `flutter analyze` 通过
- [ ] `flutter test` 通过
- [ ] Android debug APK 构建通过

## 9. 答辩表达重点

### 9.1 技术选型

> v0.2 我们做了三个技术决策：
>
> 第一，竖滑 Feed 我们手写了播放器生命周期管理，N±1 预加载、超出范围 dispose、audio focus 协调，这是短视频 App 的核心技术。
>
> 第二，手势识别我们走了 **端侧 AI + 经典算法兜底的混合方案**：主路径用 TFLite 部署一个基于 Google Quick, Draw! 数据集 transfer learning 的 5 类分类器，模型量化后 5MB 以内，端侧推理延迟 < 100ms；兜底路径用锁屏式 dot-pattern 序列识别，保证 100% 准确率。模型识别失败时**自动降级到 dot-pattern 引导式输入**——降级不是 bug fallback，而是 UX 设计的一部分。这套混合方案在创新性和稳定性之间做了明确取舍。
>
> 第三，多指连击我们用底层 Listener 自管理 pointer，绕开 GestureDetector 的双击冲突，gating 在特定高光点激活，避免污染主交互。

### 9.2 创新点

- **端侧 AI 模型支撑实时互动**：把 Quick, Draw! 的公开数据集和迁移学习落地到剧情手势识别，端侧推理无需联网，符合短剧 App 的实时性要求
- **AI + 工程兜底的混合识别架构**：主路径不准确时自动降级到点阵引导，把"模型不完美"变成产品体验的一部分而不是故障
- **数据可视化驱动情绪表达**：温度计 + 同屏人数 + 全场沸腾，直接对应课题"激发即时情绪表达"题面
- **分层互动设计**：v0.1 高频反馈 + v0.2 深度互动，覆盖从"轻量表达"到"沉浸操作"全谱
- **零后端的数据感呈现**：mock 数据 + 状态机模拟，展示无后端约束下做出"有后端"体验的工程能力

### 9.3 与 v0.1 的对比叙事

> v0.1 解决了"看剧能不能立刻有反应"这件事，v0.2 解决了"反应能不能形成深度参与"。v0.1 是单人视角，v0.2 是群体视角——这是从"播放器"到"产品"的关键差异。

## 10. 风险与降级

降级触发条件全部基于"功能就绪状态"，不基于时间：

| 风险 | 影响 | 降级触发 | 降级方案 |
| --- | --- | --- | --- |
| 真机黑屏根因复杂，修复成本高 | 阻塞所有后续 | 诊断后判断需重写 player 层 | 切到 `media_kit` 或保留 v0.1 单屏播放器，跳过 Feed |
| 竖滑 Feed 在演示设备上不稳定 | Feed 演示路径不可用 | 在主测设备上出现崩溃/黑屏/双音任一 | 列表页作为唯一入口，Feed 作为"实验入口" |
| 多指连击与现有手势冲突无法彻底解决 | 演示尴尬 | 进入 combo 模式后无法正确切回 | 改为 Demo 模式按钮触发 + 自动结束 |
| TFLite 模型准确率 < 80% | 主路径招牌镜头不稳 | 离线评估集 top-1 准确率不达标 | 降级为 dot-pattern 为主路径，ML 模型作为"有时认得"的彩蛋；或重训扩充数据 |
| 端侧推理延迟 > 200ms | 施法体感卡顿 | 主测设备实测推理 > 200ms | 模型进一步量化、降低输入分辨率到 48×48、改更小 backbone（如 SqueezeNet） |
| 模型 + 运行时使 APK 超出 30MB | 包体过大 | gradle 构建结果检查 | 模型再次量化、移除未用类别、用 dynamic delivery 模块化 |
| dot-pattern 用户学习成本高 | 答辩演示不流畅 | 评委或演示者画错率 > 50% | 加新手引导 toast + 高亮提示点阵起点 |
| 情绪温度计 mock 数据看起来太假 | 数据感招牌失效 | 评审反馈"明显在跳" | 降低跳动频率 + 加入"网络延迟"小动画掩盖 |

## 11. 最小可交付版本

如果某些项未能完成，**保底交付的是这套**：

1. v0.1 全部内容 + v0.1 打磨全部内容（兜底）
2. 真机黑屏修复（必交付，否则录屏都做不了）
3. 右侧操作栏（即使没有 Feed，也叠在现有播放器上，单独提升"短剧 App"观感）
4. 情绪温度计 + 同屏人数（即使没有热力图全屏波纹，温度计自身就是数据感招牌）

这三件即使 Feed、连击、手势全部砍掉，仍然是一个有数据感、有产品 UI、有稳定播放的 demo。

**关于手势施法的额外兜底**：即使 TFLite 模型未 swap 完成，`StubGestureClassifier` + dot-pattern 仍能构成完整施法演示链路——从"自由画布 → Stub 判定 → 命中触发 / 低置信度降级到点阵"全流程可走通。答辩叙事可在"端侧深度学习"与"端侧启发式识别 + 工程兜底"之间灵活切换。

完整版交付目标：1-3 + 竖滑 Feed + 多指连击 + dot-pattern 手势 + TFLite 模型 swap 完成。

## 12. 与 v0.1 计划的边界澄清

- 右侧操作栏归 v0.2（不在 v0.1 打磨范围内）
- 主页改造、主题层、字体、Hero 区、底部 HUD 重做归 v0.1 打磨
- shader 招牌镜头归 v0.1 打磨
- 摇一摇、传感器交互全部从所有计划中移除
- 手写曲线匹配算法路线（$1 recognizer / DTW 等）放弃，被端侧 TFLite 模型 + dot-pattern 兜底替代
- `ANDROID_DEMO_IMPLEMENTATION_PLAN.md` 中 Heart 手势项需删除（与 v0.1_PLAN 关于"不做心形"的约定冲突；本计划用 Quick Draw 的 `star` 替代 heart 类作为情感戏技能）

## 13. 已决策记录

原待决项已全部敲定，记录在此供后续工程对齐：

| 项 | 结论 | 章节 |
| --- | --- | --- |
| Feed 集数标识 | 右上角极简角标（如 `01` 或 `01/24`） | §5.2 |
| 右侧操作栏角色头像 | AI 生成，每剧 1 张，记录在 `docs/ASSET_LICENSES.md` | §5.3 |
| 多指连击阈值 | 双档：N≥10 完美连击、N≥20 神级连击 | §5.5 |
| ML 模型自由画布范围 | 全屏 | §5.6 |
| ML 模型类别数 | 5 类，不扩展 | §5.6、§6.2 |
| 施法模式 UX 语言 | 半显式游戏化，flavor 文案藏 "TFLite Runtime" 等技术标识 | §5.6 |
| ML 置信度阈值 | 默认 `[0.7, 0.4]`，模型训练后用真机评估集校准 | §5.6、§6.2 |
| 模型集成顺序 | Stub 优先（启发式实现），TFLite 模型作为后续 swap 项；接口 `GestureClassifier` 锁定 | §5.6、§6.2 |
| v0.1 / v0.2 推进模式 | 并行推进，互不阻塞；硬前置仅真机黑屏诊断 | §2 |

## 14. 训练后校准项

以下事项需在实际训练或真机评估完成后回头微调，但不影响计划启动：

- ML 模型置信度阈值的最终值（基于实际 confidence 分布曲线）
- 模型推理在主测设备上的实测延迟，决定是否需要进一步量化或换 backbone
- 施法模式画布的笔画粗细 normalize 系数（基于训练样本与用户实际触屏差异）
- 5 类手势在剧集场景中的实际触发频率分布（决定是否要调整 highlight 数据中的施法激活率）
