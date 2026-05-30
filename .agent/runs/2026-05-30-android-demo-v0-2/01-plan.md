# Plan

## Milestone

M1 Stable Single-Player Product Shell + Feed Contract.

## Acceptance Criteria

- AC-M1-01: Android manifest disables Impeller for A/B validation of the black-screen issue.
- AC-M1-02: Video initialization errors are observable in logs.
- AC-M1-03: Player pauses on app background and resumes only if it was previously playing.
- AC-M1-04: Side action bar renders avatar/follow, like, comment, share, and episode actions.
- AC-M1-05: Side action interactions update local state and trigger feedback.
- AC-M1-06: Emotion temperature and audience count remain visible over the player.
- AC-M1-07: User reactions and side actions spike the emotion temperature.
- AC-M1-08: Existing branch and playback tests remain green.
- AC-M1-09: `flutter analyze`, `flutter test`, and debug APK build pass.
- AC-M1-10: Physical device verification status is recorded honestly.

## Implementation Steps

1. Add `EnableImpeller=false` manifest metadata.
2. Add lifecycle observer and initialization logging to `DramaPlayerPage`.
3. Add `SideActionBar`.
4. Add `EmotionTemperatureOverlay`.
5. Wire user reactions, double tap, like/comment/share into emotion boost.
6. Add widget coverage for v0.2 shell.
7. Run verification and record gates.

## Risks

- Physical-device black screen cannot be fully closed without reconnecting the phone.
- Side action bar is page-local and will need extraction before Feed.
- Avatar is placeholder for this slice; generated avatar assets are deferred.
