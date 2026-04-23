# Planning & Task Breakdown

Turn an approved spec into a sequence of small, verifiable tasks. Each task is something a single agent-human pair can finish, review, and merge independently.

## When to use

- Spec is approved (see [spec-driven-development](spec-driven-development.md))
- Scope is larger than a single file change
- Multiple people/agents might work in parallel

## Sizing rule

**Each task ≤ 100 LOC of diff.** If a task would exceed this, split it further — even if the split feels artificial. Small diffs:
- Review faster
- Revert cleaner
- Merge without conflict
- Keep CI feedback tight

## Process

### 1. List every change the spec requires

Don't dedupe yet. Sources:
- New API routes
- New/changed Pydantic models
- New/changed business logic
- Schema migrations
- Config / env vars
- Tests (yes, they get their own line items if non-trivial)
- Docs / ADR

### 2. Group into ordered tasks

Order matters — put foundational pieces first:
1. Data models & migrations
2. Business logic (pure functions, no I/O)
3. Adapters (DB queries, external HTTP clients)
4. Route handlers wiring the above
5. Integration tests
6. Docs & changelog

Each task gets:
- **Title** — imperative, ≤ 10 words
- **Acceptance criteria** — 2–5 binary checkboxes
- **Blocked by** — IDs of tasks that must land first
- **Estimated diff size** — lines added/removed

### 3. Write it down

Append the task list to `spec/<feature>.md` under `## Tasks` or create `spec/<feature>-tasks.md`. Format:

```markdown
## Tasks

### T1: Add Order pydantic model
- Acceptance:
  - [ ] `src/di2vibe/models/order.py` defines `Order` with fields from spec §4
  - [ ] `tests/models/test_order.py` covers validation for each field
- Blocked by: —
- Size: ~40 LOC

### T2: Add GET /orders/{id} route (happy path only)
- Acceptance:
  - [ ] Returns 200 + Order JSON when id exists
  - [ ] Returns 404 with `OrderNotFound` error model otherwise
  - [ ] Integration test covers both cases
- Blocked by: T1
- Size: ~60 LOC
```

### 4. Get sign-off before building

The human reviews the task list. They may reorder, split further, or cut scope. Don't start T1 until the list is approved.

## Red flags

- A task has no acceptance criteria, just "implement X"
- Multiple tasks all blocked by nothing — you probably missed a dependency
- A task is estimated at "200 LOC" — split it
- Acceptance criteria reference implementation details ("uses a dict comprehension") instead of observable behavior
- You're planning two weeks of work in one pass — cut at the first natural checkpoint and re-plan after it ships

## Verification

- [ ] Every task has binary acceptance criteria
- [ ] Every task ≤ 100 LOC estimate
- [ ] Dependency graph has no cycles
- [ ] Human approved the list

Full upstream version: <https://github.com/addyosmani/agent-skills/blob/main/skills/planning-and-task-breakdown/SKILL.md>
