# Brief

## User Request

The user could not see the prop throwing feature in the demo and asked how it can be displayed.

## Goal

Make the prop throwing entry visible before the high-light interaction overlay appears, so it can be demonstrated naturally while watching.

## Constraints

- Keep prop throwing tied to nearby high-light moments.
- Preserve existing AI companion, feature settings, and hide-all behavior.
- Avoid new dependencies.
- Do not revert unrelated workspace changes.

## Target Files Or Areas

- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/prop_throw_panel.dart`
- `client/test/widget_test.dart`

## Out Of Scope

- Backend target delivery.
- New prop asset pipeline or audio assets.
