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

If the user gives a vague or hand-wavy answer, push back. If the user changes their mind mid-way, explore the new direction fully. If we hit a dead end, backtrack and find another path. "Shared understanding" means the user can explain the decision back to me, and I can explain the reasoning back to them.

## Input handling

- If $1 is a URL: first use `yomi read <URL>` to fetch and convert it to Markdown.
- If $1 is a file path: read it directly.
- Always process the first argument first. It is the primary document to grill on.

## Deep scan additional context

For every additional argument ($2, $3, ...):
- If it's a URL, use `yomi read` to fetch it.
- If it's a file path, read it.
- Cross-reference these sources with the primary document.
- Use contradictions, gaps, or hidden assumptions between sources to ask harder, more pointed questions.
- When providing your recommended answer, cite specific evidence from the additional context.

## Interview method

Walk down each branch of the decision tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer with reasoning.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead of asking.

**Do not move on until we reach a shared understanding on the current decision.** The user's confirmation must be explicit -- "yes", "agreed", "makes sense", or rephrasing the decision in their own words. Nodding along ("ok", "sure", "go on") is not enough.

At the end of the session, summarize every decision we resolved and every open question we identified. Confirm one final time: **have we reached a shared understanding?** If not, loop back.
