# Coder Task Card

Role: Coder

Run directory: `.agent/runs/2026-05-31-integrate-gesture-model-assets/`

Task: move model files into their final project locations and add asset-bundling verification.

Allowed files:

- `client/assets/models/`
- `docs/model_runs/20260531-034301/`
- `client/pubspec.yaml`
- `client/test/widget_test.dart`
- `.agent/runs/2026-05-31-integrate-gesture-model-assets/`

Forbidden files:

- Player runtime implementation files.
- Android native build files.
- Git credentials or remote configuration.

Inputs:

- `00-brief.md`
- `01-plan.md`
- `02-evidence.md`
- `client/20260531-034301/`

Acceptance criteria:

- AC1: runtime files are moved to Flutter assets.
- AC2: training evidence is preserved outside app assets.
- AC3: model assets are declared in `pubspec.yaml`.
- AC4: a test loads model and labels through `rootBundle`.

Expected artifact: `03-implementation.md`
