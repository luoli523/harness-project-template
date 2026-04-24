# Prompt: Break a spec into tasks

**Only needed if your tool does not auto-discover `.agents/skills/`.** Claude Code and Codex CLI both read that directory natively — use their skill mechanism instead.

Paste into your tool and fill in `{{spec-file}}` (e.g., `spec/orders.md`).

---

You are working in the `di2vibe` repo. Read these before doing anything:

1. `AGENTS.md`
2. `.agents/skills/planning-and-task-breakdown/SKILL.md` — the process you must follow
3. The spec file: **{{spec-file}}**

Then produce a task breakdown for that spec following the skill:

1. List every change the spec requires (models, routes, migrations, tests, docs, config).
2. Group into tasks ≤ 100 LOC diff each. Order them so foundational pieces come first.
3. For each task write: title (imperative, ≤ 10 words), 2–5 binary acceptance criteria, blocked-by dependencies, and an LOC estimate.
4. Append the task list to the same spec file under a `## Tasks` heading (or create `spec/<feature>-tasks.md` if cleaner).
5. Do **not** write application code. Do **not** start T1. Stop after the task list is written and ask for human sign-off.

If any task would exceed 100 LOC, split it further — even if the split feels artificial.
