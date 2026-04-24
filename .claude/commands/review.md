---
description: Review the current diff against the 5-axis checklist
---

Follow the `code-review-and-quality` skill in `.agents/skills/code-review-and-quality/SKILL.md`. Target: **$ARGUMENTS** (branch name, commit SHA, PR number, or blank for current uncommitted diff).

Key rules:
- Walk axes in order: correctness → readability → architecture → security → performance.
- Every finding needs: what (file:line), why it's a problem, suggested fix.
- End with verdict: APPROVE / REQUEST CHANGES / COMMENT + one-paragraph summary.
- Do not edit any files.
