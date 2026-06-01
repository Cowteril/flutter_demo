# Brief

## User Request

AI companion should be unlocked as a character-level account asset. Once a character is unlocked, it can be used while watching any drama. Settings should let the user choose which unlocked character is currently used, and only one AI companion can be active at a time.

## Goal

Convert AI companion availability from current-drama scoped to global selected-character scoped.

## Constraints

- Preserve existing gift-based unlock behavior.
- Keep only one active AI companion selection.
- Keep the selected companion available across all dramas.
- Preserve existing AI context, prop throwing, feature settings, and profile surfaces.
- Avoid new dependencies.

## Target Files Or Areas

- `client/lib/features/profile/domain/profile_controller.dart`
- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/feature_settings_sheet.dart`
- `client/lib/features/companion/data/ai_companion_script_catalog.dart`
- `client/lib/features/player/presentation/widgets/character_favorability_sheet.dart`
- `client/lib/features/profile/presentation/profile_page.dart`
- `client/test/widget_test.dart`

## Out Of Scope

- Backend persistence of selected companion.
- Real LLM persona prompt delivery.
- Multi-companion simultaneous watching.
