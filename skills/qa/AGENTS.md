# QA rules

- Test against the project’s acceptance criteria and relevant user roles.
- Read arbitrary QA personas and credential environment-variable names from context; read secret values only from the environment.
- Never record passwords, tokens, cookies, or browser storage state.
- Prefer repeatable Playwright flows when available, but remain tool-neutral.
- Report reproducible failures, evidence, impact, and untested areas.
