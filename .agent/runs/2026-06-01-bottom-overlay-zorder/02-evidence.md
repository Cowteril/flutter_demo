# Evidence

| Claim | Evidence | Source | Confidence | Impact | Follow-up |
| --- | --- | --- | --- | --- | --- |
| The screenshot overlap is produced by the interaction card and bottom player HUD. | `InteractionOverlay` renders a bottom card at `bottom: 18`; `_BottomHud` renders at `bottom: 0` and contains `HighlightTimeline`, play, and slider controls. | `client/lib/features/player/presentation/widgets/interaction_overlay.dart`, `client/lib/features/player/presentation/drama_player_page.dart` | High | Confirms the affected widgets. | Add a regression test. |
| The root cause is `Stack` paint order. | `DramaPlayerPage` builds `InteractionOverlay` before `_BottomHud` and `SideActionBar`; Flutter stacks paint later children above earlier children. | `client/lib/features/player/presentation/drama_player_page.dart` | High | Explains why the bottom controls cover the white card despite card elevation. | Change z-order or conditional visibility. |
| Hiding the bottom HUD during an active highlight is the smallest behaviorally safe fix. | While the interaction prompt is open, the prompt is the active bottom interaction surface; removing `_BottomHud` prevents visual occlusion and accidental control taps. | Local UI analysis | Medium | Preserves normal HUD when no prompt is active. | Test prompt open and prompt dismissed states. |
