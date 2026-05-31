# Researcher Task Card

Role: Researcher

Run directory: `.agent/runs/2026-05-31-integrate-gesture-model-assets/`

Task: inspect the completed model export and record evidence needed for integration.

Scope:

- Source export directory `client/20260531-034301/`.
- v0.2 plan references for model path and size target.
- Metrics and label mapping files.

Allowed files: read-only.

Forbidden files: production code edits.

Inputs:

- `00-brief.md`
- `01-plan.md`
- `client/20260531-034301/`
- `docs/ANDROID_DEMO_V0.2_PLAN.md`

Acceptance criteria:

- AC1: source files, sizes, labels, and metrics are recorded.
- AC2: runtime-vs-training file split is justified.
- AC3: credential/private-key risk is checked.

Expected artifact: `02-evidence.md`
