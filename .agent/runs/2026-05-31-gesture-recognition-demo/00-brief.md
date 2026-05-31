# Brief

## Request

User reported that the gesture recognition demo is not visible on device.

## Scope

- Add a visible gesture-casting entry point in the player.
- Add a drawable gesture overlay.
- Add a deterministic recognition path that works without system-level Windows Developer Mode.
- Add dot-pattern fallback for low-confidence recognition.
- Trigger existing effect layer and feedback text from recognized gestures.

## Constraints

- Do not leak API keys, tokens, or private credentials.
- Keep this slice demonstrable on the current local environment.
- Do not leave a partially installed `tflite_flutter` dependency if Flutter cannot validate it locally.

## Non-goals

- Full TFLite interpreter integration.
- Isolate-based inference.
- Physical-device latency measurement.
