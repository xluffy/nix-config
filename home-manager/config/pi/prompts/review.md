---
description: Review staged git changes
---
Review the staged changes from `git diff --cached`. Focus on:

- **Bugs & logic errors**: Missed edge cases, off-by-one, null/undefined handling
- **Security issues**: Exposed secrets, injection risks, insecure defaults
- **Error handling gaps**: Missing error paths, silent failures, unhandled promises
- **Code quality**: Duplication, unclear naming, unnecessary complexity
- **Consistency**: Adherence to conventions and patterns used in the rest of the codebase

If nothing is staged, note that and suggest running `git add` first.

Output your review as:

### Summary
Brief overview of what changed

### Issues
- 🔴 **Critical**: items that must be fixed before merge
- 🟡 **Warning**: items that should be addressed
- 🟢 **Suggestion**: nice-to-have improvements

### Recommendations
Actionable next steps
