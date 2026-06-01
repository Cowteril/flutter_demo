# Implementation

## Changed Files

- `client/lib/features/companion/domain/ai_companion_models.dart`
- `client/lib/features/companion/data/ai_companion_script_catalog.dart`
- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/ai_companion_overlay.dart`
- `client/lib/features/player/presentation/widgets/character_favorability_sheet.dart`
- `client/lib/features/player/presentation/widgets/effects/prop_throw_effect.dart`
- `client/lib/features/player/presentation/widgets/feature_settings_sheet.dart`
- `client/lib/features/player/presentation/widgets/prop_throw_panel.dart`
- `client/lib/features/player/presentation/widgets/side_action_bar.dart`
- `client/lib/features/profile/domain/profile_controller.dart`
- `client/lib/features/profile/presentation/profile_page.dart`
- `client/test/widget_test.dart`

## Summary

- Added reusable AI companion models and a local script catalog with persona, role positioning, previous episode summaries, highlight-bounded current context, companion dialogue, and normalized prop target coordinates.
- Extended profile state with `FeatureSettings`, gift-count companion unlocks, and an `ai_companion_unlocked` achievement.
- Added a draggable Q-style companion overlay with chat, happy, surprised, throwing, and punch poses. The speech bubble expands left from the pet so it does not cover the right-side action toolbar.
- Integrated highlight-triggered companion messages in the player while preventing future highlight context from being included.
- Added prop throwing UI and effects for glove, flower, and egg; effects start from the companion when unlocked.
- Added feature settings and bottom HUD hide-all behavior. When hidden, only the restore visibility icon remains.
- Updated side actions to build only enabled actions, keeping the column compact.
- Added tests for companion context gating, unlock behavior, feature toggles, hide-all behavior, and prop throwing.
