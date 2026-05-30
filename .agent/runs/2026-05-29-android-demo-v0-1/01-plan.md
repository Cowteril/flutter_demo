# Plan

## Goal

Implement Demo v0.1 from the plan with a focused single-player interactive chain.

## Non-goals

- Do not implement v0.2 features.
- Do not introduce backend services.
- Do not depend on copyrighted video assets.

## Assumptions

- `video_player` can be resolved with `flutter pub get`.
- A generated 20-second test video is acceptable for v0.1.
- Mock data can be adjusted to match the short test video duration.

## Tasks

1. Add `video_player` and asset video registration.
2. Generate a lightweight test MP4 under `client/assets/videos/`.
3. Add effect model and effect layer.
4. Add heart burst, shockwave, heart, text fly, and generic particle effects.
5. Update interaction options with `EffectType`.
6. Replace player layout with immersive Stack structure and asset-video support.
7. Add visual highlight timeline.
8. Add branch feedback and option-triggered effects.
9. Run formatter, analyzer, and tests.

## Role Split

- Supervisor: local implementation and integration.
- Planner: scope captured in this artifact.
- Researcher: current code read directly from repository.
- Coder: local implementation in assigned modules.
- Reviewer: final diff review after implementation.
- Tester: run Flutter verification commands and record results.

## Acceptance Criteria

- AC-001: App resolves `video_player` and declares `assets/videos/`.
- AC-002: A lightweight test video asset exists and mock dramas point to it.
- AC-003: Player page uses an immersive Stack with video/mock stage, gesture layer, effect layer, interaction layer, and bottom HUD.
- AC-004: Double-tap on the player triggers a visible heart burst effect.
- AC-005: Selecting interaction options triggers effects based on `EffectType`.
- AC-006: Highlight timeline shows visual markers and supports jumping.
- AC-007: Branch option selection shows visible route feedback.
- AC-008: System UI is hidden in player and restored on dispose.
- AC-009: `dart format`, `flutter analyze`, and relevant tests pass, or failures are recorded with reasons.

## Risks

- `video_player` may not work in widget tests without a platform mock.
- Android emulator may be unavailable in the current environment.
- `ffmpeg drawtext` is unstable on this Windows image; avoid font-dependent generation.

## Open Questions

- Whether to keep generated MP4 in git or replace later with a lighter real content sample.
