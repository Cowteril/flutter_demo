# Brief

## User Request

The screenshot shows the bottom interaction card being visually covered by
player controls. Fix the incorrect occlusion at the bottom of the short-drama
player UI.

## Goal

When a highlight interaction card is visible, player bottom controls must not
draw or receive taps above the card.

## Constraints

- Keep the change scoped to the Flutter client player UI.
- Preserve side actions and gesture spell behavior unless directly affected.
- Follow the repository multi-agent artifact workflow.

## Target Files Or Areas

- client/lib/features/player/presentation/drama_player_page.dart
- client/test/widget_test.dart

## Out Of Scope

- Reworking copy, video playback, or highlight business logic.
