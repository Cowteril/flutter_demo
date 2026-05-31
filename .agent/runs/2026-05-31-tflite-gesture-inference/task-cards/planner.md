# Planner Task Card

Role: Planner

Run directory: `.agent/runs/2026-05-31-tflite-gesture-inference/`

Task: define acceptance criteria for swapping the visible gesture demo from heuristic-only to TFLite-backed recognition.

Allowed files: read-only.

Acceptance criteria:

- AC1: dependency can be added after Developer Mode.
- AC2: model and labels load from Flutter assets.
- AC3: preprocessing matches model shape.
- AC4: output maps to five classes.
- AC5: fallback remains available.
- AC6: player manages classifier lifecycle.
- AC7: Android build passes.
- AC8: verification commands pass.

Expected artifact: `01-plan.md`
