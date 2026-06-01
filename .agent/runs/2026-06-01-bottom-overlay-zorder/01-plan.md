# Plan

## Goal

Fix bottom-layer occlusion when `InteractionOverlay` is active.

## Non-goals

- Do not redesign the player chrome.
- Do not alter highlight timing or option selection behavior.

## Assumptions

- The screenshot's issue is caused by `_BottomHud` drawing after
  `InteractionOverlay` in the player `Stack`.
- The intended behavior is to keep the interaction card unobstructed while the
  user is choosing an option.

## Tasks

- Map requirements to acceptance criteria.
- Inspect player stack order and related widgets.
- Implement a scoped UI fix.
- Add a regression widget test.
- Run formatter and tests.
- Review final diff.

## Role Split

- Planner: supervisor records this plan and acceptance criteria.
- Researcher: inspect player stack order and evidence.
- Coder: implement only player/test changes.
- Reviewer: inspect final diff for regressions.
- Tester: run reproducible verification commands.

## Acceptance Criteria

- AC-001: When a highlight interaction card is visible, `_BottomHud` controls
  are not visible above or inside that card.
- AC-002: Highlight option selection still works and dismisses the card.
- AC-003: Normal playback with no active highlight still shows the bottom HUD.
- AC-004: Existing gesture spell mode still hides the bottom HUD and side
  actions.

## Risks

- Hiding bottom controls during a highlight changes seeking availability while
  an interaction prompt is open. This is acceptable because the prompt is the
  active interaction surface.

## Open Questions

- None.
