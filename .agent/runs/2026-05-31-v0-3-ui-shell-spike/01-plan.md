# Plan

## Goal

Deliver a v0.3 feed shell that demonstrates short-drama browsing with local
video assets while preserving a clean path to a backend-provided feed later.

## Non-goals

- Backend API implementation.
- Public redistribution of local video files.
- Full import of an open-source app with unrelated backend dependencies.

## Assumptions

- The `videos/` directory contains local demo media on the developer machine.
- Synced local `.mp4` files are for local builds only and remain ignored by Git.
- The existing `DramaPlayerPage` remains the canonical playback surface.

## Tasks

- Add ignore rules and a repeatable local video sync script.
- Add a local asset catalog that discovers Flutter asset-manifest entries.
- Add a vertical `PageView` feed and route `DuanjuApp` to it.
- Add tests for mock fallback and local catalog conversion.
- Run format, analyze, tests, Android debug build, review, and secret scan.

## Role Split

- Planner: Map the user request into acceptance criteria.
- Researcher: Identify a suitable open-source Flutter short-video feed pattern.
- Coder: Implement feed shell, catalog, sync script, ignore rules, and tests.
- Reviewer: Inspect final diff against requirements.
- Tester: Run project-native verification commands.

## Acceptance Criteria

- AC-001: The app home screen is a vertically scrollable short-video feed.
- AC-002: Local `.mp4` assets under `assets/local_videos/` are discovered from
  Flutter's asset manifest and converted into playable drama entries.
- AC-003: When local assets are unavailable, the app falls back to the existing
  mock drama repository instead of showing a black or broken screen.
- AC-004: Existing `DramaPlayerPage` interaction, effects, and gesture overlay
  remain the per-video playback experience.
- AC-005: Copyrighted local video files and temporary open-source clones are
  ignored by Git.
- AC-006: A repeatable PowerShell sync script copies a limited number of local
  episodes into the Flutter asset directory without staging them.
- AC-007: Formatter, analyzer, tests, and Android debug build pass.

## Risks

- Asset-manifest loading can fail in widget tests or empty local environments;
  the feed must catch this and use mock data.
- Android builds include local videos only if the developer has synced them.
- Local videos may be large, so only a small sample should be copied for demo.

## Open Questions

- None blocking for v0.3. Backend contract design is deferred.
