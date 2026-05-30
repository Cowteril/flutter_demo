# Plan

## Goal

用纯 Flutter 代码动效把当前播放器特效做厚一层，使双击爱心、情绪粒子、文字反馈、分支弹层的观感明显优于 v0.1 初版。

## Non-goals

不做 AI sprite、shader、Rive、音效，不改变播放器基础架构，不引入复杂资产审计流程。

## Assumptions

- `flutter_animate` 与 `confetti` 已可通过 pub 依赖解析。
- 当前播放器的 `EffectLayer` 生命周期仍是临时特效的统一承载点。
- 阶段 1 验收以静态分析、widget test、debug APK 构建和代码 review 为主，真机视觉 QA 后续单独做。

## Tasks

- T-001: 确认计划书阶段 1 验收范围。
- T-002: 增强 `HeartBurstEffect` 的中心弹性、脉冲和分层粒子。
- T-003: 增强 `TextFlyEffect` 的入场、上浮、旋转/抖动。
- T-004: 增强 `GenericParticleEffect`，并为撒糖类反馈叠加 `confetti`。
- T-005: 增强 `InteractionOverlay` 入场和选项按压反馈。
- T-006: 增强播放器反馈 toast 入场动效。
- T-007: 运行格式化、分析、测试、debug APK 构建。
- T-008: 完成 reviewer/tester gate 并记录 verdict。

## Role Split

- Planner: supervisor 根据计划书拆分阶段 1 任务和验收标准。
- Researcher: 子 agent 读取计划书和现有播放器特效文件，输出范围、风险和相关文件。
- Coder: supervisor 直接修改阶段 1 涉及文件。
- Reviewer: 子 agent 审查最终 diff，关注回归、性能和范围。
- Tester: 子 agent 复核验证命令；supervisor 也本地运行核心验证。

## Acceptance Criteria

- AC-001: `flutter_animate` 与 `confetti` 作为直接依赖存在并在代码中用于阶段 1 动效。
- AC-002: 双击爱心有居中爆发、中心弹性心形、脉冲和分层粒子。
- AC-003: 文字飞出反馈有弹性入场、上浮离场、轻微旋转或抖动。
- AC-004: 情绪粒子比初版更有层次，撒糖类反馈叠加轻量 `confetti`。
- AC-005: 高光互动弹层有入场动画，选项有可见按压反馈。
- AC-006: 反馈 toast 有更强的弹出节奏，不破坏现有反馈替换逻辑。
- AC-007: `flutter analyze` 通过。
- AC-008: `flutter test` 通过。
- AC-009: `flutter build apk --debug` 通过。
- AC-010: reviewer 无 blocking finding，tester verdict 为 pass 或 final verdict 明确风险。

## Risks

- `flutter_animate` 导出的 `EffectEntry` 可能与本地 `EffectLayer` 同名冲突。
- `confetti` 粒子过多会影响低端 Android 性能。
- 选项按压动画若延迟选择，可能破坏现有 widget test 和交互节奏。
- 多个双击爱心同时存在时需要保持轻量。

## Open Questions

- 真机/模拟器视觉 QA 尚未执行，需在后续阶段补一次录屏级检查。
