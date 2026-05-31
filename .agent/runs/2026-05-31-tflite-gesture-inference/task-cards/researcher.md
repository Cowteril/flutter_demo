# Researcher Task Card

Role: Researcher

Run directory: `.agent/runs/2026-05-31-tflite-gesture-inference/`

Task: inspect `tflite_flutter` local package APIs and Android build constraints.

Allowed files: read-only.

Inputs:

- Pub cache package `tflite_flutter-0.12.1`
- `client/android/`
- Existing model assets

Acceptance criteria:

- AC1: asset loading API is identified.
- AC2: tensor metadata APIs are identified.
- AC3: Android JVM target issue is documented.

Expected artifact: `02-evidence.md`
