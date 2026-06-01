# Plan

## Acceptance Criteria

- AC-001: Filter chip labels remain readable in selected and unselected states.
- AC-002: Homepage still shows search, featured recommendations, and all-drama browsing.
- AC-003: The all-drama/search-results section has an explicit header and count.
- AC-004: Existing homepage navigation and search tests still pass.
- AC-005: Static analysis and whitespace checks pass.

## Tasks

- Update `ChoiceChip` state colors using `WidgetStateProperty` to prevent theme fallback to white.
- Add a compact section header before the full list.
- Run `dart format`, Flutter analyze, Flutter test, and `git diff --check`.
- Record review/test gates.

## Role Split

- Planner: Supervisor.
- Researcher: Supervisor inspected screenshot and homepage code.
- Coder: Supervisor.
- Reviewer: Sub-agent.
- Tester: Sub-agent plus supervisor verification.
