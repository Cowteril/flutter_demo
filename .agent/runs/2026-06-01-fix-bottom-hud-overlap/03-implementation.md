# Implementation

## Changed Files

- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/test/widget_test.dart`

## Summary

- Removed the standalone `HighlightTimeline` from `_BottomHud`.
- Added `_HudProgressRail`, which combines the seek slider with smaller tappable highlight markers on the same rail.
- Added `_HudHighlightDot` for compact high-light markers.
- Added `_HudTimecode` so current and total time sit in a compact vertical block at the end of the control row.
- Kept play, settings, hide/show, progress, and timecode in one row below the title/subtitle.
- Updated the existing bottom HUD widget test to assert the old `HighlightTimeline` is absent and only one `Slider` is rendered.
