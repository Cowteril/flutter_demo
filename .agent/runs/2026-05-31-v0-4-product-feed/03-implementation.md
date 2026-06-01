# Implementation

## Summary

Implemented v0.4 product-feed polish for the Flutter short-drama demo. The feed is now a product-like vertical playback surface with top chrome, source/progress state, active-item playback, wide/tablet viewport framing, and better overlay coexistence. Player embedding controls make the feed responsible for page-level playback while preserving standalone player behavior.

## Changed Files

- `client/lib/features/feed/presentation/drama_feed_page.dart`
- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/side_action_bar.dart`
- `client/lib/features/player/presentation/widgets/emotion_temperature_overlay.dart`
- `client/test/widget_test.dart`
- `.agent/runs/2026-05-31-v0-4-product-feed/*`

## Behavior Changes

- Feed page now enters immersive sticky system UI and restores edge-to-edge mode on dispose.
- Feed loading now supports empty state and retry.
- Feed renders vertical `PageView` content inside a centered 9:16 viewport on wide/tablet screens.
- Feed tracks current page index, displays `推荐 / 互动 / 追剧`, and shows source/progress such as `Mock · 1/3`.
- Feed embeds `DramaPlayerPage` with `isActive`, `autoPlay`, `manageSystemUi: false`, `showTopBar: false`, and a feed position label.
- Non-active player pages cancel mock playback, pause video controllers, and close the gesture overlay.
- Gesture spell overlay hides bottom HUD, side action bar, emotion temperature, and interaction overlay while open.
- Bottom HUD reserves 96px on the right to avoid the action rail.
- Audience heat badge moved upward to reduce tablet overlap.
- Side action buttons now make icon and label share one 64x66 opaque tap target.

## Tests Added Or Updated

- Updated feed fallback source assertion to `Mock · 1/3`.
- Added feed swipe progress update test.
- Added wide-screen 9:16 viewport constraint test.
- Added inactive feed player no mock-playback test.
- Added active feed player auto-advance test.
- Expanded gesture overlay test to assert hidden side action, emotion label, and slider/HUD.

## Known Limitations

- Widget tests cover mock playback and layout constraints; real video playback on tablet/phone still benefits from manual QA.
- The previously captured `qa-tablet-cast-overlay.png` may not prove the overlay opened because the tap coordinate may have missed the "施法" target.
