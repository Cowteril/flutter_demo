# Evidence

## Existing Code Observations

- `DuanjuApp` previously set `DramaFeedPage` as `MaterialApp.home`, making vertical feed the first screen.
- `DramaFeedPage` owned its own `ProfileController`, so state would be reset if the new home page independently opened profile/player/feed.
- `LocalVideoAssetCatalog` and `DramaRepository` already provide the right data sources for home browsing.
- `DramaPlayerPage` already accepts an optional `ProfileController`, allowing home navigation to preserve profile and AI companion state.

## Requirement Mapping

- Browsing all dramas maps to a `CustomScrollView` home shell with featured cards and full browse list.
- Search maps to a `SearchBar` backed by a `TextEditingController`.
- Existing vertical swipe mode remains available via a dedicated icon button that pushes `DramaFeedPage`.
- State sharing maps to injecting the same `ProfileController` into `DramaPlayerPage`, `ProfilePage`, and `DramaFeedPage`.
