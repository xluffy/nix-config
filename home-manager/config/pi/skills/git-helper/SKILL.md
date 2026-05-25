---
name: git-helper
description: Help with writing high-quality Git commit messages, managing branches, and reviewing changes.
---

# Git Helper Skill

This skill assists with Git repository management, ensuring semantic commit messages and a clean repository history.

## Commit Message Guidelines

Always use the Conventional Commits format for commit messages:
```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Commit Types

- `feat`: A new feature for the user, not a new feature for builds.
- `fix`: A bug fix for the user, not a fix for a build script.
- `docs`: Changes to the documentation.
- `style`: Formatting, missing semi-colons, etc.; no production code change.
- `refactor`: Refactoring production code, e.g. renaming a variable.
- `perf`: Code changes that improve performance.
- `test`: Adding missing tests, refactoring tests; no production code change.
- `build`: Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm).
- `ci`: Changes to CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs).
- `chore`: Other changes that don't modify src or test files.
- `revert`: Reverts a previous commit.

### Style Rules

1. **Imperative Mood**: Use the imperative, present tense ("change", not "changed" or "changes").
2. **Capitalization**: Do not capitalize the first letter of the description.
3. **Punctuation**: Do not end the description with a period.
4. **Length**: Keep the subject line short, ideally under 50 characters.
