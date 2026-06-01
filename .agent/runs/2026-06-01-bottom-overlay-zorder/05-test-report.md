# Test Report

## Environment

- Workspace: `E:\Project\duanju\client`
- Flutter/Dart SDK: `C:\Users\niuwe\flutter`

## Commands Run

- `& 'C:\Users\niuwe\flutter\bin\cache\dart-sdk\bin\dart.exe' format --output=none --set-exit-if-changed lib test`
- `& 'C:\Users\niuwe\flutter\bin\cache\dart-sdk\bin\dart.exe' 'C:\Users\niuwe\flutter\packages\flutter_tools\bin\flutter_tools.dart' test test\widget_test.dart --plain-name 'highlight interaction hides bottom controls while open'`
- `& 'C:\Users\niuwe\flutter\bin\cache\dart-sdk\bin\dart.exe' 'C:\Users\niuwe\flutter\packages\flutter_tools\bin\flutter_tools.dart' test`

## Results

- Format check passed: `Formatted 28 files (0 changed)`.
- Focused regression test passed: `+1: All tests passed`.
- Full Flutter test suite passed: `+16: All tests passed`.
- `git diff --check` passed.
- Independent tester confirmed the format command passed.

## Failures

- Initial `dart.bat` formatter wrapper hung and was terminated after the direct
  Dart SDK formatter completed successfully.
- Initial non-elevated Flutter test attempt was blocked by SDK cache lockfile
  permissions; the same command passed after running with the required SDK
  cache permission.
- Independent tester reproduced the same non-elevated Flutter SDK lockfile
  permission block before tests ran.

## Reproduction Steps

Run the commands listed above from `E:\Project\duanju\client`.

## Coverage Gaps

- No device screenshot/golden test was captured. Widget tests cover the stack
  order and visible control state for the reported overlap.

## Final Test Verdict

Pass for supervisor-run verification. Independent tester command was blocked by
environment permissions before test discovery; the final verdict records this
residual process risk.

## Gate Status

- Tester gate: Partial, with supervisor verification pass and independent tester
  environment block
- Acceptance criteria checked: Yes
- Commands recorded: Yes
