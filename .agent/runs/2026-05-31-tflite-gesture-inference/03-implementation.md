# Implementation

## Changed Files

- `client/pubspec.yaml`
- `client/pubspec.lock`
- `client/windows/flutter/generated_plugins.cmake`
- `client/android/app/build.gradle.kts`
- `client/android/build.gradle.kts`
- `client/lib/features/player/domain/gesture_classifier.dart`
- `client/lib/features/player/domain/models/gesture_spell.dart`
- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/gesture_spell_overlay.dart`

## Behavior

- Added `TfliteGestureClassifier`.
- Loads model and label assets.
- Validates `[1, 64, 64, 1]` int8 input and `[1, 5]` output.
- Rasterizes drawn points into a 64 x 64 grayscale bitmap with padding.
- Quantizes pixels using input tensor scale/zero point.
- Dequantizes output scores for confidence and maps output index through labels.
- Falls back to `HeuristicGestureClassifier` if the interpreter cannot load or inference fails.
- Player prewarms classifier in `initState` and closes it in `dispose`.
- Overlay now awaits async classification and shows `识别中`.

## Android Build Fix

- Set app Java/Kotlin target to JVM 11.
- Configure Android library subprojects and Kotlin Android subprojects to JVM 11.

## Deferred

- Isolate inference.
- Target-phone latency and accuracy calibration.
