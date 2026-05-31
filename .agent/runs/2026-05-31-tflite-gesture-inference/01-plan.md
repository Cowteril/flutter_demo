# Plan

## Acceptance Criteria

- AC1: `tflite_flutter` is added successfully after Developer Mode is enabled.
- AC2: `TfliteGestureClassifier` loads `assets/models/gesture_classifier.tflite` and `gesture_labels.json`.
- AC3: Input preprocessing follows the 64 x 64 grayscale single-channel model contract.
- AC4: Output labels map to `lightning`, `fire`, `sword`, `snowflake`, and `star`.
- AC5: Interpreter load/inference failure falls back to the heuristic classifier.
- AC6: Player prewarms and disposes the classifier.
- AC7: Android debug APK builds with the plugin.
- AC8: Format, analyze, tests, and build pass.

## Implementation Order

1. Add dependency.
2. Convert classifier interface to async.
3. Add TFLite implementation and fallback.
4. Wire player and overlay.
5. Resolve Android Gradle JVM target compatibility.
6. Verify.

## Risks

- Windows widget tests do not have the TFLite native DLL; this must be a non-fatal fallback path.
- Real accuracy still requires phone-side gesture sampling and threshold calibration.
