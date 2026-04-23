---
description: Implement the next task from an approved plan (TDD + small diff)
---

Read `.agent/prompts/build.md` and follow it. Target: **$ARGUMENTS** (format: `<spec-file> <task-id>`, e.g. `spec/orders.md T2`).

Key rules:
- Write the failing test first. Show it fail.
- Minimum implementation to turn it green.
- Run the full gate chain (`ruff`, `ruff format --check`, `mypy`, `pytest`) — all must pass.
- Commit atomically with spec + task reference in the message.
- Stop after this task. Do not start the next.
