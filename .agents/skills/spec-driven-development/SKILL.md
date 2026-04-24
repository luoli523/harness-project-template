---
name: spec-driven-development
description: Produces a structured feature specification before any code is written. Use when starting a new feature, when requirements are ambiguous or only exist as a rough idea, when a change will touch multiple modules, or when implementation would take more than ~30 minutes.
---

# Spec-Driven Development

Write a structured specification before writing any code. The spec is the shared contract between the human and the agent: what we're building, why, and how we'll know it's done.

## When to use

- Starting a new feature or significant change
- Requirements are ambiguous or only exist as a rough idea
- The change will touch more than one module
- Implementation would take more than ~30 minutes

**Skip only for:** typo fixes, comment edits, config-value tweaks scoped by the user.

## Process

### 1. Surface assumptions first

Before writing spec content, list what you're assuming. Example:

```
ASSUMPTIONS
1. Deploy target is Docker + k8s (based on existing infra)
2. Persistence is Postgres (no current DB in repo; confirming)
3. Auth uses JWT bearer tokens issued by an upstream SSO
4. Expected RPS < 100 (no load requirements given)
→ Correct any of these before I proceed.
```

The spec's primary purpose is to surface misunderstandings *before* code exists.

### 2. Write `spec/<feature-name>.md` covering six areas

1. **Objective** — What and why. Who is the user. What success looks like.
2. **Scope** — In-scope behaviors as bullet list. **Explicitly list non-goals.**
3. **API surface** — Endpoints (method, path, auth, request/response shape). Use Pydantic model names that will exist in code.
4. **Data model** — Tables/collections or in-memory shapes the feature introduces.
5. **Edge cases & failure modes** — What happens on invalid input, external dependency down, concurrent requests, partial failure. Each with expected behavior.
6. **Acceptance criteria** — Verifiable checkboxes. "Returns 404 when order id not found" — not "handles missing orders correctly."

### 3. Get human sign-off

Post the spec. Ask for explicit approval before moving to plan phase. Don't code speculatively.

## Red flags

- You started writing code before the spec is approved
- The spec says "handles errors appropriately" without listing which errors
- No non-goals section — you haven't thought about what you're *not* doing
- Acceptance criteria are vague verbs ("handles", "supports", "works with")
- You made architectural choices (framework, library, pattern) without citing why

## Verification

Before moving to planning, the spec must pass this checklist:

- [ ] Assumptions section exists and was reviewed by a human
- [ ] Every acceptance criterion is binary (pass/fail from test output)
- [ ] Non-goals are explicit
- [ ] API surface lists concrete Pydantic model names and status codes
- [ ] Every external dependency (DB, cache, upstream service) is named
- [ ] A human has approved the spec in writing

Full upstream version: <https://github.com/addyosmani/agent-skills/blob/main/skills/spec-driven-development/SKILL.md>
