# Test Report

## Environment

- Workspace: `E:\Project\duanju`
- Flutter project: `E:\Project\duanju\client`
- Date: 2026-06-01
- Platform: Windows PowerShell

## Commands Run

- `C:\Users\niuwe\flutter\bin\cache\dart-sdk\bin\dart.exe format client/lib/features/companion client/lib/features/player/presentation/drama_player_page.dart client/lib/features/player/presentation/widgets/ai_companion_overlay.dart client/lib/features/player/presentation/widgets/character_favorability_sheet.dart client/lib/features/player/presentation/widgets/feature_settings_sheet.dart client/lib/features/player/presentation/widgets/prop_throw_panel.dart client/lib/features/player/presentation/widgets/side_action_bar.dart client/lib/features/player/presentation/widgets/effects/prop_throw_effect.dart client/lib/features/profile/domain/profile_controller.dart client/lib/features/profile/presentation/profile_page.dart client/test/widget_test.dart`
- `C:\Users\niuwe\flutter\bin\cache\dart-sdk\bin\dart.exe C:\Users\niuwe\flutter\packages\flutter_tools\bin\flutter_tools.dart analyze`
- `C:\Users\niuwe\flutter\bin\cache\dart-sdk\bin\dart.exe C:\Users\niuwe\flutter\packages\flutter_tools\bin\flutter_tools.dart test`
- `git diff --check`

## Results

- `dart format`: pass, formatted 12 files, 0 changed in the final tester run.
- `flutter analyze`: pass, no issues found.
- `flutter test`: pass, 26 tests passed.
- `git diff --check`: pass.

## Failures

- None.

## Notable Warnings

- Dependency resolution reports 7 newer package versions incompatible with current constraints.
- Test logs include the existing non-fatal TFLite Windows dynamic library warning for `libtensorflowlite_c-win.dll`; tests continue through fallback behavior.

## Coverage Gaps

- No line coverage percentage generated because `flutter test --coverage` was not run.
- Pixel-perfect companion animations and prop effects were not visually verified.
- Native Windows TFLite inference was not exercised because the DLL is missing.
- Backend integration and durable settings persistence are out of scope.

## Final Test Verdict

Pass.

## Gate Status

- Tester gate: pass
- Acceptance criteria checked: AC-001 through AC-008
- Commands recorded: yes
