# Test Report

## Commands Run

- `C:\Users\niuwe\flutter\bin\cache\dart-sdk\bin\dart.exe format --output=none --set-exit-if-changed lib test`
- `C:\Users\niuwe\flutter\bin\cache\dart-sdk\bin\dart.exe C:\Users\niuwe\flutter\packages\flutter_tools\bin\flutter_tools.dart analyze`
- `C:\Users\niuwe\flutter\bin\cache\dart-sdk\bin\dart.exe C:\Users\niuwe\flutter\packages\flutter_tools\bin\flutter_tools.dart test`
- `C:\Users\niuwe\flutter\bin\cache\dart-sdk\bin\dart.exe C:\Users\niuwe\flutter\packages\flutter_tools\bin\flutter_tools.dart build apk --debug`

## Results

- Format: PASS, 26 files checked, 0 changed.
- Analyze: PASS, no issues found.
- Flutter test: PASS, 7 tests passed.
- Android debug APK build: PASS.

## APK

- `client/build/app/outputs/flutter-apk/app-debug.apk`

## Warnings

- 7 packages have newer versions incompatible with dependency constraints.
- `video_player_android` still emits the Kotlin Gradle Plugin future compatibility warning.
- Windows widget tests log missing `libtensorflowlite_c-win.dll`; this is expected and covered by fallback behavior.

## Verdict

PASS.
