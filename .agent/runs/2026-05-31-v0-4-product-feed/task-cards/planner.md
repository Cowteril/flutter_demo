# Planner Task Card

Role: Planner
Run directory: `.agent/runs/2026-05-31-v0-4-product-feed/`
Task: Convert the v0.4 product-feed continuation request into stable tasks and acceptance criteria.
Scope: Brief, plan, and gate criteria only.
Allowed files: read-only for source; may update run artifacts.
Forbidden files: production code edits.
Inputs:
- `00-brief.md`
- Repository AGENTS instructions
- Current working tree status and diff summary
Constraints:
- Do not edit production code.
- Produce testable acceptance criteria with stable IDs.
- Include secret/media safety constraints.
Acceptance criteria:
- AC-001 through AC-010 are defined in `01-plan.md`.
Expected artifact: `01-plan.md`
Output format:
- Goal
- Non-goals
- Assumptions
- Tasks
- Role split
- Acceptance criteria
- Risks
- Open questions
