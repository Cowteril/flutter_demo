# Plan

## Goal

Implement account-level AI companion selection.

## Tasks

- Add global unlocked AI companion list and selected companion ID to `ProfileController`.
- Auto-select the first character when it reaches the AI companion gift requirement.
- Add a settings selector that lists unlocked AI companions and selects exactly one.
- Change player companion availability to use the selected global character instead of the current drama character.
- Pass the selected character identity into AI companion script context.
- Update profile and character surfaces to show selected/unlocked state.
- Add tests for cross-drama companion usage and settings selection.

## Acceptance Criteria

- AC-001: A character unlocked in one drama can be used as AI companion while watching another drama.
- AC-002: Current drama's own character does not need to be unlocked for the selected AI companion to appear.
- AC-003: Settings lists unlocked AI companion characters and selecting one updates the global selected character.
- AC-004: Only one selected companion ID is active at a time.
- AC-005: Player uses the selected character name/persona in the companion overlay and context.
- AC-006: Existing AI companion, feature settings, hide-all, and prop behavior keep passing tests.
- AC-007: Format, analyze, test, and whitespace checks pass.

## Risks

- Selection is in-memory demo state; persistence is a future backend/client storage task.
- The script catalog still uses local mock persona data rather than backend-provided role scripts.

## Role Split

- Planner: define AC-001 through AC-007.
- Researcher: inspect existing profile/player/settings coupling.
- Coder: update state, UI, player integration, and tests.
- Reviewer: inspect final diff against requirements.
- Tester: run verification commands.
