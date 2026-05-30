# Researcher Task Card

Role: Researcher
Run directory: `.agent/runs/2026-05-29-android-demo-v0-1-followup`
Task: Compare the current v0.1 Flutter implementation with `docs/ANDROID_DEMO_V0.1_PLAN.md` and identify remaining gaps or risks.
Scope: Read-only scan of `client/lib`, `client/test`, `client/pubspec.yaml`, and the v0.1 plan.
Allowed files: read-only
Forbidden files: production code edits
Inputs:
- `.agent/runs/2026-05-29-android-demo-v0-1-followup/00-brief.md`
- `.agent/runs/2026-05-29-android-demo-v0-1-followup/01-plan.md`
- `docs/ANDROID_DEMO_V0.1_PLAN.md`
Constraints:
- Cite exact file paths and line numbers when possible.
- Separate facts from assumptions.
- Focus on gaps that affect the v0.1 acceptance checklist.
Acceptance criteria:
- AC-001 through AC-006 in `01-plan.md`
Expected artifact: `02-evidence.md`
Output format:
- Findings
- Evidence table
- Risks
- Recommended next steps
