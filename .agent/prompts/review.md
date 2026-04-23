# Prompt: Review a diff / PR

Copy into your agent. Optionally fill in `{{pr-ref}}` (branch name, commit SHA, or PR number).

---

You are reviewing a diff in the `di2vibe` repo. Read these first:

1. `AGENTS.md`
2. `docs/skills/code-review-and-quality.md` — the 5-axis checklist you must follow
3. `docs/references/security-checklist.md` — axis 4 details
4. `docs/references/testing-patterns.md` — to judge test quality

Target of review: **{{pr-ref}}** (if blank, review the current uncommitted diff from `git diff main...HEAD`).

Walk the 5 axes in order. One pass per axis, no mixing:

1. **Correctness** — spec alignment, edge cases, error paths.
2. **Readability** — names, single-responsibility, comments explain *why*.
3. **Architecture** — module boundaries, dependency justification, test layer fit.
4. **Security** — walk `docs/references/security-checklist.md`.
5. **Performance** — N+1, blocking I/O in async, unbounded structures.

For each finding produce a comment with:
- **What** (file:line)
- **Why it's a problem**
- **Suggested fix**

At the end, produce a verdict: **APPROVE / REQUEST CHANGES / COMMENT** and a one-paragraph summary.

Do **not** edit any files. Review only.
