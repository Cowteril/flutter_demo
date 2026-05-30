# Evidence

## Sources

- `docs/ANDROID_DEMO_V0.2_PLAN.md`
- `docs/GESTURE_MODEL_TRAINING_NOTES.md`
- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/android/app/src/main/AndroidManifest.xml`
- local `video_player` and `video_player_android` package cache

## Research Findings

- v0.2 plan marks true physical-device black-screen diagnosis as a hard prerequisite before Feed work.
- `video_player` 2.11.1 asset controllers default to `VideoViewType.textureView`.
- Local Flutter SDK supports Android manifest opt-out using `io.flutter.embedding.android.EnableImpeller=false`.
- The likely black-screen path is Android external video texture rendering with Impeller/Vulkan on the physical device.
- Physical device is not currently attached; only emulator is visible.
- Emulator is under memory pressure and not reliable for launch visual QA in this run.

## Decisions

- Keep `video_player` for now.
- Add Impeller opt-out and lifecycle/logging hardening first.
- Defer `VideoViewType.platformView` or `media_kit` migration until physical-device evidence requires it.
- Implement v0.2 data/product shell on the existing player before extracting Feed.
