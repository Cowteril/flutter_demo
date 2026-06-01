# Plan

## Goal

Reduce the bottom HUD from multiple stacked progress/control rows to a compact layout.

## Tasks

- Replace the separate `HighlightTimeline` plus slider/time rows with one merged progress rail.
- Render high-light points as small tappable markers on the same progress rail.
- Keep play, feature settings, hide/show controls, and timecode in one compact row.
- Add a regression assertion so the old separate `HighlightTimeline` is not rendered in the player HUD.
- Run format, analyze, test, and diff whitespace checks.

## Acceptance Criteria

- AC-001: Bottom HUD no longer renders the old standalone `HighlightTimeline`.
- AC-002: Bottom HUD still renders one seek slider and supports highlight marker jumps.
- AC-003: Play, settings, hide/show, and timecode remain available in the compact row.
- AC-004: Hide-all behavior still hides feature icons and keeps only the restore control.
- AC-005: Static analysis and widget tests pass.

## Risks

- This is a behavior/layout-level fix verified by widget tests, not a pixel-perfect screenshot comparison.

## Role Split

- Planner: define acceptance criteria.
- Researcher: inspect screenshot and current HUD implementation.
- Coder: modify bottom HUD and tests.
- Reviewer: inspect final diff.
- Tester: run verification commands.
