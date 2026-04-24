---
name: git-workflow-and-versioning
description: Enforces atomic commits on short-lived feature branches off main, with imperative commit messages that explain why, and rebase-based integration. Use when committing, branching, opening a PR, resolving merges, or structuring the final commit set before push.
---

# Git Workflow & Versioning

Small, atomic commits on short-lived branches off `main`. Treat each commit as a save-point you might want to revert independently.

## Branch model

- `main` is always deployable. CI green is non-negotiable on `main`.
- Feature branches off `main`, named `<type>/<short-slug>`:
  - `feat/order-listing`
  - `fix/404-on-missing-order`
  - `chore/upgrade-fastapi-0-115`
  - `docs/revise-spec-template`
- Branch lifetime: **< 3 days**. If it drifts longer, rebase on `main` or split.

## Commit rules

### Atomicity

One logical change per commit. Don't mix:
- Refactor + feature
- Formatting + logic
- Config + code

If you already mixed them, use `git add -p` to split by hunk before committing.

### Message format

```
<type>(<scope>): <imperative summary, ≤ 72 chars>

<body: why this change, what the alternative was, what to watch out for>

Refs spec/<feature>.md, task T<n>
```

**Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `ci`

**Scope** is a top-level area: `api`, `models`, `db`, `config`, `ci`, etc.

**Body** explains the *why*. The *what* is the diff — don't repeat it. Mention follow-ups, known limitations, or decisions that a future reader will want context on.

### Examples

Good:
```
feat(orders): add GET /orders/{id} endpoint

Returns 200 + Order JSON on hit, 404 + OrderNotFound on miss.
Chose explicit 404 over 200+null so clients can distinguish
"no such order" from "order with no data." Pagination is out of
scope for this task — tracked in T5.

Refs spec/orders.md, task T2
```

Bad:
```
updated order stuff
```

## PR rules

- PR = one task from the plan, ideally one commit. Multiple commits OK if each is atomic and makes sense on its own.
- Target `main` always. No long-lived integration branches.
- PR description links the spec (`spec/<feature>.md`) and lists the task IDs it closes.
- **Squash merge by default** — keeps `main` history one-commit-per-PR and easy to revert.
- Exception: if the branch is already perfectly atomic and each commit is independently valuable, use **rebase merge**. No merge commits on `main`.

## Rebasing vs merging

- **Keep feature branches current via rebase**, not merge. `git rebase main` on your feature branch.
- After rebase, force-push with lease: `git push --force-with-lease`. Never `--force` on its own.
- Never rebase `main` or any branch someone else may be building on.

## Red flags

- A commit message is just the file names that changed
- One commit spans 10 files with no connecting theme
- You pushed `main` directly (should never happen; enforce via branch protection)
- A PR has been open for > 1 week
- You force-pushed a shared branch
- You used `git commit --amend` after pushing

## Verification (before pushing)

- [ ] Every commit message follows the format
- [ ] Every commit is atomic (could be reverted alone)
- [ ] Branch is rebased on current `main`
- [ ] No WIP / fixup commits left (squash or amend before push)
- [ ] Pre-commit hooks ran green

Full upstream version: <https://github.com/addyosmani/agent-skills/blob/main/skills/git-workflow-and-versioning/SKILL.md>
Commit conventions detail: [../../../docs/workflows/commit-conventions.md](../../../docs/workflows/commit-conventions.md)
