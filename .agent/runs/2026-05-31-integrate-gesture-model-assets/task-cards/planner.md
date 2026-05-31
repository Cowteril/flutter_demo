# Planner Task Card

Role: Planner

Run directory: `.agent/runs/2026-05-31-integrate-gesture-model-assets/`

Task: define acceptance criteria for moving the completed gesture model export into the Flutter project.

Scope:

- Runtime model assets.
- Training/export evidence archive.
- Flutter asset declaration.
- Verification expectations.

Allowed files: read-only.

Forbidden files: production code edits.

Inputs:

- `00-brief.md`
- `docs/ANDROID_DEMO_V0.2_PLAN.md`
- `docs/GESTURE_MODEL_TRAINING_NOTES.md`

Acceptance criteria:

- AC1: runtime model is in `client/assets/models/gesture_classifier.tflite`.
- AC2: labels are in `client/assets/models/gesture_labels.json`.
- AC3: training evidence is archived under `docs/model_runs/20260531-034301/`.
- AC4: `client/pubspec.yaml` declares `assets/models/`.
- AC5: tests verify bundled asset loading and size target.
- AC6: format, analyze, tests, and APK build pass.

Expected artifact: `01-plan.md`
