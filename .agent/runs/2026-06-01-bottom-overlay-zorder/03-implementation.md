# Implementation

## Summary

Hide the bottom playback HUD while a highlight interaction prompt is visible.
Move the prompt to the top of the player stack so it remains the foreground
surface until dismissed or an option is selected.

## Changed Files

- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/test/widget_test.dart`

## Behavior Changes

- `_BottomHud` now renders only when gesture spell mode is closed and no
  highlight prompt is active.
- `InteractionOverlay` now paints after the side action bar, so the prompt is
  the topmost non-gesture overlay when a highlight is active.
- Normal HUD rendering resumes immediately after the prompt is dismissed or an
  option is selected.

## Tests Added Or Updated

- Added `highlight interaction hides bottom controls while open`, covering HUD
  visibility while the prompt is open, restored HUD after option selection, and
  prompt stack order.

## Known Limitations

- Manual Android screenshot verification is not part of the automated widget
  test. The test verifies the relevant widget visibility state.
