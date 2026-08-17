# Sandbox hardening design

## Outcome

Close the remaining sandbox findings without changing the provider-neutral architecture or introducing a runtime service.

## Approaches considered

1. Minimal contract and bootstrap hardening — recommended and approved. Extend the existing readiness states, configuration fields, setup checks, and evaluation evidence.
2. Add a machine-readable registry or database. This could make validation more deterministic but duplicates context.md and adds migration/runtime complexity.
3. Add provider- or CLI-specific adapters. This could make selected integrations easier but fragments the canonical skills and conflicts with the portability goal.

## Approved changes

- Distinguish user-reported, agent-observed, and currently addressable verification. A source is executable-ready only when the current runtime can invoke it or a bounded artifact is supplied.
- Require a stable cohort identity and explicit pre/post-merge treatment before account-grain longitudinal metrics can be ready.
- Create `.env` with owner-only permissions, warn about unsafe populated files, and provide exact blank QA variable placeholders after persona configuration.
- Rename bootstrap messages so structural discovery cannot be mistaken for product/source readiness.
- Preserve absolute authorization windows and last-verified dates in index summaries.
- Replace static-only behavioral claims with honest execution states and auditable disposable-run artifacts, including real file mutation, validation, and rollback tests for self-improvement.

## Success criteria

1. Clean-clone setup remains idempotent and exposes all canonical skills.
2. New `.env` files use mode 0600; an unsafe populated `.env` is reported.
3. Source and dependent-skill readiness cannot be `ready` from a name or user report alone when the runtime cannot address it.
4. Longitudinal account metrics remain partial or blocked until merge semantics are confirmed.
5. Index source windows remain absolute.
6. Validation results distinguish executed, simulated, failed, and not-run criteria and retain observable artifacts.
