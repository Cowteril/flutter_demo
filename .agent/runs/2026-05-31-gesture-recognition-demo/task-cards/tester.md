# Tester Task Card

Role: Tester

Run directory: `.agent/runs/2026-05-31-gesture-recognition-demo/`

Task: verify the gesture demo slice.

Commands:

- `dart format --output=none --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`

Expected output:

- Exact pass/fail results.
- Warnings.
- APK path if build succeeds.
