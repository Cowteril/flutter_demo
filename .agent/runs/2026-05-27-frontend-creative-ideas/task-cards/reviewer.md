# Reviewer Task Card

Role: Reviewer
Run directory: `.agent/runs/2026-05-27-frontend-creative-ideas`
Task: Review final documentation changes against the brief and acceptance criteria.
Scope: final changed files only
Allowed files: read-only, plus `04-review.md`
Forbidden files: Flutter runtime code edits
Inputs:
- `00-brief.md`
- `01-plan.md`
- changed files
- `05-test-report.md` if available
Constraints:
- Prioritize requirement coverage, structure consistency, and accidental runtime edits.
Acceptance criteria:
- AC-001: Project contains a structured creative ideas file.
- AC-002: Existing frontend foundation is documented.
- AC-003: Previously discussed ideas are captured.
- AC-004: Each idea has stable, extensible fields.
- AC-005: No Flutter runtime code changes.
Expected artifact: `04-review.md`
Output format:
- Verdict
- Gate status
- Blocking findings
- Non-blocking findings
- Missing tests
- Risk assessment
- Required fixes
