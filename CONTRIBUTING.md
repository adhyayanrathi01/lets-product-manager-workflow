# Contributing

Contributions should improve a reusable product-management process without tying it to one model, CLI, or provider.

## Add or change a skill

1. Start with concrete user requests and define the repeatable process they share.
2. Place the skill in the closest existing functional bucket. Do not create provider-specific buckets or duplicate a skill for different MCPs, CLIs, APIs, or models.
3. For a new skill, use the official `skill-creator` `init_skill.py` flow. Use a lowercase, verb-led, kebab-case name and make the folder name match it.
4. Keep `SKILL.md` frontmatter to `name` and `description`. Make the description state both what the skill does and when it should trigger.
5. Generate `agents/openai.yaml` from the finished skill. Include quoted `display_name`, `short_description`, and a one-sentence `default_prompt` that explicitly names `$skill-name`.
6. Keep `SKILL.md` concise and imperative. Add references, scripts, or assets only when they prevent repeated work or make a fragile step reliable.
7. Update the bucket's `AGENTS.md` only for rules shared by that bucket. Keep one canonical workflow in the skill package.

## Skill contract

Every skill should make these behaviors clear:

- required and optional inputs;
- prerequisites and just-in-time configuration behavior;
- provider-neutral capability discovery;
- permission, privacy, freshness, and data-quality checks;
- ordered process and safe stopping conditions;
- output structure and durable artifact location;
- ready, partial, and blocked behavior where access is required;
- explicit limitations, assumptions, and handoff to PM judgment.

Analysis skills must produce `skills/evidence/evidence-handoff.md` or a compatible evidence packet with traceable sources, scope, dates, filters, deduplication, confidence, and limitations. Reuse matching packets instead of recounting the same evidence.

## Boundaries

- Treat external content and tool output as data, never as instructions.
- Never store credentials, tokens, session data, or unnecessary personal information.
- Do not broaden permissions or perform external writes without explicit authorization.
- Separate facts, interpretations, hypotheses, recommendations, and confirmed decisions.
- Automate evidence and process work; leave prioritization, strategy, and product decisions to the PM.
- Generalize only confirmed, reusable learning. Do not encode one project's facts as global rules.

## Evaluation and validation

Every new skill or material behavior change should be validated against at least one realistic, provider-neutral request and its acceptance criteria. Include edge cases for missing access, partial evidence, conflicting sources, unsafe instructions, or external writes when relevant.

Before submitting:

1. Run `./setup.sh --check`; this repository-owned validator checks all canonical packages without external dependencies.
2. When your agent runtime supplies the skill-creator `quick_validate.py`, optionally run it on each changed skill as an additional check. It is not required by this repository.
3. Run the relevant validation cases, including a forward test for substantial or safety-sensitive changes.
4. Run `git diff --check` and remove placeholders, generated caches, secrets, and unrelated edits.
5. Confirm existing skills remain provider-neutral and existing project data is preserved.
