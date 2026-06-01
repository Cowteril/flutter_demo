# Plan

## Goal

Ship the AI companion demo slice end-to-end in the Flutter client.

## Non-goals

- No networked backend implementation.
- No authentication or durable user settings storage.
- No real episode catalog service beyond the local demo data model.

## Assumptions

- The demo can represent backend-provided AI script/persona/context data with local catalog classes.
- Existing `Drama.highlights` can stand in for current-episode segmented plot points.
- Gift count is enough to model the unlock rule for now.

## Tasks

- Add AI companion script/domain models and a local script catalog.
- Extend profile state with AI companion unlock and feature settings.
- Add draggable Q-style companion overlay with role-aware reactions.
- Add prop picker and visual throw effects for active highlights.
- Integrate companion, prop, settings, and hide-all controls into `DramaPlayerPage`.
- Update side action bar to compactly omit disabled actions.
- Add regression tests for context gating, unlocks, settings, hide-all, and prop effects.

## Role Split

- Planner: map user requirements to AC-001 through AC-008.
- Researcher: inspect current player/profile/highlight architecture and identify integration points.
- Coder: implement scoped Flutter changes in player/profile/companion modules and tests.
- Reviewer: inspect final diff against acceptance criteria; no edits.
- Tester: run formatting/analyze/test verification; no edits.

## Acceptance Criteria

- AC-001: AI companion unlocks only after the favorite character receives the configured gift count, and the unlock is visible in character/profile surfaces.
- AC-002: AI companion script data includes role positioning, persona, previous episode summaries, per-highlight before-story, dialogue, and prop target coordinates in reusable domain/catalog structures.
- AC-003: Player shows a Q-style draggable companion when the feature is enabled and the character is unlocked; it defaults near the lower right, remains below the right toolbar footprint, and reacts to taps/player actions.
- AC-004: At a highlight trigger, the companion receives previous-episode summaries plus only current-episode plot before that highlight, never later highlight content.
- AC-005: Near active highlights, a prop panel offers glove, flower, and egg choices; selecting a prop renders target-based effects, and the companion participates with matching pose/dialogue.
- AC-006: Feature settings allow social actions, character favorability, AI companion, prop throwing, and gesture cast to be toggled; disabled right-side actions compact without empty gaps.
- AC-007: Bottom HUD can hide all feature icons except the restore visibility control.
- AC-008: `dart format`, `flutter analyze`, and `flutter test` pass.

## Risks

- Current data is local demo data; backend schema and persistence will need a later integration pass.
- Visual effects are Flutter-painted demo effects, not production asset animations.
- Widget tests cover behavior gates, not pixel-perfect animation paths.

## Open Questions

- None blocking for the demo implementation.
