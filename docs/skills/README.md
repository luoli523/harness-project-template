# Skills

Workflow playbooks for anything that touches the codebase. Read the relevant one **before** starting work — not after.

These are condensed, project-adapted versions of the upstream [agent-skills](https://github.com/addyosmani/agent-skills) library. If a skill here feels too terse, fall back to the full version upstream.

## When to use which

| Situation | Skill |
|---|---|
| Starting a new feature / ambiguous requirements | [spec-driven-development](spec-driven-development.md) |
| Spec exists, need to break it into tasks | [planning-and-task-breakdown](planning-and-task-breakdown.md) |
| About to write code for a task | [incremental-implementation](incremental-implementation.md) |
| Adding or changing behavior | [test-driven-development](test-driven-development.md) |
| Opening a PR | [code-review-and-quality](code-review-and-quality.md) |
| Committing, branching, merging | [git-workflow-and-versioning](git-workflow-and-versioning.md) |

## How these are used

- **Claude Code users** — `/spec`, `/plan`, `/build`, `/review` slash commands auto-load the relevant skill.
- **Codex / other CLI users** — paste the prompt from `.agent/prompts/<verb>.md`, which references the skill file.
- **Humans** — read them directly; they are written to be human-readable too.

## Not seeing a skill you need?

The full 21-skill library covers browser testing, performance optimization, security hardening, API design, deprecation, and more. Pick what you need from <https://github.com/addyosmani/agent-skills/tree/main/skills> and add a project-adapted copy here.
