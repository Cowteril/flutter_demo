# Plan

## Goal

Bring the v0.1 Android demo closer to the plan's acceptance checklist by fixing visible polish issues and re-running verification.

## Non-goals

- No v0.2 feature work.
- No broad redesign of the list page or design system.
- No dependency upgrades beyond what is required to keep the existing v0.1 implementation working.

## Assumptions

- The prior implementation already added `video_player`, the test MP4 asset, effect widgets, and immersive player structure.
- The next useful work is polish and validation rather than creating another major feature slice.

## Tasks

- Inspect the current implementation against the v0.1 plan.
- Fix user-visible mojibake strings and branch/effect feedback behavior.
- Add focused widget coverage where feasible without relying on native video playback.
- Run formatting, static analysis, tests, and debug APK build if local tooling permits.
- Record reviewer and tester gates.

## Role Split

- Supervisor: scope control, integration, final verdict.
- Researcher: read-only plan/code gap scan.
- Coder: local supervisor implementation for tightly coupled polish.
- Reviewer: inspect final diff against ACs.
- Tester: run verification commands and report reproducible output.

## Acceptance Criteria

- AC-001: App/list/player visible Chinese copy is readable UTF-8, not mojibake.
- AC-002: Player feedback distinguishes normal effect feedback from branch-route feedback and does not let old branch state overwrite later effects.
- AC-003: v0.1 controls remain intact: play/pause, seek, highlight markers, double-tap effect layer, option-triggered effects.
- AC-004: Focused tests cover the readable list copy and branch/effect feedback behavior where practical.
- AC-005: `dart format`, `flutter analyze`, and `flutter test` pass; `flutter build apk --debug` is attempted and recorded.
- AC-006: Reviewer has no blocking findings; tester verdict is pass or the final verdict states residual risk.

## Risks

- Native `video_player` behavior cannot be fully visually verified in widget tests.
- True device visual QA may remain unrun if no device/emulator is available.

## Open Questions

- None. Continue with conservative polish within v0.1.
