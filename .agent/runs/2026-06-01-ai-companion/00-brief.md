# Brief

## User Request

Implement the next demo goal: AI companion watching.

## Goal

Add an unlockable AI character companion for the player demo, including script/persona context data, a draggable Q-style pet overlay, highlight-aware dialogue that does not see future plot, prop throwing interactions, feature toggles, and a hide-all feature icon control.

## Constraints

- Follow the existing Flutter demo architecture and avoid new dependencies.
- Keep AI companion script/context data in reusable structures for future branching and fan-fiction features.
- Do not reveal current-episode content after the active highlight to the AI companion.
- The companion must not block the right-side action toolbar.
- Feature toggles must remove disabled icons without leaving blank slots.
- Per AGENTS.md, record acceptance criteria, changed files, review, and test gate results.

## Target Files Or Areas

- `client/lib/features/companion/`
- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/`
- `client/lib/features/profile/`
- `client/test/widget_test.dart`

## Out Of Scope

- Real backend persistence or live LLM calls.
- Real 3D model assets.
- Production audio asset pipeline beyond the demo click sound.
