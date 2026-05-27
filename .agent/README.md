# Multi-Agent Codex Kit

This kit implements a lightweight Codex-native multi-agent workflow.

It is intentionally framework-light:

- Codex sub-agents provide separate contexts.
- Markdown role files provide stable behavior.
- Run folders provide traceability.
- Acceptance and review files provide explicit gates.

## How To Use

1. Create a run:

```powershell
powershell -ExecutionPolicy Bypass -File .agent/scripts/new-run.ps1 -Slug implement-login-check
```

2. Fill `00-brief.md` with the user request, constraints, and target files.

3. Supervisor fills the relevant files in `task-cards/` before spawning agents.

4. Supervisor spawns separate agents using the role prompts in `.agent/roles/`.

5. Each sub-agent writes or returns only its required artifact.

6. Supervisor writes `06-final-verdict.md` with explicit gate results.

## Recommended Agent Order

```text
Planner -> Researcher(s) -> Coder(s) -> Reviewer + Tester -> Supervisor verdict
```

For small tasks, skip roles that do not add value.

Reviewer and tester gates are still mandatory for code changes unless the final verdict records why they were skipped and what risk remains.
