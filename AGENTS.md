# di2vibe — Agent Instructions

This file is the **single source of truth** for how agents (Claude Code, Codex, Cursor, etc.) should work in this repo. Read it fully before your first action.

## Tech Stack

- **Language:** Python 3.12
- **Framework:** FastAPI (ASGI)
- **Server:** uvicorn
- **Package manager:** `uv` (preferred) — falls back to `pip` if `uv` not installed
- **Lint + format:** `ruff`
- **Type check:** `mypy`
- **Tests:** `pytest` + `pytest-asyncio` + `httpx`

## Commands

```bash
# Install deps (preferred)
uv sync

# Fallback
pip install -e ".[dev]"

# Run dev server
uv run uvicorn di2vibe.main:app --reload

# Test
uv run pytest

# Lint + format
uv run ruff check .
uv run ruff format .

# Type check
uv run mypy src

# All gates (run before every PR)
uv run ruff check . && uv run ruff format --check . && uv run mypy src && uv run pytest
```

## Project Structure

```
src/di2vibe/          # Application code (installable package)
  main.py             # FastAPI app factory + entry point
  api/                # HTTP route modules (one file per resource)
tests/                # Mirrors src/ layout; test_<module>.py per module
spec/                 # Feature specifications (one .md per feature)
docs/
  skills/             # Workflow playbooks — READ THESE BEFORE WORKING
  references/         # Checklists (testing, security)
  workflows/          # Team conventions (PR flow, commits)
.agent/prompts/       # Tool-agnostic prompt templates for non-Claude users
.claude/              # Claude Code–specific ergonomics (commands, hooks)
```

## Workflow (mandatory)

Every change — no matter how small — follows this gated flow:

```
SPEC ──► PLAN ──► BUILD ──► REVIEW ──► SHIP
```

1. **SPEC** — Before writing code for a new feature, produce `spec/<feature>.md`. See `docs/skills/spec-driven-development.md`.
2. **PLAN** — Break the spec into tasks ≤ 100 LOC each, with acceptance criteria. See `docs/skills/planning-and-task-breakdown.md`.
3. **BUILD** — One task at a time, TDD-first (red → green → refactor). See `docs/skills/incremental-implementation.md` and `docs/skills/test-driven-development.md`.
4. **REVIEW** — Self-check against the 5-axis list (correctness, readability, architecture, security, performance) in `docs/skills/code-review-and-quality.md` before opening the PR.
5. **SHIP** — PR needs: CI green, at least one human reviewer, linked spec.

Skip this flow only for: typo fixes, comment-only edits, config-value tweaks explicitly scoped by the user.

## Skill Index (read these before claiming to follow them)

| When you're about to... | Read |
|---|---|
| Design a feature | `docs/skills/spec-driven-development.md` |
| Break work into tasks | `docs/skills/planning-and-task-breakdown.md` |
| Start implementing | `docs/skills/incremental-implementation.md` |
| Write or change logic | `docs/skills/test-driven-development.md` |
| Open a PR | `docs/skills/code-review-and-quality.md` |
| Commit | `docs/skills/git-workflow-and-versioning.md` |

Full versions of all 21 skills live upstream at <https://github.com/addyosmani/agent-skills>.

## Code Style

- 4-space indentation (PEP 8, enforced by ruff).
- Type hints on every public function; `mypy --strict` on `src/`.
- One class / concept per module; don't create `utils.py` dump files.
- Prefer `async def` route handlers even for CPU-bound stubs — FastAPI benefits from consistent async.
- Pydantic models for request/response bodies. No raw dicts on the API boundary.
- Functions do one thing. If a function needs a comment explaining *what* it does, split it.
- Comments explain *why*, not *what*. Good names make *what* obvious.
- Error messages are actionable: say what went wrong AND what to do about it.

## Testing Strategy

- **Unit** (70%) — pure logic, no I/O, no network.
- **Integration** (25%) — route + DB + dependencies, via `httpx.AsyncClient` + TestClient.
- **E2E** (5%) — full app boot, real adapters. Add sparingly.
- Tests must fail before the fix and pass after (Prove-It pattern for bugs).
- No test ever mocks the system under test. See `docs/references/testing-patterns.md`.

## Boundaries

**Always:**
- Read the relevant `docs/skills/*.md` before claiming to follow that workflow.
- Run the full gate chain (`ruff` + `mypy` + `pytest`) locally before pushing.
- Reference the spec file in your commit message (`Refs spec/<feature>.md`).
- Write tests **before** implementation code for new logic.

**Never:**
- Commit without running tests.
- Add a new dependency without recording rationale in the PR description.
- Create `utils.py`, `helpers.py`, or any grab-bag module.
- Skip writing tests with "the code is trivial" — trivial code still breaks at boundaries.
- Use `--no-verify` to bypass pre-commit hooks.
- Silence mypy/ruff errors with `# type: ignore` or `# noqa` without a one-line justification comment.

## Tool-specific Notes

- **Claude Code users:** use `/spec`, `/plan`, `/build`, `/review` slash commands (defined in `.claude/commands/`). SessionStart shows this file automatically.
- **Codex / other CLI users:** corresponding prompts are in `.agent/prompts/*.md` — paste the relevant one and fill in the `{{feature}}` / `{{task}}` placeholder.
- Regardless of tool: CI is the ground truth. If CI fails, the PR is not mergeable, period.
