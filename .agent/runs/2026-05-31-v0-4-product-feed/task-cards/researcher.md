# Researcher Task Card

Role: Researcher
Run directory: `.agent/runs/2026-05-31-v0-4-product-feed/`
Task: Gather code and artifact evidence for the v0.4 product-feed changes.
Scope: Current diff, changed files, existing QA screenshots, verification command outputs.
Allowed files: read-only for source; may update `02-evidence.md`.
Forbidden files: production code edits.
Inputs:
- `00-brief.md`
- `01-plan.md`
- `git diff --stat`
- Changed source/test files
Constraints:
- Cite exact paths, line numbers, commands, or artifact paths.
- Separate facts from assumptions and known residual risk.
Acceptance criteria:
- AC-001 through AC-008 have concrete source/test evidence.
- AC-010 has command evidence once scans run.
Expected artifact: `02-evidence.md`
Output format:
- Findings
- Evidence table
- Screenshot/artifact list
- Risks
- Recommended next steps
