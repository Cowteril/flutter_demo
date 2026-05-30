# Evidence

## Inputs

- Current Android Demo v0.1 implementation context.
- User-provided critique of the earlier asset reuse strategy.
- Deadline assumptions stated by the user: 2026-06-11 submission and 2026-06-19 defense.

## Key Decisions

- Treat license tracking as a lightweight support task, not the main line of work.
- Prioritize visible effect layering and technical explainability.
- Prefer pure Flutter animation and shader work before large external animation assets.
- Use CC0 sprite/audio assets only when they clearly improve visual quality.

## Risks Considered

- Over-investing in asset sourcing can reduce time available for visible technical work.
- LottieFiles free animations require per-asset license verification.
- Rive can produce strong interaction moments but may cost more time than pure Flutter/shader work.
