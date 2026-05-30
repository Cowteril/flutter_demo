# Brief

## User Request

按照 `docs/ANDROID_DEMO_V0.1_EFFECTS_POLISH_PLAN.md` 继续做特效更新。

## Goal

完成阶段 1：引入并使用 `flutter_animate` 与 `confetti`，增强现有播放器的高频/中频互动反馈观感，同时保持 Android Demo v0.1 的播放与互动链路稳定。

## Constraints

- 范围限定在阶段 1 代码动效增强。
- 不启动 AI sprite、shader、Rive、Lottie 或音效阶段。
- 不泄露任何 API key、token 或私有配置。
- 继续遵循 `.agent` 多 agent 工作流，记录 reviewer/tester gate。
- 若 GitHub 网络不可达，不做强制上传或反复重试。

## Target Files Or Areas

- `client/pubspec.yaml`
- `client/pubspec.lock`
- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/interaction_overlay.dart`
- `client/lib/features/player/presentation/widgets/effects/*.dart`

## Out Of Scope

- AI 生成粒子贴图与素材记录。
- Fragment shader 招牌镜头。
- 分支选择 Rive 动画。
- 音效与音效开关。
- 竖滑 Feed、热力图、多指连击等 v0.2 范围。
