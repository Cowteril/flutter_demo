# Implementation

## Changed Files

- `client/pubspec.yaml`
- `client/pubspec.lock`
- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/interaction_overlay.dart`
- `client/lib/features/player/presentation/widgets/effects/heart_burst_effect.dart`
- `client/lib/features/player/presentation/widgets/effects/text_fly_effect.dart`
- `client/lib/features/player/presentation/widgets/effects/generic_particle_effect.dart`
- `client/lib/features/player/presentation/widgets/effects/particle_effect.dart`

## Notes

- 新增 `flutter_animate` 与 `confetti` 依赖。
- `HeartBurstEffect` 改为以点击点为中心定位，增加 220px 爆发画布、中心心形脉冲、分层粒子和延迟 sparkle。
- `ParticleBurst` 新增稳定尺寸和居中 Stack，避免粒子从点击点右下角偏移。
- `TextFlyEffect` 增加弹性入场、上浮退出、轻微旋转和 shake。
- `GenericParticleEffect` 改为确定性随机粒子扩散，增加二级色、高光阴影，并为 `EffectType.candy` 叠加短时 `ConfettiWidget`。
- `InteractionOverlay` 改为 stateful，增加弹层入场、选项 stagger 入场、选项按压缩放反馈。
- `_EffectToast` 增加淡入、弹性缩放和轻微 shake。
- 保持现有播放器播放/暂停、seek、高光处理和反馈替换逻辑不变。

## Residual Risk

- 尚未做真机/模拟器视觉 QA，无法完全确认 confetti 在目标设备上的肉眼效果和帧率。
- `video_player_android` 仍有 KGP 未来兼容警告，属于既有依赖警告。
