# Plan

## Goal

Validate and finalize v0.4 product-feed changes that make the demo behave more like a short-drama app: immersive vertical feed, current-item playback control, cleaner overlays, tablet-safe framing, and expanded widget tests.

## Non-goals

- No new network backend.
- No public upload of local media.
- No unrelated visual redesign outside the feed/player surface.

## Assumptions

- The existing local/mock drama repositories remain the data source for this iteration.
- Real video playback may fall back to mock playback in widget tests and in environments without packaged local assets.
- Device manual QA is useful but can be recorded as residual risk if the connected device is unavailable.

## Tasks

- T-001: Confirm working tree scope and branch.
- T-002: Record stable acceptance criteria and role task cards.
- T-003: Review final diff against product-feed requirements.
- T-004: Run format, analyze, tests, debug APK build, and safety scans.
- T-005: Update run artifacts with implementation, review, test report, and final verdict.
- T-006: If all gates pass, commit `feat: improve product feed playback experience` and push `codex/v0.4-product-feed`.

## Role Split

- Supervisor: owns scope, artifact completion, gate integration, commit/push decision.
- Planner: maps requirements to AC IDs and task cards.
- Researcher: gathers code evidence, screenshots, command outputs, and safety scan evidence.
- Coder: owns the feed/player/test code edits already present in the working tree.
- Reviewer: performs read-only final diff review.
- Tester: runs reproducible verification commands and reports results.

## Acceptance Criteria

- AC-001: Feed presents a productized vertical surface with top tabs, source/progress pill, empty state, refresh path, and immersive system UI management.
- AC-002: Feed uses a vertical `PageView` with current index tracking; active page autoplays while inactive pages pause, and `TickerMode` limits ticking to current/nearby pages.
- AC-003: Wide/tablet layouts constrain feed playback to a centered 9:16 viewport with black side margins instead of stretching horizontally.
- AC-004: `DramaPlayerPage` supports feed embedding controls: `isActive`, `autoPlay`, `manageSystemUi`, `showTopBar`, and `feedPositionLabel`.
- AC-005: Inactive embedded players stop video/mock playback and close the gesture overlay; gesture overlay hides HUD, side bar, emotion temperature, and interaction layers.
- AC-006: Bottom HUD avoids the right action rail, and the audience heat badge avoids title/HUD overlap.
- AC-007: Right-side action buttons expose one shared 64x66 clickable area for icon and label.
- AC-008: Widget tests cover feed source/progress chrome, swipe progress updates, wide 9:16 viewport, inactive mock playback, active auto-advance, and overlay-hidden layers.
- AC-009: Verification commands are recorded and pass, or failures are clearly documented.
- AC-010: Secret/media scans show no staged forbidden media and no committed secrets introduced by this change.

## Risks

- Manual device QA can be limited by USB/device instability.
- Widget tests validate layout and mock playback but cannot fully replace real video/device gesture QA.
- Existing generated/build output may contain terms such as "password" in platform build scripts; scans must be interpreted against source changes and excluded build folders.

## Open Questions

- None blocking at planning time.
