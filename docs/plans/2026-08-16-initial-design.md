# Initial design: Let's Product Manager Workflow

## Goal

Create a lightweight, model-agnostic workspace that automates repetitive product-management processes while keeping prioritization and product decisions with the PM.

## Validated decisions

- Use Markdown as the v0.1 operating surface.
- Make README.md the first-read onboarding entry point.
- Keep AGENTS.md canonical and let CLAUDE.md import it.
- Keep skills provider-neutral; discover MCPs, CLIs, files, and other access at runtime.
- Store active state, history, and navigation in root task.md, log.md, and index.md.
- Store evolving initiative artifacts under projects/<project-name>/.
- Allow skills to learn, while separating project facts, company context, folder conventions, and reusable processes.
- Drive self-improvement with a target-and-improvement payload, acceptance checks, and off, suggest, or safe-auto workspace modes; use suggest by default.
- Restrict automatic edits to narrow changes supported by an explicit reusable correction or confirmed evaluator failure. Require approval for inferred, broad, security-sensitive, permission-changing, or externally mutating changes.
- Require a PM decision before moving from evidence and options into implementation.
- Support independently invokable workflows for support tickets, meetings, and team communications without provider-specific skill trees.
- Keep strategy and prioritization decisions with the PM rather than adding dedicated strategy or prioritization skills in v0.1.

## v0.2 self-serve additions

- Add a network-free setup.sh that validates and exposes canonical skills through supported local discovery paths.
- Configure connected, authenticated, authorized, scoped, and verified source states plus ready, partial, or blocked skill states.
- Record metric, entity, identity, timezone, fiscal-calendar, privacy, exclusion, freshness, and arbitrary QA-role conventions in context.md.
- Add configure-workspace and analyze-product-context as provider-neutral skills.
- Use a common execution and evidence-packet contract across every evidence type.
- Add provider-neutral validation cases and public contribution and compatibility guidance.

## Deliberately excluded from v0.1

Provider-specific skill trees, adapter generators, schemas, integration registries, policy engines, databases, daemons, and automatic deployment.
