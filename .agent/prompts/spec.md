# Prompt: Start a spec

Copy the whole block below into your agent (Codex, Cursor, Aider, plain ChatGPT) and fill in `{{feature}}`.

---

You are working in the `di2vibe` repo (Python 3.12 + FastAPI). Read these files before doing anything else:

1. `AGENTS.md` — project conventions
2. `docs/skills/spec-driven-development.md` — the process you must follow
3. Any existing files under `spec/` — so you match the established format

Then produce a spec for: **{{feature}}**

Follow `docs/skills/spec-driven-development.md` exactly:

1. List your assumptions first. Stop and wait for human confirmation before writing the spec body.
2. After confirmation, write the full spec to `spec/<feature-kebab-case>.md` covering all six areas: Objective, Scope (+ non-goals), API surface, Data model, Edge cases & failure modes, Acceptance criteria.
3. Do **not** write any code. Do **not** modify `src/` or `tests/`. Spec only.
4. When done, print the file path and a one-sentence summary. Do **not** proceed to planning.

If the feature request is ambiguous, ask clarifying questions rather than guessing.
