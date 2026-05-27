# Tester Task Card

Role: Tester
Run directory: TODO
Task: Verify the changed behavior with commands or reproducible checks.
Scope: acceptance criteria and changed files
Allowed files: read-only by default
Forbidden files: production code edits unless explicitly reassigned
Inputs:
- `00-brief.md`
- `01-plan.md`
- changed file list
Constraints:
- Prefer project-native test commands.
- Record exact command names and summarized outputs.
- If tests cannot run, explain why and what risk remains.
Acceptance criteria:
- AC-001: TODO
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

