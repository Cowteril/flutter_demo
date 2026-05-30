# Reviewer Task Card

Role: Supervisor-reviewer
Run directory: `.agent/runs/2026-05-30-remote-upload-trial`
Task: Review staged upload readiness.
Scope: Staged files, secret scan result, ignored local config, whitespace check.
Acceptance criteria:
- No obvious secret-bearing files are staged.
- `git diff --cached --check` passes.
Expected artifact: `04-review.md`
