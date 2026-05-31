# Coder Task Card

Role: Coder
Run directory: `.agent/runs/2026-05-31-v0-3-ui-shell-spike/`
Task: Implement the v0.3 local-video vertical feed shell.
Scope: feed UI, local catalog, sync script, ignore rules, app route, and tests.
Allowed files:
- `.gitignore`
- `client/assets/local_videos/README.md`
- `client/lib/app/duanju_app.dart`
- `client/lib/features/drama/data/local_video_asset_catalog.dart`
- `client/lib/features/feed/presentation/drama_feed_page.dart`
- `client/pubspec.yaml`
- `client/test/widget_test.dart`
- `scripts/sync-local-videos.ps1`
Forbidden files:
- Copyrighted `.mp4`, `.mov`, or `.m4v` files
- Unrelated production modules
Inputs:
- `00-brief.md`
- `01-plan.md`
- relevant evidence
Constraints:
- Edit only assigned files or modules.
- Do not revert other people's changes.
- Report blockers instead of widening scope silently.
Acceptance criteria:
- AC-001 through AC-007 in `01-plan.md`
Expected artifact: `03-implementation.md`
Output format:
- Summary
- Changed files
- Behavior changes
- Tests added or updated
- Known limitations
