# harness-project-template

A **GitHub template** for spinning up Python + FastAPI services that are ready for multi-agent collaboration (Claude Code, Codex, Cursor, and humans) on day one.

What you get out of the box:

- A working FastAPI scaffold (`src/di2vibe/`, one `/health` endpoint) with passing tests.
- A tool-agnostic workflow — `SPEC → PLAN → BUILD → REVIEW → SHIP` — encoded as skills any agent can read.
- Pre-wired CI gates: `ruff` + `mypy --strict` + `pytest`, plus pre-commit hooks.
- Slash commands (`/spec`, `/plan`, `/build`, `/review`) for Claude Code, and equivalent prompts for any other agent.

`di2vibe` inside `src/` is just an example placeholder package — you rename it to your service name after cloning (see [Step 2](#2-rename-the-example-package) below).

## Use this template

### Option A — GitHub UI

1. Open <https://github.com/luoli523/harness-project-template>.
2. Click **Use this template → Create a new repository**.
3. Give it a name, choose owner/visibility, click **Create repository from template**.
4. `git clone` your new repo and follow [Post-clone setup](#post-clone-setup).

### Option B — GitHub CLI

```bash
gh repo create <your-org>/<your-service> \
  --template luoli523/harness-project-template \
  --private --clone
cd <your-service>
```

Then continue below.

## Post-clone setup

### 1. Install the toolchain

```bash
# Install uv once (skip if you already have it)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install deps + dev extras
uv sync --all-extras

# Install pre-commit hooks
uv run pre-commit install
```

Sanity check — the scaffold should be green right after cloning:

```bash
uv run ruff check . && uv run ruff format --check . && uv run mypy src && uv run pytest
uv run uvicorn di2vibe.main:app --reload   # → http://localhost:8000/health
```

### 2. Rename the example package

`di2vibe` appears in source, tests, configs, and a few docs. Replace it with your service name (lowercase, valid Python identifier — e.g. `orders_api`):

```bash
NEW_NAME=orders_api

# Rename the package directory
git mv src/di2vibe src/$NEW_NAME

# Replace remaining references (macOS sed; drop the '' on Linux)
grep -rl di2vibe . --exclude-dir=.git --exclude-dir=.venv \
  | xargs sed -i '' "s/di2vibe/$NEW_NAME/g"
```

This rewrites `pyproject.toml` (`[project].name`, `description`, hatch `packages`), source imports, tests, and a few doc references in one pass. `uv.lock` also gets touched — that's fine, the only reference is the project's own name field. Re-sync and re-run the gate chain to confirm nothing broke:

```bash
uv sync && uv run ruff check . && uv run ruff format --check . && uv run mypy src && uv run pytest
```

### 3. Make it yours

- Edit `AGENTS.md` — change the **Tech Stack** line if you swap out FastAPI/uv/etc., and prune anything that doesn't apply. This file is the single source of truth all agents read.
- Edit this `README.md` — replace the template intro with a description of *your* service.
- Delete the example `src/<your_pkg>/api/health.py` and its test once you have real endpoints (or keep it as a liveness probe).
- Add real specs under `spec/<feature>.md` as you start building (use `/spec <feature>` if you're on Claude Code).

### 4. Wire up CI (already done) and branch protection (you do this)

CI runs on push to `main` and on every PR — see `.github/workflows/ci.yml`. Once your repo exists on GitHub, add a branch protection rule on `main` that requires the `lint-type-test` check to pass before merging.

## How the workflow works

Every change — feature, fix, refactor — goes through the same gated flow:

```
SPEC  →  PLAN  →  BUILD  →  REVIEW  →  SHIP
```

| Step | What it produces | Skill | Claude command |
|---|---|---|---|
| **SPEC** | `spec/<feature>.md` describing the change | `spec-driven-development` | `/spec <feature>` |
| **PLAN** | Task list, each task ≤ 100 LOC with acceptance criteria | `planning-and-task-breakdown` | `/plan spec/<feature>.md` |
| **BUILD** | One task at a time, TDD-first (red → green → refactor) | `incremental-implementation`, `test-driven-development` | `/build spec/<feature>.md T<n>` |
| **REVIEW** | Self-check against the 5-axis list | `code-review-and-quality` | `/review` |
| **SHIP** | PR linked to the spec, CI green, one human review | `git-workflow-and-versioning` | — |

Skill playbooks live in `.agents/skills/<name>/SKILL.md`. Both Claude Code and Codex auto-discover that path. Read [AGENTS.md](AGENTS.md) for the full rules.

## Repository layout

```
AGENTS.md                Single source of truth for all agents
CLAUDE.md                Pointer to AGENTS.md (Claude Code reads this on session start)

src/<your_pkg>/          Application code (rename from di2vibe)
tests/                   Mirrors src/ layout
spec/                    One .md per feature

.agents/skills/          Workflow playbooks (tool-agnostic, auto-discovered)
.agent/prompts/          Same flows as plain-text prompts for tools without skill support
.claude/                 Claude Code commands + permissions

docs/
  references/            testing-patterns.md, security-checklist.md
  workflows/             pr-flow.md, commit-conventions.md

.github/workflows/ci.yml CI: ruff → ruff format --check → mypy → pytest
.pre-commit-config.yaml  Same gates locally before commit
pyproject.toml           Deps, ruff/mypy/pytest config
```

## Agent entry points

| Tool | How to use it |
|---|---|
| **Claude Code** | `/spec`, `/plan`, `/build`, `/review` (defined in `.claude/commands/`) |
| **Codex CLI** | Type `$<skill-name>` to mention, or `/skills` to pick — `.agents/skills/` is native |
| **Cursor / Aider / other** | Open `.agents/skills/<name>/SKILL.md`, or paste the matching `.agent/prompts/*.md` |
| **Human** | Read [AGENTS.md](AGENTS.md), then the relevant `.agents/skills/<name>/SKILL.md` |

All tools produce work that must pass the same CI gates — no tool gets to skip the rules.

## Customizing the template itself

If you fork this template to make your own variant (different stack, different skills):

- Swap the FastAPI scaffold under `src/` for your stack of choice.
- Update **Tech Stack** and **Commands** sections in `AGENTS.md`.
- Edit `.github/workflows/ci.yml` to match the new gate chain.
- Trim or replace skills under `.agents/skills/` — the 6 included here are condensed from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills); link upstream from each `SKILL.md` so users can find the full version.

## Upstream reference

The skill playbooks in `.agents/skills/` are project-adapted condensed versions of [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills). When a project-local skill feels too terse, the upstream full version is linked at the bottom of each `SKILL.md`.
