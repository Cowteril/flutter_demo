# Coder Task Card

Role: Coder
Run directory: `.agent/runs/2026-06-01-profile-gamification-features/`
Task: Implement the requested demo features within the Flutter client.
Scope: profile controller/UI, prediction highlights and eligibility, player/feed wiring, character favorability, achievements, visual polish, and tests.

Allowed files:
- `client/lib/features/drama/**`
- `client/lib/features/feed/**`
- `client/lib/features/player/**`
- `client/lib/features/profile/**`
- `client/test/widget_test.dart`
- run artifacts under `.agent/runs/2026-06-01-profile-gamification-features/`

Forbidden files:
- Unrelated application modules.
- Dependency files unless a dependency is explicitly required.

Inputs:
- `00-brief.md`
- `01-plan.md`
- `02-evidence.md`

Constraints:
- Do not revert other people's changes.
- Keep demo state in memory.
- Avoid adding dependencies for avatar upload.

Acceptance criteria:
- AC-001 through AC-008 in `01-plan.md`.

Expected artifact: `03-implementation.md`

Output format:
- Summary
- Changed files
- Behavior changes
- Tests added or updated
- Known limitations
