# Reviewer Task Card

Role: Reviewer
Run directory: `.agent/runs/2026-06-01-profile-gamification-features/`
Task: Review final changes against the brief and acceptance criteria.
Scope: final diff and changed files only.
Allowed files: read-only, plus `04-review.md`.
Forbidden files: code edits unless explicitly reassigned.

Inputs:
- `00-brief.md`
- `01-plan.md`
- final diff or changed files
- `05-test-report.md` if available

Constraints:
- Do not rely on the coder's private context.
- Prioritize correctness, regressions, security, data loss, and missing tests.

Acceptance criteria:
- Review AC-001 through AC-008.

Expected artifact: `04-review.md`

Output format:
- Verdict
- Gate status
- Blocking findings
- Non-blocking findings
- Missing tests
- Risk assessment
- Required fixes
