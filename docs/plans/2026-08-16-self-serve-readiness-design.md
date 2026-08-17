# Self-serve readiness design

## Outcome

Make the repository usable after a user clones it and connects their available sources, without making reusable PM skills depend on a model, provider, MCP, CLI, or storage system.

## Approved approach

Keep `skills/` as the canonical provider-neutral source. Add a thin `setup.sh` bootstrap that verifies the workspace, exposes skills through compatible local discovery paths when possible, and reports manual bootstrap instructions when a runtime has no discoverable convention.

Use Markdown as the configuration surface. Expand `context.md` rather than introducing a database or provider registry. Configuration will cover source readiness, access scope, privacy, freshness, metric definitions, entity and identity mappings, time conventions, arbitrary QA roles, and known gaps.

Add two reusable skills:

- `configure-workspace` to conduct setup, inspect available capabilities, run safe read-only smoke tests, and produce a readiness result;
- `analyze-product-context` to retrieve and reconcile product documentation, specifications, roadmaps, changelogs, and technical context from any available source.

Give every skill a concise common execution contract: inputs, preflight, process, output, partial-result behavior, and blocking conditions. Route quantitative as well as qualitative findings through the shared evidence handoff.

Add provider-neutral validation cases for onboarding, source readiness, missing access, conflicting evidence, multi-source analysis, PM decision boundaries, and self-improvement safety. Keep validation runnable by any capable agent without a dedicated test framework.

## Safety and scope

- Setup performs no network installation and never stores secrets.
- Connection checks are bounded and read-only.
- Authentication does not imply authorization; source scope must be recorded.
- Runtime-specific behavior is limited to discovery/bootstrap. Skill processes remain provider-neutral.
- Missing access produces partial readiness and explicit gaps rather than invented evidence.
- The PM retains prioritization and final product decisions.

## Success criteria

1. `setup.sh` runs safely more than once and validates all skill packages.
2. A new user can configure source access and business definitions through one guided skill.
3. The workspace distinguishes connected, authorized, scoped, verified, partial, and blocked sources.
4. Cross-source work has explicit entity, identity, metric, timezone, and freshness semantics.
5. Every skill declares predictable inputs, outputs, and failure behavior.
6. Evidence packets can be reused across all evidence channels without double counting.
7. Independent forward tests can complete onboarding and plan a multi-source investigation without undocumented assumptions.
