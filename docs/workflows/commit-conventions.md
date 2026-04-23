# Commit Conventions

Loose Conventional Commits, enforced by review (not by tooling — yet).

## Format

```
<type>(<scope>): <imperative summary, ≤ 72 chars>

<body: why, alternatives considered, follow-ups>

Refs spec/<feature>.md, task T<n>
```

## Types

| Type | When |
|---|---|
| `feat` | New user-visible behavior |
| `fix` | Bug fix (link to issue or Prove-It test) |
| `refactor` | Restructure without behavior change |
| `test` | Add/modify tests only |
| `docs` | Docs only (including spec, skill playbooks) |
| `chore` | Tooling, deps, boilerplate |
| `perf` | Performance improvement (include before/after numbers in body) |
| `ci` | CI config changes |

## Scope

A top-level area. Keep it short and consistent. Examples in this repo:

- `api` — FastAPI routes
- `models` — Pydantic models
- `db` — database / migrations
- `config` — settings, env loading
- `deps` — dependency injection wiring
- `ci` — GitHub Actions

If a commit genuinely spans scopes, the commit is probably too big — split it.

## Imperative mood

Write the summary as a command, not a report.

| ❌ | ✅ |
|---|---|
| `Added /orders endpoint` | `Add /orders endpoint` |
| `Fixed the 404 bug` | `Fix 404 when order id missing` |
| `Updating deps` | `Upgrade fastapi to 0.115` |

## Body

Explain the *why*, the *what else was considered*, the *follow-ups*. Skip the body only for trivial commits (typo, rename).

```
feat(orders): add GET /orders/{id}

Chose explicit 404 over 200+null so clients can distinguish "no such
order" from "order with no visible fields." Pagination intentionally
out of scope — tracked in T5.

Refs spec/orders.md, task T2
```

## Footer

- `Refs spec/<feature>.md, task T<n>` — always, for non-trivial commits.
- `Fixes #123` — if the commit closes an issue.
- `Co-authored-by: ...` — when pair-programming with an agent or another human.

## What not to do

```
❌ "updates"
❌ "wip"
❌ "fix stuff"
❌ "address review comments"    (→ what comments? amend or be specific)
❌ "final version"               (→ nothing is final)
❌ a multi-line ASCII-art header
```

A good commit message is the one you'll thank yourself for when `git blame` lands here two years from now.
