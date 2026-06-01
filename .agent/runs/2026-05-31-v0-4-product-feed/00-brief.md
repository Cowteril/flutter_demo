# Brief

## User Request

Continue the Flutter short-drama interactive Android demo toward a more mature productized short-drama app experience. Do not stop at a stage demo; keep improving the vertical feed, playback behavior, and mobile/tablet QA readiness.

## Goal

Ship the v0.4 product-feed iteration on branch `codex/v0.4-product-feed` with documented acceptance criteria, reviewed diff, reproducible verification, and safety checks before commit/push.

## Constraints

- Do not commit or expose API keys, secrets, passwords, or private keys.
- Do not upload `videos/`, local short-drama videos, `client/assets/local_videos/*.mp4`, `catalog.json`, or `.agent/tmp/`.
- Use `.agent/runs/2026-05-31-v0-4-product-feed/` as the persisted handoff surface.
- Reviewer and tester gates are mandatory for this non-trivial code change.
- Prefer tablet verification, especially Samsung SM_T733 / `R52W407WCQV`, when a device is available.

## Target Files Or Areas

- `client/lib/features/feed/presentation/drama_feed_page.dart`
- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/side_action_bar.dart`
- `client/lib/features/player/presentation/widgets/emotion_temperature_overlay.dart`
- `client/test/widget_test.dart`
- `.agent/runs/2026-05-31-v0-4-product-feed/`

## Out Of Scope

- Uploading or committing raw local video assets.
- Replacing the drama data model, repository architecture, or video catalog format.
- Adding real backend services, real authentication, or production analytics.
- Reworking unrelated UI flows outside feed/player.
