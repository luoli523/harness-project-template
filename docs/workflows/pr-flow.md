# PR Flow

End-to-end lifecycle of a pull request in this repo.

## 1. Before you open

- [ ] Your branch is rebased on current `main`.
- [ ] You walked the [code-review-and-quality](../../.agents/skills/code-review-and-quality/SKILL.md) skill on your own diff.
- [ ] All gates green locally: `uv run ruff check . && uv run ruff format --check . && uv run mypy src && uv run pytest`.
- [ ] Every commit message follows the format in the [git-workflow-and-versioning](../../.agents/skills/git-workflow-and-versioning/SKILL.md) skill.
- [ ] The PR addresses **one task** from the plan (or a tight cluster — never unrelated tasks).

## 2. Opening

Use the PR template. Required fields:

- **Linked spec** — `spec/<feature>.md`
- **Task IDs closed** — T2, T3
- **Why this approach** — 2–3 sentences if non-obvious
- **New dependencies** — each with a one-line rationale, or "none"
- **Risk / rollback** — what could break, how to revert
- **Test plan** — how you verified (commands run, manual steps)

Mark as **Draft** if you're still iterating. Don't waste reviewer time on a moving target.

## 3. Review

- Request review from ≥ 1 human. An agent cannot approve.
- Reviewer walks the [5-axis checklist](../../.agents/skills/code-review-and-quality/SKILL.md).
- Reviewer leaves **actionable** comments (what, why, suggested fix).
- Author replies to every comment. Resolving a comment means the concern is addressed, not ignored.

## 4. Iterating

- Push additional commits, don't amend + force-push (breaks reviewer's ability to see what changed since last review).
- Once approved, you **may** squash-rebase for a clean merge if commits accumulated.

## 5. Merging

- **Default:** squash merge (one PR → one commit on `main`).
- **Exception:** rebase merge when every commit on the branch is independently meaningful and atomic.
- **Never:** merge commits on `main`.
- CI must be green at merge time (branch protection enforces this).

## 6. Post-merge

- Delete the branch (GitHub can auto-delete).
- If the PR closed an acceptance criterion, check it off in `spec/<feature>.md`.
- Watch production / staging for the next ~30 min if the change is runtime-facing.
- If something broke: revert first, debug second. `main` must stay deployable.

## Size limits

| Diff size (excl. tests) | Action |
|---|---|
| < 100 LOC | Normal review |
| 100–400 LOC | OK but reviewer may push back; justify in description |
| > 400 LOC | **Split**, or explicitly justify why split is impossible (generated code, mechanical rename) |
