# Plan

## Goal

Introduce a browsable drama home page and search entry while retaining the existing vertical feed as a secondary viewing mode.

## Non-goals

- No backend/API changes.
- No real recommendation ranking model.
- No new account persistence work.
- No visual asset pipeline beyond generated poster-like blocks from existing drama metadata.

## Assumptions

- Available local videos should be preferred on real devices.
- Tests should use mock repository fallback to avoid local asset dependence.
- Search can initially match title and subtitle because the current domain model has no tag/keyword field.
- The existing `ProfileController` is the correct in-memory owner for profile, companion, achievements, and feature settings state.

## Tasks

- Create a `DramaHomePage` with header, search, filters, featured rail, and all-drama list.
- Make the app root open `DramaHomePage`.
- Let the home page navigate into `DramaPlayerPage`, `ProfilePage`, and the existing `DramaFeedPage`.
- Allow `DramaFeedPage` to accept an external `ProfileController` so shared state survives navigation from home.
- Add widget tests for home shell, search filtering, and vertical feed entry.
- Run formatting, static analysis, unit/widget tests, and diff whitespace checks.

## Role Split

- Planner: Supervisor, recorded here.
- Researcher: Supervisor inspected existing app/feed/player/profile patterns.
- Coder: Supervisor implemented the scoped changes.
- Reviewer: Sub-agent review of final diff.
- Tester: Sub-agent verification plus supervisor command runs.

## Acceptance Criteria

- AC-001: App first screen is a browsable home page, not the vertical feed.
- AC-002: Home page displays all available dramas from local catalog or mock fallback.
- AC-003: Home page includes a visible search box and filters dramas by query.
- AC-004: Users can open a selected drama in the existing player.
- AC-005: Users can still enter the existing vertical swipe feed from the home page.
- AC-006: Profile/AI companion state is shared when navigating from home into player/profile/feed.
- AC-007: Existing feed/player tests still pass.

## Risks

- Search is local-only and metadata-limited.
- Poster visuals are generated from metadata colors instead of production artwork.
- Flutter web visual QA was not run unless a browser build target is separately validated.

## Open Questions

- What production ranking/search metadata will be supplied by backend later?
