# Brief

## User Request

Add a mainstream-app-style home surface for browsing all short dramas, plus a search box. The current app starts directly in a vertical short-video feed and only supports swipe viewing; the new entry should let users browse dramas before entering playback.

## Goal

Make the app open to a drama home page that supports:

- Browsing all available dramas.
- Searching by title/subtitle.
- Entering an individual drama player.
- Entering the existing vertical feed mode.
- Preserving profile/AI companion state across home, player, profile, and feed navigation.

## Constraints

- Keep the existing vertical feed functional.
- Prefer existing repository/data abstractions.
- Use the local video catalog when present and fall back to mock repository data for demos/tests.
- Keep UI controls compact and usable on mobile screens.
- Record acceptance criteria, implementation, review, and test gates per AGENTS.md.

## Target Files Or Areas

- `client/lib/app/duanju_app.dart`
- `client/lib/features/home/presentation/drama_home_page.dart`
- `client/lib/features/feed/presentation/drama_feed_page.dart`
- `client/test/widget_test.dart`

## Out Of Scope

- Backend search API.
- Real poster image ingestion.
- Persisted search history or recommendations.
- Commit/push; the user did not request it for this task.
