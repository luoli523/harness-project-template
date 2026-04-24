---
name: incremental-implementation
description: Implements one thin vertical slice at a time — smallest change that leaves the system working, tested, and shippable. Use for every code change in this repo, no matter how small, after a task from the plan is selected.
---

# Incremental Implementation

Build one thin vertical slice at a time. A slice is the smallest change that leaves the system **working, tested, and shippable**.

## When to use

Every time you write code. There is no "big bang" mode in this project.

## The slice loop

For each task from the plan:

```
READ SPEC  →  WRITE TEST  →  MAKE IT FAIL  →  IMPLEMENT  →  MAKE IT PASS  →  REFACTOR  →  COMMIT
```

### 1. Read the spec + acceptance criteria

Re-read the task. Re-read the parent section of the spec. Make sure you can recite what "done" means before typing.

### 2. Write the test first

For new logic, write the failing test before any implementation. See the `test-driven-development` skill. The test encodes the acceptance criterion.

For a bug fix, use the **Prove-It pattern**: write a test that reproduces the bug and fails on current `main`. Only then fix it.

### 3. Run the test — it must fail

If it passes on an empty implementation, the test is wrong or the behavior already exists. Don't move on.

### 4. Implement the minimum to make it pass

No speculative abstractions. No "I'll also handle X while I'm here." The goal is the smallest diff that turns the test green.

### 5. Run the full gate chain

```bash
uv run ruff check . && uv run ruff format --check . && uv run mypy src && uv run pytest
```

All four must pass. If they don't, fix and re-run. Don't commit red.

### 6. Refactor (optional, but isolated)

If the implementation is ugly, clean it up **now** — while the context is fresh. But do not mix refactor and feature in the same commit. See the `git-workflow-and-versioning` skill.

### 7. Commit

One task → one (or more) atomic commit(s). Message format:

```
<type>(<area>): <imperative summary>

<why, not what>

Refs spec/<feature>.md, task T<n>
```

## Red flags

- You wrote implementation before any test
- You mixed refactor + feature in one commit
- You skipped running tests "because the change is trivial"
- You added code that isn't required by any acceptance criterion
- You started on T3 while T2 isn't merged
- You stubbed a function and said "I'll add the real logic later" — later is now

## Verification (per slice)

- [ ] Failing test committed first (or visible in the test run before the fix)
- [ ] All gates pass: ruff, ruff format, mypy, pytest
- [ ] Diff ≤ 100 LOC
- [ ] Commit references the spec and task ID
- [ ] No TODOs left in the diff without a tracked issue

Full upstream version: <https://github.com/addyosmani/agent-skills/blob/main/skills/incremental-implementation/SKILL.md>
