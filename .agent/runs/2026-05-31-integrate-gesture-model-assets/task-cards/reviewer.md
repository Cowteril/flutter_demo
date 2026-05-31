# Reviewer Task Card

Review the model asset integration diff.

Check:

- Runtime files are in app assets, not mixed with training logs.
- Training evidence remains available under docs.
- `pubspec.yaml` correctly includes model assets.
- The new test verifies asset bundling without hard-coding unnecessary implementation details.
- No credentials or private keys are introduced.

Expected output: PASS or BLOCKED with concrete file/line findings.
