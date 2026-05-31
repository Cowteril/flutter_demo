# Gesture Classifier Run 20260531-034301

## Purpose

This run provides the v0.2 gesture classifier assets for the Flutter Android demo.

Runtime assets copied into the app:

- `client/assets/models/gesture_classifier.tflite`
- `client/assets/models/gesture_labels.json`

Training and export evidence kept in this directory:

- `gesture_classifier.keras`
- `gesture_classifier_float32.tflite`
- `gesture_classifier_int8.tflite`
- `metrics.json`
- `confusion_matrix.csv`
- `training_log.csv`

## Model Contract

- Input: 64 x 64 grayscale gesture bitmap.
- Output labels:
  - `0`: `lightning`
  - `1`: `fire`
  - `2`: `sword`
  - `3`: `snowflake`
  - `4`: `star`
- Runtime model: int8 TFLite export.

## Metrics

- Dataset classes: `lightning`, `campfire` mapped to `fire`, `sword`, `snowflake`, `star`.
- Samples per class: 50,000.
- Total samples: 250,000.
- Train / validation / test split: 200,000 / 25,000 / 25,000.
- Epochs run: 29.
- Test accuracy: 96.48%.
- Int8 TFLite evaluation accuracy: 96.41% on 10,000 samples.
- Runtime model size: 112,616 bytes.
- Float32 TFLite size: 409,512 bytes.

## Integration Notes

The app currently bundles the model and labels as Flutter assets. The inference path is intentionally separate from this file move: the next implementation step should add the `GestureClassifier` abstraction, a TFLite-backed implementation, and the dot-pattern fallback described in `docs/ANDROID_DEMO_V0.2_PLAN.md`.
