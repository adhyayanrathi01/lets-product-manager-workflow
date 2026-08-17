# Let's Product Manager Workflow

An evidence-first workspace that automates product research, analysis, synthesis, prototyping, and testing without replacing product judgment.

> **See [the workflow diagrams](docs/FLOWS.md)** for the end-to-end user journey, evidence orchestration, and safe skill-improvement paths.

## Core principle

Agents identify problems, assemble evidence, explain uncertainty, and present options. The product manager decides what matters, what to prioritize, and what to build. Analysis never silently becomes implementation or an external write.

## Agent: read this first

When starting in this repository:

1. Read AGENTS.md, context.md, task.md, and relevant entries in index.md.
2. If setup is incomplete, follow SETUP.md one question at a time.
3. Use a project folder for substantial work and the relevant provider-neutral skills.
4. Return evidence, options, confidence, and trade-offs for the PM's decision.
5. Maintain task.md, log.md, and index.md as defined in AGENTS.md; route reusable learnings through improve-skills.

## User quick start

1. Clone the repository and run `./setup.sh`. It validates the workspace, creates an untracked owner-only `.env` when needed, and exposes canonical skills through supported local discovery paths.
2. Open the folder in your agent. For a custom CLI, have it read README.md and AGENTS.md and use `skills/` as its skill source.
3. Say: “Use configure-workspace to help me set up this product workspace.”
4. The agent collects product context and, when permitted, verifies task-relevant sources with bounded read-only checks.
5. Resolve only blockers needed for the first task; unrelated gaps may remain partial.
6. Start with a product question such as: “Help me understand why retention for Feature X is declining.”

Documentation may stay in any external system. Record pointers in context.md; skills discover authorized MCPs, CLIs, APIs, browser tools, and files at runtime.

`setup.sh` performs no network installation, stores no connector credentials, and does not establish product-source readiness. Run `./setup.sh --check` for a read-only structural check; use configure-workspace for product readiness.

## What configured means

A named or authenticated connection is not ready by itself. Setup distinguishes user-reported status, current runtime addressability through a non-secret handle or readable artifact, and an agent-observed bounded read. Only an authorized, scoped, addressable, agent-observed source is executable-ready.

Context records definitions needed for safe analysis and joins: metrics, entities, identifiers, stable cohort identity, merge/split treatment, source precedence, terminology, time, exclusions, and QA roles. Skills report ready, partial, or blocked instead of guessing.

## How an investigation works

For “How can we improve retention for Feature X?”, the agent:

1. Clarifies the scope, definitions, and PM decision; then creates a project folder.
2. Gathers available quantitative, qualitative, competitive, and product-context evidence.
3. Separates facts from hypotheses and presents options with confidence, risks, and validation ideas.
4. Stops for the PM's decision before prototyping, instrumentation, querying, testing, or implementation beyond the approved scope.

## Main files

| File | Purpose |
| --- | --- |
| setup.sh | Safe, idempotent bootstrap and structural readiness check |
| AGENTS.md | Canonical operating rules for agents |
| CLAUDE.md | Claude entry point that imports AGENTS.md |
| SETUP.md | First-use interview and setup checklist |
| context.md | Stable product context and pointers to external sources |
| task.md | Current work, status, blockers, and next actions |
| log.md | Concise history of meaningful actions and decisions |
| index.md | Map of local project files, skills, and external sources |
| projects/ | Evolving files for each product initiative |
| skills/ | Reusable, provider-neutral product processes |
| COMPATIBILITY.md | Minimum runtime contract, limitations, and upgrades |
| CONTRIBUTING.md | Rules for adding or changing reusable skills |
| VERSION | Current semantic version |

## Included workflows

The skills cover workspace configuration, product investigations, analytics and tracking, safe queries, product context, customer evidence, support, meetings, team communication, competition, PM-approved prototypes, QA, and skill improvement. Every workflow can run independently or contribute an evidence handoff to a broader investigation.

## Skill learning

Invoke improve-skills in plain language or with a reusable payload:

    Use $improve-skills
    target_skill: analyze-support-tickets
    improvement: Distinguish duplicate contacts from unique affected accounts.
    evidence: Ticket volume overstated the number of affected customers.
    mode: suggest
    acceptance_check: Report both ticket count and unique affected accounts.

Use `target_skill: auto` when ownership is unknown. The skill locates the narrowest rule and returns the evidence, proposed diff, acceptance check, and risks; existing behavior returns `no_change` rather than duplicate instructions.

Self-improvement mode is configured in context.md:

- `off`: no automatic trigger; manual use remains available.
- `suggest` (default): propose exact changes for approval.
- `safe-auto`: apply only narrow changes backed by an explicit correction or confirmed failed acceptance check; propose broader or inferred changes.

A manual `mode: apply` authorizes only a safe, in-scope edit—not dependencies, scripts, external actions, permission changes, weakened security, or destructive operations.

Candidates include reusable corrections, repeated workflow or evaluator failures, and confirmed process changes. Project facts stay in the project, company facts in context.md, and reusable process rules in the relevant SKILL.md or folder AGENTS.md.

Never promote credentials, personal data, customer content, temporary workarounds, or unsupported assumptions into a reusable skill.

## Evidence channels

Analytics, queries, product documentation, support, meetings, and communications each produce reusable evidence packets. They may feed broader investigations while remaining independently usable. Tool discovery happens at runtime; no provider-specific workflow folder is required.
