# harness-project-template

**English** | [中文](README.zh-CN.md)

A **GitHub template** for spinning up Python + FastAPI services that are ready for multi-agent collaboration (Claude Code, Codex, Cursor, and humans) on day one.

## Why this template exists

Most "agent-friendly" project setups are tied to one tool: a `.cursor/` folder, a `.claude/` config, a `.codex/` rule file. Switch tools and you re-explain the project from scratch.

This template solves that by treating the **workflow** as the source of truth, not the tool. The rules — how to spec a feature, how to break it into tasks, how to review code — live in tool-agnostic Markdown skills under `.agents/skills/`. Claude Code and Codex auto-discover that path natively; other tools can read the same files. So whether the next contributor uses Claude, Codex, Cursor, or just opens VS Code, they all follow the same gated flow:

```
SPEC  →  PLAN  →  BUILD  →  REVIEW  →  SHIP
```

CI enforces the same gates regardless of who (or what) wrote the code.

## What you get out of the box

- **Working FastAPI scaffold** — `src/di2vibe/` with one `/health` endpoint, plus its async test. `di2vibe` is a placeholder name; you rename it in 30 seconds (see [Bootstrap](#1-bootstrap-one-command)).
- **Tool-agnostic workflow skills** — six condensed playbooks under `.agents/skills/` covering spec writing, task breakdown, incremental implementation, TDD, code review, and git workflow.
- **Pre-wired quality gates** — `ruff` (lint + format) + `mypy --strict` (on `src/`) + `pytest` (asyncio mode), enforced both by pre-commit hooks locally and by GitHub Actions on every PR.
- **Slash commands for Claude Code** — `/spec`, `/plan`, `/build`, `/review` wrap the matching skills.
- **Equivalent prompts for any other tool** — same flows as plain-text prompts under `.agent/prompts/`.
- **One-shot bootstrap script** — `scripts/init-template.sh` installs `uv`, renames the package, syncs deps, installs hooks, and runs the gates. Idempotent.

`di2vibe` inside `src/` is just an example placeholder package — you rename it to your service name during bootstrap.

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

### 1. Bootstrap (one command)

```bash
./scripts/init-template.sh <your_package_name>
# e.g. ./scripts/init-template.sh orders_api
```

This single script does everything that used to be manual:

1. Installs `uv` if it's missing.
2. Renames the example package `di2vibe` → `<your_package_name>` across source, tests, `pyproject.toml`, `uv.lock`, and docs (skipping itself).
3. Runs `uv sync --all-extras`.
4. Runs `uv run pre-commit install`.
5. Runs the full gate chain (`ruff` + `mypy` + `pytest`) so you know the scaffold is green before you start.

The script is idempotent — re-running it after a successful rename just re-syncs deps and re-runs the gates. Once everything is green, start the dev server:

```bash
uv run uvicorn <your_package_name>.main:app --reload   # → http://localhost:8000/health
```

### 2. Make it yours

- Edit `AGENTS.md` — change the **Tech Stack** line if you swap out FastAPI/uv/etc., and prune anything that doesn't apply. This file is the single source of truth all agents read.
- Edit this `README.md` — replace the template intro with a description of *your* service. The "Use this template" and "Post-clone setup" sections no longer apply once you've instantiated the repo.
- Delete `scripts/init-template.sh` — it's a one-shot bootstrap, not a long-lived tool.
- Delete the example `src/<your_pkg>/api/health.py` and its test once you have real endpoints (or keep it as a liveness probe).
- Add real specs under `spec/<feature>.md` as you start building (use `/spec <feature>` if you're on Claude Code).

### 3. Wire up branch protection

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

## Quality gates

The same gates run in three places, by design (defense in depth):

| Where | When | Tools |
|---|---|---|
| **pre-commit hook** | Before every `git commit` | trailing whitespace / EOL / yaml / toml / large files / merge conflicts; `ruff --fix`; `ruff-format`; `mypy` on `src/` |
| **`scripts/init-template.sh`** | After bootstrap | `ruff` + `ruff format --check` + `mypy` + `pytest` |
| **GitHub Actions CI** | Every push to `main`, every PR | `ruff` + `ruff format --check` + `mypy` + `pytest` |

Hooks give sub-second feedback; CI is the unbypassable ground truth. AGENTS.md forbids `--no-verify`.

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

scripts/init-template.sh One-shot bootstrap (delete after first use)
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
- Edit `.github/workflows/ci.yml` and `.pre-commit-config.yaml` to match the new gate chain.
- Update `OLD_NAME` in `scripts/init-template.sh` if you change the placeholder package name.
- Trim or replace skills under `.agents/skills/` — the 6 included here are condensed from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills); link upstream from each `SKILL.md` so users can find the full version.

## Upstream reference

The skill playbooks in `.agents/skills/` are project-adapted condensed versions of [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills). When a project-local skill feels too terse, the upstream full version is linked at the bottom of each `SKILL.md`.
