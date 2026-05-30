# Plan

## Goal

Update the effects polish plan to make AI-generated sprite assets the preferred source and remove AI copyright-limit caveats.

## Tasks

- Replace CC0-first sprite wording with AI-first sprite wording.
- Keep CC0 as fallback.
- Keep license tracking only for externally downloaded assets.
- Preserve the existing effects roadmap and schedule.

## Acceptance Criteria

- AC-001: AI-generated sprite assets are listed as the preferred particle asset path.
- AC-002: The plan explicitly says AI-generated assets only need generation/process notes, not copyright-limit discussion.
- AC-003: CC0 assets remain as fallback for failed or insufficient AI output.
- AC-004: External downloaded assets still require `ASSET_LICENSES.md` tracking.

## Gate Policy

Documentation-only change. No build/test gate required.
