# Plan

## Goal

Add the requested gamification and personal profile demo surfaces end to end.

## Non-goals

- Persistent account storage.
- Real prediction settlement.
- Real file upload plugin.

## Assumptions

- The demo can store profile, prediction, and character state in a shared in-memory `ProfileController`.
- "Watched later content" can be modeled in the vertical feed: when the user swipes forward, earlier dramas are marked ineligible for unresolved predictions.
- Avatar upload can be represented by a visible upload button that cycles demo avatar styles.

## Tasks

- Add prediction highlight kind and sample prediction entries.
- Add profile/gamification state controller.
- Wire feed, player, side actions, prediction lockout, and profile navigation.
- Add character favorability and profile UI.
- Add visual polish for interaction overlays/effects.
- Add focused widget tests.
- Run analyze/test and complete reviewer/tester gates.

## Role Split

- Planner: supervisor-created acceptance criteria and scope in this file.
- Researcher: inspect existing feed/player/highlight/test structure.
- Coder: supervisor implemented scoped Flutter changes.
- Reviewer: sub-agent `019e8258-004e-7531-9281-47c56d96aeac`.
- Tester: sub-agent `019e8258-41ac-71e1-b3ba-94c326a8dd52`, plus supervisor verification.

## Acceptance Criteria

- AC-001: Prediction highlights are available in mock/local demo content with "预测1/预测2".
- AC-002: Prediction choices create pending records and do not reveal a correct answer.
- AC-003: Seeking from before a prediction trigger to after it disqualifies participation.
- AC-004: Watching later feed content disqualifies earlier unresolved predictions.
- AC-005: Player side actions update likes/follows/favorites and expose character favorability.
- AC-006: Character like/gift changes score and unlocks exclusive content at the threshold.
- AC-007: Profile page shows nickname, account, avatar upload demo, stats, achievements, prediction records, and liked characters.
- AC-008: Widget tests cover the new critical flows; `flutter analyze` and `flutter test` pass.

## Risks

- In-memory state resets on app restart.
- Avatar upload is a demo action, not a platform picker.
- Prediction settlement is pending only because no backend or future-episode answer source exists.

## Open Questions

- None blocking for the demo implementation.
