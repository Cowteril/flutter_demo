# Implementation

## Changed Files

- `client/lib/features/profile/domain/profile_controller.dart`
- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/feature_settings_sheet.dart`
- `client/lib/features/companion/data/ai_companion_script_catalog.dart`
- `client/lib/features/player/presentation/widgets/character_favorability_sheet.dart`
- `client/lib/features/profile/presentation/profile_page.dart`
- `client/test/widget_test.dart`

## Summary

- Added `selectedAiCompanionCharacterId`, `selectedAiCompanionCharacter`, `unlockedAiCompanionCharacters`, and `selectAiCompanionCharacter` to profile state.
- Auto-selects the first character that crosses the AI companion gift requirement.
- Changed player AI companion availability and overlay name to use the selected global companion.
- Passed selected companion ID/name/source drama into companion script context so persona data can represent a cross-drama companion.
- Added settings UI with single-select chips for unlocked AI companion characters.
- Updated character and profile UI text to distinguish `AI使用中` from merely `AI已解锁`.
- Added tests for cross-drama AI companion usage and settings selection.
