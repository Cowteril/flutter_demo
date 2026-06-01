# Evidence

## Question

Where should the requested profile and gamification features be integrated?

## Findings

- The feed is the shared parent for vertically swiped dramas, so it owns the demo-wide `ProfileController` and the personal profile entry.
- `DramaPlayerPage` owns playback position, highlight visibility, side actions, seeking, and option selection, so prediction eligibility and character actions belong there.
- `HighlightPoint.kind` needed a new `prediction` kind so prediction UI can reuse the existing highlight mechanism.
- Existing widget tests already exercise feed, player, highlights, side actions, and gesture overlay, making them the right place for regression coverage.

## Evidence Table

| Claim | Evidence | Source | Confidence | Impact |
| --- | --- | --- | --- | --- |
| Feed can share profile state across player pages and profile page. | `DramaFeedPage` builds `PageView` and each `DramaPlayerPage`. | `client/lib/features/feed/presentation/drama_feed_page.dart` | High | Put shared controller and profile route in feed. |
| Player can enforce prediction eligibility. | Player controls `_position`, `_seek`, `_activeHighlight`, and `_selectOption`. | `client/lib/features/player/presentation/drama_player_page.dart` | High | Eligibility checks and disqualification hooks belong in player. |
| Highlight kinds are centralized. | `HighlightKind` enum is used by interaction overlay and timeline. | `client/lib/features/drama/domain/models/highlight_point.dart` | High | Add `prediction` to the enum and handle it in switches. |
| Mock/local demos are driven by local data sources. | Mock repository and local catalog create `Drama.highlights`. | `client/lib/features/drama/data/mock_drama_repository.dart`, `client/lib/features/drama/data/local_video_asset_catalog.dart` | High | Add prediction points there. |
| Tests can validate feature behavior. | Existing tests pump `DramaFeedPage` and `DramaPlayerPage`. | `client/test/widget_test.dart` | High | Add focused widget tests for profile, prediction, and character flows. |

## Risks

- In-memory state is appropriate for a demo but not production persistence.
- TFLite Windows native library is unavailable in test logs, but the classifier already falls back and tests pass.

## Recommended Next Steps

- Implement with a profile controller and existing highlight/side-action surfaces.
- Keep reward status pending until backend answer settlement exists.
