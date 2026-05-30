# Reviewer Task Card

Role: Reviewer
Run directory: `.agent/runs/2026-05-29-android-demo-v0-1-followup`
Task: Review the final diff against `01-plan.md` acceptance criteria.
Scope: Read-only review of modified files and `git diff`.
Allowed files: read-only
Forbidden files: production code edits
Inputs:
- `01-plan.md`
- `03-implementation.md`
- Final `git diff`
Constraints:
- Prioritize bugs, regressions, missing tests, and v0.1 requirement gaps.
- Report blocking findings first with file and line references.
- Do not repeat coder implementation notes unless they explain a risk.
Acceptance criteria:
- AC-001 through AC-006 in `01-plan.md`
Expected artifact: `04-review.md`
Output format:
- Verdict: pass/fail
- Blocking findings
- Non-blocking findings
- Residual risks
