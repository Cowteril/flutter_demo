# Implementation

## Changed Files

- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/ai_companion_overlay.dart`
- `client/test/widget_test.dart`

## Summary

- Increased `AiCompanionOverlay.toolbarReserveWidth` from `82` to `124`.
- Added `AiCompanionOverlay.bottomReserveHeight`.
- Recomputed default companion position using `petSize`, toolbar reserve, and bottom reserve.
- Updated drag clamping to enforce the same right/bottom safe areas.
- Added widget assertions to ensure the default companion position stays outside the reserved right and bottom areas.
