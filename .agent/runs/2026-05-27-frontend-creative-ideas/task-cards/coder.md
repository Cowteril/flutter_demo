# Coder Task Card

Role: Coder
Run directory: `.agent/runs/2026-05-27-frontend-creative-ideas`
Task: Add the structured frontend creative ideas file.
Scope: Documentation only
Allowed files:
- `docs/frontend_creative_ideas.yaml`
- `.agent/runs/2026-05-27-frontend-creative-ideas/03-implementation.md`
Forbidden files:
- `client/lib/**`
- `client/pubspec.yaml`
- build outputs
Inputs:
- `00-brief.md`
- `01-plan.md`
- `02-evidence.md`
Constraints:
- Edit only assigned documentation files.
- Keep the format easy to copy and extend.
- Do not implement runtime behavior.
Acceptance criteria:
- AC-001: Project contains a structured creative ideas file.
- AC-003: Previously discussed ideas are captured.
- AC-004: Each idea has stable, extensible fields.
- AC-005: No Flutter runtime code changes.
Expected artifact: `03-implementation.md`
Output format:
- Summary
- Changed files
- Behavior changes
- Tests added or updated
- Known limitations
