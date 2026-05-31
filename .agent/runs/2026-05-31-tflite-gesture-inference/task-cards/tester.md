# Tester Task Card

Role: Tester

Run directory: `.agent/runs/2026-05-31-tflite-gesture-inference/`

Task: verify TFLite gesture integration.

Commands:

- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`

Expected output:

- Exact pass/fail results.
- Known warnings.
- APK path if build succeeds.
