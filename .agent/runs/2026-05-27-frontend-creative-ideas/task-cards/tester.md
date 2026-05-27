# Tester Task Card

Role: Tester
Run directory: `.agent/runs/2026-05-27-frontend-creative-ideas`
Task: Verify documentation file existence and key idea coverage.
Scope: changed documentation files
Allowed files: read-only, plus `05-test-report.md`
Forbidden files: Flutter runtime code edits
Inputs:
- `00-brief.md`
- `01-plan.md`
- changed file list
Constraints:
- Record exact command names and summarized outputs.
- Explain why Flutter tests are not required if no app code changed.
Acceptance criteria:
- AC-001: Project contains a structured creative ideas file.
- AC-003: Previously discussed ideas are captured.
- AC-004: Each idea has stable, extensible fields.
- AC-005: No Flutter runtime code changes.
Expected artifact: `05-test-report.md`
Output format:
- Environment
- Commands run
- Results
- Failures
- Reproduction steps
- Coverage gaps
- Final test verdict
- Gate status
