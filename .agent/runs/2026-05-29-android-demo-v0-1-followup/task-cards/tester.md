# Tester Task Card

Role: Tester
Run directory: `.agent/runs/2026-05-29-android-demo-v0-1-followup`
Task: Run verification commands after implementation and record reproducible results.
Scope:
- `client`
- Flutter/Dart verification commands
Allowed files: generated build/test outputs only
Forbidden files: production code edits
Inputs:
- `01-plan.md`
- `03-implementation.md`
Commands to run:
- `dart format --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`
Constraints:
- Record exact commands, pass/fail status, and important output.
- If a command cannot run because of sandbox/tooling/device constraints, state the reason and residual risk.
Acceptance criteria:
- AC-005 and AC-006 in `01-plan.md`
Expected artifact: `05-test-report.md`
Output format:
- Verdict: pass/fail/partial
- Environment notes
- Command results
- Residual risks
