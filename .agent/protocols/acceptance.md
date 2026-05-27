# Acceptance Protocol

Acceptance criteria must be observable.

Each criterion should have a stable ID:

```text
AC-001:
AC-002:
AC-003:
```

Good:

- `npm test` passes.
- `src/auth/session.ts` rejects expired sessions.
- Reviewer reports no P0/P1 findings.
- Trace includes tool calls, changed files, and test output.

Weak:

- Code looks good.
- Model should behave better.
- The implementation is robust.

## Verdict Values

- Pass: all criteria met.
- Partial: some criteria met; list gaps and risk.
- Fail: blocking criteria unmet.

## Gate Checklist

```text
Acceptance criteria status:
Reviewer gate:
Tester gate:
Changed files listed:
Commands recorded:
Residual risk:
Final verdict:
```
