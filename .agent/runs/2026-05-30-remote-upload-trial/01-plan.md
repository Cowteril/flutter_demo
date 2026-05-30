# Plan

## Goal

Safely commit and push the current project to GitHub.

## Tasks

- Confirm remote configuration.
- Inspect working tree status.
- Scan for obvious secrets and secret-like file names.
- Ignore `.claude/` before staging.
- Stage current project files.
- Check staged whitespace and staged file list.
- Commit current work.
- Push `master` to `origin`.

## Acceptance Criteria

- AC-001: `origin` points to `git@github.com:Cowteril/flutter_demo.git`.
- AC-002: No obvious secret strings or secret-like files are staged.
- AC-003: `.claude/` is ignored and not staged.
- AC-004: A local commit is created.
- AC-005: Push is attempted once; if network blocks GitHub, skip further upload attempts.

## Risks

- GitHub SSH may be unreachable from the current network.
- The commit is broad because the project has accumulated multiple completed work slices.

## Open Questions

- None.
