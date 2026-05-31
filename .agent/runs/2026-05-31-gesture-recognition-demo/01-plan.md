# Plan

## Goal

Close the visible demo gap for v0.2 gesture recognition by adding an in-player gesture casting flow.

## Acceptance Criteria

- AC1: Player has an obvious gesture/AI casting entry point.
- AC2: Tapping the entry point opens a full-screen drawing overlay.
- AC3: Drawing a gesture produces a recognition result and accepted results trigger existing effects.
- AC4: Low-confidence recognition exposes dot-pattern fallback.
- AC5: Dot-pattern fallback can deterministically recognize at least one spell path.
- AC6: No `tflite_flutter` dependency remains until Windows Developer Mode/symlink support is available.
- AC7: Format, analyze, tests, and debug APK build pass.

## Task Split

- Add gesture result domain model and classifier abstraction.
- Add heuristic and dot-pattern classifiers.
- Add gesture overlay widget.
- Wire player actions to overlay and effects.
- Add widget/unit tests.
- Record review and test gate results.

## Risks

- Heuristic recognition is suitable for demo flow but not equivalent to trained TFLite inference.
- TFLite package integration is blocked locally by Windows Developer Mode symlink support.
