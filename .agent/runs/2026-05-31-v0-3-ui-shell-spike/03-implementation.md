# Implementation

## Summary

Added a v0.3 vertical short-drama feed shell. The app uses locally synced demo
`.mp4` files as a temporary stand-in for a backend feed and renders each item
with the existing interactive `DramaPlayerPage`. Local metadata comes from an
ignored `assets/local_videos/catalog.json`, and catalog entries are filtered
against Flutter's `AssetManifest` so stale local metadata cannot point the
player at missing assets. If local assets are absent or discovery fails, the
feed falls back to mock dramas.

## Changed Files

- `.gitignore`
- `client/assets/local_videos/README.md`
- `client/lib/app/duanju_app.dart`
- `client/lib/features/drama/data/local_video_asset_catalog.dart`
- `client/lib/features/feed/presentation/drama_feed_page.dart`
- `client/pubspec.yaml`
- `client/test/widget_test.dart`
- `scripts/sync-local-videos.ps1`

## Behavior Changes

- The app opens directly into a vertically scrollable short-video feed.
- Local demo assets take precedence when available and are represented by flat
  `assets/local_videos/dramaXX_epYYY.mp4` asset paths.
- `catalog.json` stores local titles and episode numbers for demo builds while
  remaining ignored by Git.
- A source badge distinguishes local short-drama data from mock fallback data.
- The existing player remains responsible for video playback, effects, branch
  feedback, and gesture overlay behavior.
- `scripts/sync-local-videos.ps1` copies a limited local sample, defaults to
  the smallest episode per drama for APK size, supports episode-order selection,
  and guards the destination path before cleaning generated flat files.

## Tests Added Or Updated

- Updated the app-shell widget test to verify the vertical feed and player.
- Added a deterministic mock fallback widget test.
- Added catalog unit tests for asset-path conversion, flat metadata conversion,
  and stale catalog filtering.

## Known Limitations

- v0.3 uses local bundled assets for the demo; API-backed feed loading is
  intentionally deferred.
- The sync script copies a small episode sample for local builds only.
- APK size grows when local demo media is synced into Flutter assets.
- Manual device playback QA is still not recorded in this run.
