# Brief

## User Request

Fix the bottom area shown in the screenshot. The player HUD had too many stacked controls at the bottom: title/subtitle, a separate highlight timeline, a control row, a second progress slider, and time labels.

## Goal

Make the bottom playback HUD compact and readable while preserving playback, feature settings, hide-all, seeking, and highlight-jump behavior.

## Constraints

- Preserve the AI companion and feature setting work already in the workspace.
- Avoid new dependencies.
- Do not revert unrelated untracked QA files or previous run artifacts.
- Keep widget tests passing.

## Target Files Or Areas

- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/test/widget_test.dart`

## Out Of Scope

- Full visual golden testing.
- Reworking the right-side action bar or top overlays.
