<!--
Before opening: walk docs/skills/code-review-and-quality.md on your own diff.
Keep this PR ≤ 400 LOC. If bigger, split or justify.
-->

## Linked spec

<!-- e.g. spec/orders.md -->

## Tasks closed

<!-- e.g. T2, T3 -->

## Why this approach

<!-- 2–3 sentences. What alternatives did you consider? Why this one? -->

## New dependencies

<!-- List each with a one-line rationale, or "none". -->

## Risk / rollback

<!-- What could break. How to revert. Any data migrations? Feature-flagged? -->

## Test plan

<!-- Commands you ran. Manual verification steps. Screenshots if UI. -->

- [ ] `uv run ruff check .` passes
- [ ] `uv run ruff format --check .` passes
- [ ] `uv run mypy src` passes
- [ ] `uv run pytest` passes
- [ ] Self-reviewed against the 5-axis checklist
- [ ] Spec acceptance criteria checked off (if task complete)
