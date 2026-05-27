# Researcher Task Card

Role: Researcher
Run directory: `.agent/runs/2026-05-27-frontend-creative-ideas`
Task: Summarize current frontend context and ideas already discussed.
Scope: Read-only repository context and current conversation artifacts
Allowed files: read-only, plus `02-evidence.md`
Forbidden files: Flutter runtime code edits
Inputs:
- `00-brief.md`
- Current source structure under `client/lib`
Constraints:
- Capture evidence as file paths and concise summaries.
- Do not introduce external backend requirements.
Acceptance criteria:
- AC-002: Existing frontend foundation is documented.
- AC-003: Previously discussed ideas are captured.
Expected artifact: `02-evidence.md`
Output format:
- Project context
- Discussion inputs
- Source files referenced
