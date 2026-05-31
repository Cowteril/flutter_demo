# Implementation

## Changed Files

- `client/lib/features/player/domain/models/gesture_spell.dart`
- `client/lib/features/player/domain/gesture_classifier.dart`
- `client/lib/features/player/presentation/widgets/gesture_spell_overlay.dart`
- `client/lib/features/player/presentation/widgets/side_action_bar.dart`
- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/test/widget_test.dart`

## Behavior

- Replaced the right-side episode action with a visible `施法` action using `Icons.auto_fix_high`.
- Added full-screen `GestureSpellOverlay` with drawing canvas, glowing stroke rendering, recognition result panel, clear action, and close action.
- Added `HeuristicGestureClassifier` for immediate demo recognition.
- Added `DotPatternGestureClassifier` with deterministic spell paths.
- Low-confidence drawing results reveal a 3x3 dot-pattern fallback panel.
- Accepted gesture results trigger existing player feedback, emotion boost, and effect layer animations.

## Tests Added

- Dot-pattern fallback recognizes the sword spell path `[1, 5, 9]`.
- Player side action opens the gesture casting overlay.

## Deferred

- `tflite_flutter` integration is deferred until Windows Developer Mode/symlink support is enabled.
- The bundled `.tflite` model remains available for the next swap-in slice.
