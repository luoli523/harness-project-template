# Skills

Workflow playbooks that any agent in this repo should follow. This directory is **auto-discovered** by both Claude Code and Codex CLI — they scan `.agents/skills/` from the current working directory up to the repo root.

Each skill lives in its own subdirectory with a `SKILL.md` file. The YAML frontmatter (`name` + `description` starting with "Use when...") controls both how it shows up in UI selectors and when an agent will pick it up implicitly.

## Skills in this repo

| Skill | When it fires |
|---|---|
| [spec-driven-development](spec-driven-development/SKILL.md) | Starting a feature / ambiguous requirements / multi-module change |
| [planning-and-task-breakdown](planning-and-task-breakdown/SKILL.md) | Spec approved, ready to break into ≤ 100 LOC tasks |
| [incremental-implementation](incremental-implementation/SKILL.md) | About to write code — every code change starts here |
| [test-driven-development](test-driven-development/SKILL.md) | New logic / bug fix (Prove-It pattern) / changing behavior |
| [code-review-and-quality](code-review-and-quality/SKILL.md) | Self-review before PR, or reviewing someone else's |
| [git-workflow-and-versioning](git-workflow-and-versioning/SKILL.md) | Committing, branching, resolving merges |

## How each tool invokes them

- **Claude Code** — available as `/spec`, `/plan`, `/build`, `/review` slash commands (defined in `.claude/commands/`). Claude can also trigger them implicitly based on the skill descriptions.
- **Codex CLI** — type `$spec-driven-development` (or any skill name) to mention, or run `/skills` for a picker. Codex will also trigger skills implicitly from the description.
- **Cursor / Aider / other** — paste the prompt from `.agent/prompts/*.md`, or open the SKILL.md and ask your agent to follow it.

## Known issue

[openai/codex#16012](https://github.com/openai/codex/issues/16012) — repo-local `.agents/skills/` is occasionally not auto-injected on a fresh Codex session. Workaround: `AGENTS.md` in this repo explicitly lists the skill paths, so Codex will still pick them up via the instructions file.

## Adding a new skill

1. Create `.agents/skills/<kebab-case-name>/SKILL.md`.
2. Frontmatter required:
   ```yaml
   ---
   name: <kebab-case-name>
   description: <what it does>. Use when <trigger conditions>.
   ---
   ```
3. Body structure: Overview → When to use → Process → Red flags → Verification.
4. Reference other skills by name (e.g. "see the `test-driven-development` skill"), not by file path — more portable if structure shifts.

Full upstream reference for more skills: <https://github.com/addyosmani/agent-skills>.
