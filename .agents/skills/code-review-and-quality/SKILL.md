---
name: code-review-and-quality
description: Walks a diff across five axes — correctness, readability, architecture, security, performance — producing actionable review comments. Use before opening a PR for self-review, when reviewing someone else's PR, or any time a diff is larger than 10 LOC.
---

# Code Review & Quality

Before opening a PR — and before approving one — walk the diff against five axes. Every finding must be actionable.

## When to use

- You are about to open a PR (self-review)
- You are reviewing someone else's PR
- Diff is larger than 10 LOC

## The five axes

Review in this order. Don't mix axes — one pass per axis keeps feedback clean.

### 1. Correctness

- Does the code do what the spec says? Walk each acceptance criterion.
- Are edge cases handled? Empty input, None, zero, negative, unicode, concurrent calls.
- Are error paths correct? Does a failure propagate the right exception / status code?
- Off-by-one, boundary conditions, floating-point comparisons.

### 2. Readability

- Can a new engineer understand this in one read?
- Names reveal intent? (Bad: `data`, `temp`, `process`. Good: `raw_order`, `validated_items`.)
- Functions do one thing? If a function needs a comment explaining what, split it.
- Comments explain *why*, not *what*? If the code explains what, the comment is noise.
- No dead code, no commented-out blocks.

### 3. Architecture

- Does this fit the existing module boundaries, or does it leak concerns across layers?
- New dependency justified? (Added to pyproject.toml with rationale in PR description.)
- Is the test at the right layer? (Unit for logic, integration for wiring.)
- Public API: is it the smallest surface that does the job?
- Any new grab-bag modules (`utils.py`, `helpers.py`)? Reject.

### 4. Security

Walk the full [security checklist](../../../docs/references/security-checklist.md). Highlights:

- All user input validated by Pydantic at the route boundary (not raw `dict`).
- No secrets in code, commits, or logs.
- SQL parameters bound, never f-string interpolated.
- AuthZ checks on every non-public endpoint.
- External HTTP calls use timeout + retry with bounded backoff.

### 5. Performance

- N+1 queries? Look at every loop that calls a DB or HTTP client.
- Blocking I/O inside `async def`? (Requests library, sync DB drivers — must be `run_in_executor` or async equivalent.)
- Unbounded data structures? (Fetch-all-then-filter patterns.)
- Any synchronous file I/O inside a request handler?

Don't optimize speculatively. If a code path is not on a hot route, "correct and readable" beats "fast."

## Size limit

If the diff exceeds ~400 LOC (excluding tests and generated files), stop and ask the author to split. Beyond this, reviewers start skimming and the review loses value.

## Review comment format

Each comment must state:
1. **What** is wrong (be specific, reference line)
2. **Why** it's a problem (what breaks / what a reader will misread)
3. **Suggestion** (concrete fix, or "let's discuss if unclear")

```
❌ "This is confusing"
✅ "The `data` param here mixes validated and raw input — at line 42 you treat it
    as validated but line 47 assumes raw. Suggest renaming the param and
    splitting into `raw_order: dict` and `validated_order: Order`."
```

## Red flags

- Approving a PR without reading the diff
- "LGTM" with no comments on a > 100 LOC PR
- Finding something wrong but approving "because it's small"
- Review took < 5 minutes for a > 50 LOC diff
- You reviewed only the files you recognize

## Verification (before hitting "Open PR" on your own work)

- [ ] All five axes walked
- [ ] CI green locally (ruff + mypy + pytest)
- [ ] Linked spec and task IDs in PR description
- [ ] Every new dependency has a rationale line in the PR description
- [ ] No commented-out code, no orphan TODOs

Full upstream version: <https://github.com/addyosmani/agent-skills/blob/main/skills/code-review-and-quality/SKILL.md>
