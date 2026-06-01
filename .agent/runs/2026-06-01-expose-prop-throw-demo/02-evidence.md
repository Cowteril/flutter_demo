# Evidence

## Code Findings

- `DramaPlayerPage` only rendered `PropThrowPanel` when `_activeHighlight` was non-null.
- `_activeHighlight` only returns a high-light inside the 5 second interaction window and after prediction filtering.
- This made the prop entry easy to miss during normal playback, especially before the interaction overlay appears.
- `PropThrowPanel` was positioned near the top-right, where it could visually compete with top overlays.

## Source Files Read

- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/prop_throw_panel.dart`
- `client/lib/features/drama/data/mock_drama_repository.dart`
- `client/lib/features/drama/data/local_video_asset_catalog.dart`
- `client/test/widget_test.dart`
