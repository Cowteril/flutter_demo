# Codex Multi-Agent Workflow

This repository uses a supervisor-led, context-isolated workflow for Codex.

## Core Rule

Do not let one long context do planning, research, coding, review, and testing.
Split work into small role-specific agents and exchange only structured artifacts.

## Roles

- Supervisor: owns scope, task state, handoffs, and final verdict.
- Planner: turns the user request into tasks and acceptance criteria.
- Researcher: gathers code or external evidence and records sources.
- Coder: edits only the assigned files or modules.
- Reviewer: reviews the diff against requirements and acceptance criteria.
- Tester: runs verification commands and reports reproducible results.

## Context Isolation

- Spawn sub-agents without full conversation history unless explicitly needed.
- Give each sub-agent only its task card, relevant files, constraints, and expected output.
- Do not pass chain-of-thought, brainstorming logs, or unrelated chat history between agents.
- Pass artifacts, not memories.

## Artifact Contract

Every meaningful task should produce a run directory:

```text
.agent/runs/YYYY-MM-DD-slug/
  00-brief.md
  01-plan.md
  02-evidence.md
  03-implementation.md
  04-review.md
  05-test-report.md
  06-final-verdict.md
  task-cards/
    planner.md
    researcher.md
    coder.md
    reviewer.md
    tester.md
```

The supervisor may add extra files, but these names are the default handoff surface.

## Done Criteria

A task is not done until:

- Requirements are mapped to concrete acceptance criteria with stable IDs.
- Each spawned agent has a persisted task card.
- Changed files are listed.
- Verification commands and results are recorded.
- Reviewer has no blocking findings.
- Tester verdict is pass, or the final verdict explains why testing could not run.
- Final verdict states pass, fail, or partial with reasons.

## Mandatory Gates

For normal code changes, reviewer and tester gates are mandatory.
Planner and researcher may be skipped for small tasks, but the supervisor must still record acceptance criteria and final gate status.

If any mandatory gate is skipped, `06-final-verdict.md` must state why and mark the residual risk.

## Parallel Work Rules

- Parallel coders must own disjoint files or modules.
- Read-only agents may run in parallel freely.
- A reviewer should inspect final diffs, not the coder's private context.
- The supervisor integrates artifacts and resolves conflicts.

## Local Commands

Create a new run folder:

```powershell
powershell -ExecutionPolicy Bypass -File .agent/scripts/new-run.ps1 -Slug my-task
```

## Supervisor Startup Rule

For any non-trivial implementation, research, review, or debugging task, the supervisor should proactively create a run directory before delegating work:

```powershell
powershell -ExecutionPolicy Bypass -File .agent/scripts/new-run.ps1 -Slug short-task-name
```

The user does not need to run this manually unless they want to pre-create a run.

Skip run creation only for tiny questions, quick commands, or tasks where persistent artifacts would add no value.
