# Evidence

## Code Findings

- `DramaPlayerPage._isAiCompanionAvailable` previously checked `profileController.characterFor(widget.drama).isAiCompanionUnlocked`, making AI companion availability current-drama scoped.
- `AiCompanionOverlay` received `profileController.characterFor(widget.drama).name`, so the overlay always used the current drama's character.
- `FeatureSettingsSheet` only had an AI companion on/off switch and no selected-character control.
- `ProfileController` already owned character favorability and gifts, so global companion selection belongs there.

## Source Files Read

- `client/lib/features/profile/domain/profile_controller.dart`
- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/feature_settings_sheet.dart`
- `client/lib/features/companion/data/ai_companion_script_catalog.dart`
- `client/test/widget_test.dart`
