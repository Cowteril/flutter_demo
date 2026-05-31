# Brief

## Request

User enabled Windows Developer Mode, so continue from the visible gesture demo and wire the bundled TFLite model into the gesture classifier.

## Scope

- Add `tflite_flutter`.
- Implement model-backed `GestureClassifier`.
- Keep heuristic recognition as runtime fallback.
- Preload the interpreter from the player.
- Fix Android build configuration required by the plugin.
- Verify tests and debug APK build.

## Constraints

- Do not leak API keys, tokens, or private credentials.
- Do not touch unrelated untracked `videos/`.
- Preserve dot-pattern fallback.
