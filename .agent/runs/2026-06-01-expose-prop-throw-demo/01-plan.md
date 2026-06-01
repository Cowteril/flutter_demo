# Plan

## Goal

Expose prop throwing earlier and more visibly in the player demo.

## Tasks

- Add a prop-throw availability window before each high-light point.
- Render the prop panel based on the prop window, not only the active interaction overlay.
- Move the prop panel to the right-side toolbar area and add a visible `扔道具` label.
- Add a regression test confirming the panel appears before an upcoming high-light.
- Run format, analyze, tests, and diff whitespace checks.

## Acceptance Criteria

- AC-001: Prop panel is visible before an upcoming high-light without requiring the interaction overlay to be active.
- AC-002: Prop panel still only appears near configured high-light points.
- AC-003: Panel is visually discoverable with a `扔道具` label and glove/flower/egg buttons.
- AC-004: Selecting a prop still triggers the existing prop effect path.
- AC-005: Feature hide-all and feature settings still govern visibility.
- AC-006: Static analysis and tests pass.

## Risks

- Exact on-device positioning is not pixel-golden tested.
- The lead window is demo-oriented and may need backend tuning later.

## Role Split

- Planner: define acceptance criteria.
- Researcher: inspect current prop trigger condition and panel position.
- Coder: update prop window, panel, and tests.
- Reviewer: inspect final diff.
- Tester: run verification.
