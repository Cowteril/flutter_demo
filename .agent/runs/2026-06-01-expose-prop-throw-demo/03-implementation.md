# Implementation

## Changed Files

- `client/lib/features/player/presentation/drama_player_page.dart`
- `client/lib/features/player/presentation/widgets/prop_throw_panel.dart`
- `client/test/widget_test.dart`

## Summary

- Added `_propThrowLeadWindow` and `_propThrowHighlight` so prop throwing becomes available 6 seconds before each high-light and remains available through the existing interaction window.
- Changed player rendering to show `PropThrowPanel` based on `_propThrowHighlight`, not only `_activeHighlight`.
- Updated `PropThrowPanel` to accept the high-light title, display a `扔道具` label, and position itself in the right-side toolbar area rather than near the top overlay.
- Added a widget test verifying the prop panel appears before an upcoming high-light while the main interaction overlay is still absent.
- Existing prop effect test continues to verify selecting an egg creates `PropThrowEffect`.
