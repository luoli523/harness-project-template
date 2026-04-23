# CLAUDE.md

This repo's instructions for all agents — including Claude Code — live in [AGENTS.md](AGENTS.md).

That file is the single source of truth. It is tool-agnostic so Codex, Cursor, Aider, and any other agent read the same conventions you do.

**Before doing anything in this repo, read `AGENTS.md`.**

## Claude-specific ergonomics

- Slash commands are in `.claude/commands/`: `/spec`, `/plan`, `/build`, `/review`.
- Each wraps a tool-agnostic prompt from `.agent/prompts/`.
- Settings (permissions) are in `.claude/settings.json`.

If you're not using Claude Code, the same flows are available via `.agent/prompts/` — paste the prompt into your tool of choice.
