# Reviewer Task Card

Role: Reviewer
Run directory: TODO
Task: Review final changes against the brief and acceptance criteria.
Scope: final diff and changed files only
Allowed files: read-only
Forbidden files: code edits unless explicitly reassigned
Inputs:
- `00-brief.md`
- `01-plan.md`
- final diff or changed files
- `05-test-report.md` if available
Constraints:
- Do not rely on the coder's private context.
- Prioritize correctness, regressions, security, data loss, and missing tests.
Acceptance criteria:
- AC-001: TODO
Expected artifact: `04-review.md`
Output format:
- Verdict
- Gate status
- Blocking findings
- Non-blocking findings
- Missing tests
- Risk assessment
- Required fixes
