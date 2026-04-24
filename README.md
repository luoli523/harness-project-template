# di2vibe

A Python + FastAPI service, scaffolded for multi-agent collaboration (Claude Code, Codex, Cursor, and humans).

## Quick start

```bash
# Install uv (once, if you don't have it)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install deps
uv sync --all-extras

# Run
uv run uvicorn di2vibe.main:app --reload
# → http://localhost:8000/health

# Gates (run before every PR)
uv run ruff check . && uv run ruff format --check . && uv run mypy src && uv run pytest

# Pre-commit hooks (once per clone)
uv run pre-commit install
```

## How this repo works

This project uses **spec-driven, test-first, small-diff** workflows. Every change — feature, fix, refactor — follows the same gated flow:

```
SPEC  →  PLAN  →  BUILD  →  REVIEW  →  SHIP
```

The rules, commands, and skill playbooks live in:

- **[AGENTS.md](AGENTS.md)** — single source of truth. Read this first.
- **[.agents/skills/](.agents/skills/)** — workflow playbooks (Claude Code + Codex auto-discover these).
- **[docs/references/](docs/references/)** — testing patterns, security checklist.
- **[docs/workflows/](docs/workflows/)** — PR flow, commit conventions.

## For agents

| Tool | Entry point |
|---|---|
| **Claude Code** | Slash commands: `/spec`, `/plan`, `/build`, `/review` (defined in `.claude/commands/`) |
| **Codex CLI** | `$<skill-name>` to mention, or `/skills` to pick — `.agents/skills/` is auto-discovered |
| **Cursor / Aider / other** | Open `.agents/skills/<name>/SKILL.md` or paste a prompt from `.agent/prompts/*.md` |
| **Human** | Read [AGENTS.md](AGENTS.md), then the relevant `.agents/skills/<name>/SKILL.md` |

All tools produce work that must pass the same CI gates — no tool gets to skip the rules.

## Project layout

```
src/di2vibe/          Application code (installable package)
tests/                Mirrors src/ layout
spec/                 Feature specifications (one .md per feature)
.agents/skills/       Workflow playbooks — the rules (tool-agnostic)
docs/
  references/         Testing + security checklists
  workflows/          PR flow, commit conventions
.agent/prompts/       Prompts for tools without native skill support
.claude/              Claude Code config (commands, permissions)
.github/workflows/    CI pipeline
```

## Contributing (TL;DR)

1. Read `AGENTS.md`.
2. New feature? Run `/spec <feature>` (or paste `.agent/prompts/spec.md`). Get the spec approved.
3. `/plan spec/<feature>.md` — break into tasks ≤ 100 LOC each.
4. For each task: `/build spec/<feature>.md T<n>` — TDD-first.
5. `/review` before opening the PR.
6. PR must link the spec and be green on CI.

See [docs/workflows/pr-flow.md](docs/workflows/pr-flow.md) for full details.

## Upstream reference

The skill playbooks in `.agents/skills/` are project-adapted condensed versions of [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills). When a project-local skill feels too terse, the upstream full version is linked at the bottom of each SKILL.md.
