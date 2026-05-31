# Planner Task Card

Role: Planner

Run directory: `.agent/runs/2026-05-31-gesture-recognition-demo/`

Task: define the smallest useful gesture recognition demo slice.

Scope:

- Player-visible entry point.
- Drawing overlay.
- Heuristic recognizer and dot-pattern fallback.
- Tests and verification gates.

Allowed files: read-only.

Forbidden files: production code edits.

Acceptance criteria:

- AC1: visible cast entry.
- AC2: overlay opens.
- AC3: accepted result triggers effects.
- AC4: fallback appears for low confidence.
- AC5: fallback path is test-covered.
- AC6: no broken TFLite dependency remains.
- AC7: verification passes.

Expected artifact: `01-plan.md`
