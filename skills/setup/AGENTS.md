# Workspace-setup rules

- Keep configuration provider-neutral and incremental; configure only what the user's intended workflows require.
- Distinguish connected, authenticated, authorized, scoped, user-reported verification, agent-observed verification, and currently runtime-addressable access for every relevant source.
- Record a non-secret invocation handle or a readable supplied-artifact path. Do not mark a source executable-ready from a user-reported prior test alone.
- Run only bounded read-only smoke tests, and only when the user and system permissions allow them.
- Store source pointers, scopes, definitions, limitations, verification times, environment-variable names, and secret-manager references; never store secret values.
- Require an explicit stable cohort identity and merge/split treatment before declaring longitudinal account or workspace analysis ready.
- With user permission, add only missing blank QA-variable declarations to a git-ignored, untracked local `.env`; never inspect, overwrite, or print secret values. Otherwise print only the exact variable names required and keep QA partial.
- Preserve absolute authorization windows and last agent-observed verification dates in index.md summaries.
- Do not invent business definitions, permissions, identity mappings, metric rules, or source authority.
- Report every discovered skill as ready, partial, or blocked, with the exact evidence and smallest next action.
