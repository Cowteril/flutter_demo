# Evidence

## Screenshot Finding

The provided screenshot showed the bottom-left HUD with multiple stacked controls: title text, a standalone highlight timeline with large circular markers, playback/settings/hide icons, a second progress slider, and time labels. This crowded the bottom of the video and made the controls read as duplicated.

## Code Finding

`_BottomHud` in `client/lib/features/player/presentation/drama_player_page.dart` rendered:

- `HighlightTimeline`
- a row of control buttons
- a separate `Slider`
- a separate time row

That directly matched the screenshot problem.

## Source Files Read

- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/highlight_timeline.dart`
- `client/test/widget_test.dart`
