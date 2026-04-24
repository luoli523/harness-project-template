---
name: test-driven-development
description: Writes a failing test before the implementation and uses the Prove-It pattern for bug fixes. Use when adding any new business logic, when fixing any bug, or when changing an existing function's behavior.
---

# Test-Driven Development

Write the test before the code. The test defines "done"; the implementation is whatever is needed to make it pass.

## When to use

- Any new business logic
- Any bug fix (use the Prove-It pattern below)
- Any change to an existing function's behavior

**Skip only for:** cosmetic changes (renames, comments, formatting) and pure config edits that have no runtime branching.

## The cycle

```
RED  →  GREEN  →  REFACTOR
```

1. **RED** — Write a test for the behavior you want. Run it. It must fail (and fail for the reason you expect — a missing function, not a syntax error).
2. **GREEN** — Write the minimum code to make the test pass. Not elegant — minimum.
3. **REFACTOR** — Clean up while tests stay green. Names, duplication, structure. Commit refactor separately from the red→green commit.

## The Prove-It pattern (for bugs)

Before fixing any bug:

1. Write a test that reproduces the reported behavior.
2. Run it on current `main`. It **must fail**.
3. Commit the test with a commit message like `test(orders): reproduce #123 — 404 instead of 403 on forbidden order`.
4. Apply the fix.
5. Run the test. It **must pass**.
6. Commit the fix.

This guarantees the bug stays fixed and the regression is catchable.

## Test pyramid (this project)

| Layer | Share | Characteristics |
|---|---|---|
| Unit | ~70% | Pure functions, no I/O, no network, < 10ms each |
| Integration | ~25% | Route + Pydantic + fake/stub adapter via `httpx.AsyncClient` |
| E2E | ~5% | Full app boot, real adapters. Add sparingly — they are slow and flaky. |

## Testing conventions

- **File layout:** `tests/` mirrors `src/di2vibe/`. `src/di2vibe/api/health.py` → `tests/api/test_health.py`.
- **Naming:** `test_<unit>_<condition>_<expected>()`. E.g. `test_get_order_returns_404_when_missing`.
- **Structure:** Arrange / Act / Assert separated by blank lines.
- **Prefer DAMP over DRY in tests** — repetition that makes the test readable is better than a helper that requires cross-referencing.
- **Never mock the system under test.** Mock its dependencies, not itself.
- **Never assert the negation of a bug** (`assert result != None`). Assert the positive behavior.

## FastAPI specifics

- Use `httpx.AsyncClient(transport=ASGITransport(app=app))` via `pytest-asyncio` for route tests — faster than starlette's `TestClient` and consistent with production async behavior.
- Override dependencies with `app.dependency_overrides[...]` in a fixture; reset in teardown.
- Don't import `main.app` at module level in tests — use a factory fixture (`create_app()`) so each test gets a fresh app.

## Red flags

- Wrote the test after the implementation — you don't know if it catches the bug
- Test passes on an empty function
- Test name is `test_orders` with no condition
- Test mocks the function it is testing
- Assertion count is zero ("test" just runs the code)
- You disabled a failing test with `@pytest.mark.skip` without a tracked issue

## Verification

- [ ] Test was committed failing (visible in commit history or test run)
- [ ] Test name states condition and expected outcome
- [ ] Test fails if the production code is reverted
- [ ] No `skip` / `xfail` without a linked issue

Full upstream version: <https://github.com/addyosmani/agent-skills/blob/main/skills/test-driven-development/SKILL.md>
Reference patterns: [../../../docs/references/testing-patterns.md](../../../docs/references/testing-patterns.md)
