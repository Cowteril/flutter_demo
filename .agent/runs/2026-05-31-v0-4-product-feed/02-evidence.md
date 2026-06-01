# Evidence

## Findings

- The working branch is `codex/v0.4-product-feed`.
- Current source diff is limited to five tracked files under feed/player/widget test areas.
- The run directory already contains emulator and tablet screenshots from earlier QA passes, including first screen, swipe, adaptive tablet viewport, HUD fix, and cast-overlay probe images.
- The existing run Markdown/task-card files were template placeholders and needed completion.

## Evidence Table

| Claim | Evidence | Source | Confidence | Impact | Follow-up |
| --- | --- | --- | --- | --- | --- |
| Feed now owns immersive UI and retryable load state. | `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)` and reset to `edgeToEdge`; empty state calls `_retryLoad`. | `client/lib/features/feed/presentation/drama_feed_page.dart:34`, `client/lib/features/feed/presentation/drama_feed_page.dart:40`, `client/lib/features/feed/presentation/drama_feed_page.dart:70`, `client/lib/features/feed/presentation/drama_feed_page.dart:143` | High | Covers AC-001. | Verify analyze/test. |
| Feed uses vertical paging, current index, active player controls, and nearby ticking. | `PageView.builder`, `onPageChanged`, `TickerMode`, and embedded `DramaPlayerPage` flags. | `client/lib/features/feed/presentation/drama_feed_page.dart:98`, `client/lib/features/feed/presentation/drama_feed_page.dart:102`, `client/lib/features/feed/presentation/drama_feed_page.dart:107`, `client/lib/features/feed/presentation/drama_feed_page.dart:111` | High | Covers AC-002 and AC-004. | Reviewer gate. |
| Tablet/wide viewport is constrained to 9:16. | `_feedViewportWidth` returns `min(maxWidth, maxHeight * 9 / 16)`. | `client/lib/features/feed/presentation/drama_feed_page.dart:151` | High | Covers AC-003. | Widget test and tablet screenshot. |
| Feed chrome includes tabs and source/progress pill. | `_FeedChrome`, `_FeedTabs`, and progress text are rendered over the feed. | `client/lib/features/feed/presentation/drama_feed_page.dart:122`, `client/lib/features/feed/presentation/drama_feed_page.dart:158` | High | Covers AC-001. | Widget test. |
| Player exposes feed embedding switches. | Constructor fields `isActive`, `autoPlay`, `manageSystemUi`, `showTopBar`, `feedPositionLabel`. | `client/lib/features/player/presentation/drama_player_page.dart:28` | High | Covers AC-004. | Analyzer validates call sites. |
| Inactive players and overlay state are synchronized. | `_syncPlaybackForActiveState` cancels mock timer, pauses controller, and closes gesture overlay when inactive. | `client/lib/features/player/presentation/drama_player_page.dart:243` | Medium | Covers AC-002 and AC-005. | Unit/widget tests cover mock path; real video remains device QA risk. |
| Gesture overlay hides competing layers. | Emotion overlay, interaction overlay, top bar, bottom HUD, and side action bar are gated by `!_isGestureSpellOpen`. | `client/lib/features/player/presentation/drama_player_page.dart:499`, `client/lib/features/player/presentation/drama_player_page.dart:514`, `client/lib/features/player/presentation/drama_player_page.dart:520`, `client/lib/features/player/presentation/drama_player_page.dart:522`, `client/lib/features/player/presentation/drama_player_page.dart:534` | High | Covers AC-005. | Widget test. |
| HUD avoids side action rail. | `_BottomHud` is positioned with `right: 96`. | `client/lib/features/player/presentation/drama_player_page.dart:756` | High | Covers AC-006. | Visual QA/screenshots. |
| Side action items have shared tap area. | `_ActionButton` wraps icon and text in an opaque `GestureDetector` sized 64x66. | `client/lib/features/player/presentation/widgets/side_action_bar.dart:193`, `client/lib/features/player/presentation/widgets/side_action_bar.dart:196`, `client/lib/features/player/presentation/widgets/side_action_bar.dart:197` | High | Covers AC-007. | Manual tap QA. |
| Audience heat badge moved above HUD/title collision area. | `bottom: 178`. | `client/lib/features/player/presentation/widgets/emotion_temperature_overlay.dart:44` | High | Covers AC-006. | Visual QA/screenshots. |
| Widget tests cover the new behaviors. | Tests assert `Mock · 1/3`, swipe to `2/3`, 450px 9:16 width at 1200x800, inactive no mock playback, active auto advance, overlay hides side/comment/emotion/slider. | `client/test/widget_test.dart:40`, `client/test/widget_test.dart:51`, `client/test/widget_test.dart:72`, `client/test/widget_test.dart:207`, `client/test/widget_test.dart:228`, `client/test/widget_test.dart:301` | High | Covers AC-008. | Run `flutter test`. |

## Screenshots Already Captured

- `.agent/runs/2026-05-31-v0-4-product-feed/qa-emulator-first.png`
- `.agent/runs/2026-05-31-v0-4-product-feed/qa-emulator-swipe.png`
- `.agent/runs/2026-05-31-v0-4-product-feed/qa-emulator-cast-fixed.png`
- `.agent/runs/2026-05-31-v0-4-product-feed/qa-tablet-first.png`
- `.agent/runs/2026-05-31-v0-4-product-feed/qa-tablet-adaptive.png`
- `.agent/runs/2026-05-31-v0-4-product-feed/qa-tablet-hud-fixed.png`
- `.agent/runs/2026-05-31-v0-4-product-feed/qa-tablet-cast-overlay.png`

## Risks

- `qa-tablet-cast-overlay.png` was recorded as a cast-overlay probe where the overlay may not have actually opened; manual phone/tablet retest of the "施法" entry remains useful.
- Real video controller pause/autoplay behavior needs device confidence beyond mock widget tests.
