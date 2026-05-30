# Brief

## User Request

根据 `docs/ANDROID_DEMO_V0.1_PLAN.md` 开始编码，实现 Android 短剧互动 Demo v0.1。

## Goal

完成核心播放器和基础互动特效链路：真实视频播放、沉浸式播放器 UI、双击爱心、高光触发条、互动选项粒子特效、分支选择反馈，并能通过 Flutter 静态检查和基础测试。

## Constraints

- Android 优先，基于现有 Flutter 项目。
- 后端暂不实现，使用 mock 数据和本地 asset 视频。
- 保留 mock 舞台回退，避免视频依赖阻塞特效链路。
- 不复制任何第三方 App 的具体视觉资产和品牌设计。
- 不回退用户已有改动。

## Target Files Or Areas

- `client/pubspec.yaml`
- `client/assets/videos/`
- `client/lib/features/drama/**`
- `client/lib/features/player/**`
- `client/test/**`

## Out Of Scope

- 竖滑 Feed
- 情绪热力图
- 多指连击
- 画手势施法
- 摇一摇加油
- 右侧操作栏
- 后端接口
