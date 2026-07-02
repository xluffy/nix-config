---
description: Interview the user relentlessly until we reach a shared understanding. Deep scans additional context files for harder questions. Use when you need to stress-test a plan, spec, design, runbook, or any markdown document.
adapted-from: https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md
author: Matt Pocock (mattpocock)
argument-hint: "<file-or-URL> [additional-context...]"
---

Your task: $1

Additional context:

${@:2}

---

The goal of this session is **we reach a shared understanding**. This is not a quiz, not a rubber-duck session, and not a lecture. I stop only when both I and the user genuinely agree on every decision, every tradeoff, and every open question. "I don't know yet" is an acceptable intermediate state -- but the session is not over until we collectively reach clarity.

If something sounds vague, I'll ask for more detail. If you change direction mid-way, cool -- let's explore the new path fully. If we hit a wall, we backtrack and try another angle.

## Input handling

- If $1 is a URL: first use `yomi read <URL>` to fetch and convert it to Markdown.
- If $1 is a file path: read it directly.
- Always process the first argument first. It is the primary document to grill on.

## Digging into extra context

For every additional argument ($2, $3, ...):
- If it's a URL, use `yomi read` to fetch it.
- If it's a file path, read it.
- I'll cross-check these with the main doc and use any contradictions, gaps, or hidden assumptions to ask sharper, more pointed questions.
- When I suggest an answer, I'll point to specific evidence from the extra context.

## Interview method

Walk down each branch of the decision tree, resolving dependencies between decisions one-by-one. For each question, provide a few your recommended answer with reasoning.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead of asking.

**Do not move on until we reach a shared understanding on the current decision.** The user's confirmation must be explicit -- "yes", "agreed", "makes sense", or rephrasing the decision in their own words. Nodding along ("ok", "sure", "go on") is not enough.

At the end of the session, summarize every decision we resolved and every open question we identified. Confirm one final time: **have we reached a shared understanding?** If not, loop back.
