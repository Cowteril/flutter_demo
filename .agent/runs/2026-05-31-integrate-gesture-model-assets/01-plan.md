# Plan

## Acceptance Criteria

- AC1: `gesture_classifier.tflite` is available at `client/assets/models/gesture_classifier.tflite`.
- AC2: Label mapping is available at `client/assets/models/gesture_labels.json`.
- AC3: Training evidence is preserved under `docs/model_runs/20260531-034301/`.
- AC4: `client/pubspec.yaml` declares `assets/models/`.
- AC5: Tests verify the model asset is loadable and stays below the 5 MB v0.2 target.
- AC6: Format, analyze, tests, and debug APK build pass.

## Steps

1. Inspect source export contents and metrics.
2. Move runtime files into app assets.
3. Move training evidence into docs.
4. Update Flutter asset config and tests.
5. Run verification.
6. Review and record final verdict.
