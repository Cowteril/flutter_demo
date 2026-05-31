# Brief

## User Request

Implement the v0.3 short-drama UI shell using a maintainable open-source
short-video feed pattern. For the demo, play the local short-drama videos
directly. In the real product, the frontend will receive video sources from a
backend.

## Goal

Replace the list-first home screen with a vertical short-video feed that can
discover local demo assets, play each video with the existing interactive
player, and fall back to the existing mock feed when local assets are absent.

## Constraints

- Do not commit or push copyrighted video files.
- Keep the local video source replaceable by a backend repository later.
- Reuse the existing interactive player and v0.2 gesture/effect behavior.
- Record the open-source reference and license.

## Target Files Or Areas

- `client/lib/features/feed/`
- `client/lib/features/drama/data/local_video_asset_catalog.dart`
- `client/lib/app/duanju_app.dart`
- `scripts/sync-local-videos.ps1`
- local asset configuration and ignore rules

## Out Of Scope

- Backend API implementation.
- Uploading or redistributing local short-drama videos.
- Importing an entire open-source app or its Firebase backend.
