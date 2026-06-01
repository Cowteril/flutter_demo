# Brief

## User Request

Add profile-driven gamification features to the Flutter short-drama demo:

- Plot prediction quiz before key story moments, using temporary options "预测1/预测2".
- Prediction eligibility must be blocked if the viewer seeks past the trigger time before answering, or has watched later content.
- Prediction rewards must remain pending to avoid spoilers.
- Character favorability meter with like/gift actions and exclusive-content unlock.
- Achievement/badge collection.
- Personal profile page with nickname, account, avatar upload demo, follows, favorites, history, likes, achievements, and liked characters.

## Goal

Make the features visible and usable in the existing demo feed/player without adding backend persistence or new dependencies.

## Constraints

- Keep state in memory for the demo.
- Preserve existing Flutter architecture and widget tests.
- No external package added for avatar upload; use a demo upload/avatar-cycle action.
- Do not revert unrelated untracked `.agent` assets from earlier runs.
- Follow mandatory reviewer/tester gates.

## Target Files Or Areas

- `client/lib/features/drama/*` highlight data/model.
- `client/lib/features/feed/presentation/drama_feed_page.dart`.
- `client/lib/features/player/presentation/*`.
- `client/lib/features/profile/*`.
- `client/test/widget_test.dart`.

## Out Of Scope

- Real backend account/profile persistence.
- Real prediction answer settlement.
- Real media-file avatar picker integration.
- Web preview, because this project includes `tflite_flutter`/FFI and is validated through Flutter tests here.
