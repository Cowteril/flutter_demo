# Reviewer Task Card

Role: Reviewer
Run directory: `.agent/runs/2026-05-31-v0-4-product-feed/`
Task: Review final changes against the brief and acceptance criteria.
Scope: Final diff and changed files only.
Allowed files: read-only.
Forbidden files: code edits unless explicitly reassigned.
Inputs:
- `00-brief.md`
- `01-plan.md`
- Final diff or changed files
- `05-test-report.md` if available
Constraints:
- Do not rely on the coder's private context.
- Prioritize correctness, regressions, security, data loss, and missing tests.
- Report blocking findings first with file/line references.
Acceptance criteria:
- AC-001 through AC-010 checked against the final diff and recorded verification.
Expected artifact: `04-review.md`
Output format:
- Verdict
- Gate status
- Blocking findings
- Non-blocking findings
- Missing tests
- Risk assessment
- Required fixes
