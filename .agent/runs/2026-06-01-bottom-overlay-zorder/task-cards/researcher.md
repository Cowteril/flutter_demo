# Researcher Task Card

## Scope

Inspect the player rendering order for bottom overlays.

## Files

- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/interaction_overlay.dart`
- `client/lib/features/player/presentation/widgets/side_action_bar.dart`
- `client/lib/features/player/presentation/widgets/highlight_timeline.dart`

## Questions

- Which widgets are involved in the screenshot overlap?
- What draw order causes the issue?
- Which fix is smallest while preserving expected interactions?

## Expected Output

Record evidence in `02-evidence.md`.
