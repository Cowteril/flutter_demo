# Evidence

## Codebase Findings

- `DramaPlayerPage` owns playback position, active highlights, side actions, gesture effects, and profile-controller integration, so it is the right integration point for highlight-aware companion events.
- `ProfileController` already stores profile, prediction, achievement, character favorability, and history state; feature settings and AI companion unlock state fit there for the demo.
- `SideActionBar` previously had a fixed action column, so dynamic feature toggles required rebuilding the action list rather than hiding individual children in place.
- Existing effect rendering uses `EffectLayer` and `EffectEntry`; prop throwing can reuse that mechanism without adding dependencies.

## Source Files Read

- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/side_action_bar.dart`
- `client/lib/features/player/presentation/widgets/effect_layer.dart`
- `client/lib/features/profile/domain/profile_controller.dart`
- `client/lib/features/profile/presentation/profile_page.dart`
- `client/lib/features/drama/domain/models/drama.dart`
- `client/lib/features/drama/domain/models/highlight_point.dart`
