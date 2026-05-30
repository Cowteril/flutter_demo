# Evidence

## Sources

- `docs/ANDROID_DEMO_V0.1_EFFECTS_POLISH_PLAN.md`
- `client/lib/features/player/presentation/widgets/effects/heart_burst_effect.dart`
- `client/lib/features/player/presentation/widgets/effects/text_fly_effect.dart`
- `client/lib/features/player/presentation/widgets/effects/generic_particle_effect.dart`
- `client/lib/features/player/presentation/widgets/effects/particle_effect.dart`
- `client/lib/features/player/presentation/widgets/interaction_overlay.dart`
- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/test/widget_test.dart`

## Findings

- 阶段 1 明确要求引入 `flutter_animate` 与 `confetti`，强化爱心、文字飞出、互动弹层和选项反馈。
- `pubspec.yaml` 已加入 `flutter_animate: ^4.5.2` 与 `confetti: ^0.8.0`，`pubspec.lock` 已解析。
- 现有 `EffectLayer` 支持多条临时特效并按 duration 自动移除，适合继续承载阶段 1 动效。
- `drama_player_page.dart` 已有 `_EffectToast` 和 `_triggerOptionEffect`，可在不改交互链路的情况下增强视觉反馈。
- 研究 agent 提醒：不要让选项按压反馈延迟业务选择；`confetti` 需要控制粒子数量并释放 controller。

## Decisions

- 不新增素材，不触碰 AI sprite/license 文档。
- `confetti` 只用于 `EffectType.candy`，避免所有情绪特效同时引入高粒子负载。
- 选项按压反馈使用 `Listener + AnimatedScale`，不延迟 `onSelect`。
- `flutter_animate` 在 `drama_player_page.dart` 使用 `hide EffectEntry` 规避本地模型命名冲突。
