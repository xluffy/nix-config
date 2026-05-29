---
description: Generate a commit message from staged changes
---
Generate a git commit message based on `git diff --cached` (or `git diff` if nothing is staged).

Rules for the commit message:
- The first line should be a short summary of the changes, without emojis
- Explain the 'why' behind changes
- Use bullet points for multiple changes
- If there are no changes, or the input is blank — return a blank string

Think carefully before you write the commit message.

Output the commit message in this format:

Summary of changes
- change 1
- change 2

Then, on a new line after the commit message, suggest a git branch name following the repo's convention (e.g., `feat/<scope>/<what>`, `fix/<scope>/<what>`, `refactor/<scope>/<what>`):

Branch: <suggested-branch-name>
