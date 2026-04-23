# Prompt: Implement the next task

Copy into your agent and fill in `{{spec-file}}` and `{{task-id}}` (e.g., `spec/orders.md`, `T2`).

---

You are working in the `di2vibe` repo. Read these before doing anything:

1. `AGENTS.md`
2. `docs/skills/incremental-implementation.md` — the process you must follow
3. `docs/skills/test-driven-development.md` — mandatory for any logic change
4. `docs/skills/git-workflow-and-versioning.md` — commit message format
5. The spec and task list: **{{spec-file}}**

Implement task **{{task-id}}** following the slice loop:

1. Re-read the task's acceptance criteria. Confirm you understand "done."
2. **Write the failing test first.** Run it. Show me it fails for the expected reason.
3. Write the minimum implementation to make it pass. No speculative abstractions.
4. Run the full gate chain and report output:
   ```
   uv run ruff check . && uv run ruff format --check . && uv run mypy src && uv run pytest
   ```
5. All four must pass. If any fail, fix and re-run.
6. Commit atomically with a message in the format from `docs/workflows/commit-conventions.md`. Reference the spec and task ID.
7. Do **not** start the next task. Stop and wait.

Constraints:
- Diff ≤ 100 LOC (excluding generated files and tests).
- No changes outside what this task requires.
- No TODOs without a linked issue.
