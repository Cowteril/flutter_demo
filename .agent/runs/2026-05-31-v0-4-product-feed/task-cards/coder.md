# Coder Task Card

Role: Coder
Run directory: `.agent/runs/2026-05-31-v0-4-product-feed/`
Task: Implement the productized feed/player iteration and update focused widget tests.
Scope: Feed, player, side action, emotion overlay, and widget tests.
Allowed files:
- `client/lib/features/feed/presentation/drama_feed_page.dart`
- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/side_action_bar.dart`
- `client/lib/features/player/presentation/widgets/emotion_temperature_overlay.dart`
- `client/test/widget_test.dart`
- `.agent/runs/2026-05-31-v0-4-product-feed/03-implementation.md`
Forbidden files:
- `videos/**`
- `client/assets/local_videos/**`
- `catalog.json`
- `.agent/tmp/**`
- Unrelated modules outside assigned scope
Inputs:
- `00-brief.md`
- `01-plan.md`
- `02-evidence.md`
Constraints:
- Edit only assigned files or run artifacts.
- Do not revert other people's changes.
- Preserve standalone player defaults while adding feed embedding controls.
- Keep local media and secrets out of committed changes.
Acceptance criteria:
- AC-001 through AC-008 are implemented or covered by tests.
Expected artifact: `03-implementation.md`
Output format:
- Summary
- Changed files
- Behavior changes
- Tests added or updated
- Known limitations
