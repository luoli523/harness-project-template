# Prompt: Start a spec

**Only needed if your tool does not auto-discover `.agents/skills/`.** Claude Code and Codex CLI both read that directory natively — use their skill mechanism instead.

Paste the block below into your tool (Cursor, Aider, plain ChatGPT, etc.) and fill in `{{feature}}`.

---

You are working in the `di2vibe` repo (Python 3.12 + FastAPI). Read these files before doing anything else:

1. `AGENTS.md` — project conventions
2. `.agents/skills/spec-driven-development/SKILL.md` — the process you must follow
3. Any existing files under `spec/` — so you match the established format

Then produce a spec for: **{{feature}}**

Follow `.agents/skills/spec-driven-development/SKILL.md` exactly:

1. List your assumptions first. Stop and wait for human confirmation before writing the spec body.
2. After confirmation, write the full spec to `spec/<feature-kebab-case>.md` covering all six areas: Objective, Scope (+ non-goals), API surface, Data model, Edge cases & failure modes, Acceptance criteria.
3. Do **not** write any code. Do **not** modify `src/` or `tests/`. Spec only.
4. When done, print the file path and a one-sentence summary. Do **not** proceed to planning.

If the feature request is ambiguous, ask clarifying questions rather than guessing.
