# Task Card Protocol

Use this as the only input to a sub-agent unless it needs specific file excerpts.

```text
Role:
Run directory:
Task:
Scope:
Allowed files:
Forbidden files:
Inputs:
Constraints:
Acceptance criteria:
Expected artifact:
Output format:
```

## Rules

- Keep the task card short.
- Persist the exact task card under the run directory before spawning the agent.
- Include only relevant context.
- Prefer paths, diffs, test names, and acceptance checks over narrative.
- Never include unrelated conversation history.
