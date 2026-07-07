# Pi Agent Configuration

Personal pi coding agent setup. Minimal, intentional, software-engineering focused.

## Philosophy

- **KISS** - Keep it simple. No bloat, no magic, no fancy abstractions.
- **Prompts over skills** - Custom prompt templates are the primary interface. Skills are only for narrow, repeatable domain knowledge (nix, bash, laravel).
- **No internet copy-paste** - Every skill, prompt, and extension here is hand-written for real workflows. Zero cloned "awesome" lists or viral dotfiles.
- **Software engineering focus** - Spec-driven development, code review, git workflows. Not a general-purpose chatbot.
- **Minimal extensions** - Two custom extensions: a model provider and a footer. No bloat.

## Structure

```
pi/
├── APPEND_SYSTEM.md       # System policy: no em dashes, minimize semicolons
├── prompts/               # Core: custom prompt templates
│   ├── spec-workflow.md   # Full spec → plan → implement → review
│   ├── spec-quick.md      # Lightweight spec for small changes
│   ├── review.md          # Code review against specs & best practices
│   ├── git-ci.md          # Git commit & CI pipeline guidance
│   ├── grill-me.md        # Stress-test a plan/design through Q&A
│   ├── audit-me.md        # Audit code/documents against criteria
│   └── handoff.md         # Handoff context between sessions
├── skills/                # Narrow, repeatable domain knowledge
│   ├── nix-helper/
│   ├── nix-config-helper/
│   ├── bash-scripting/
│   ├── laravel-helper/
│   └── laravel-best-practices/
├── extensions/            # Custom pi extensions
│   ├── company-provider.ts
│   └── minimal-footer.ts
├── models.json            # Model definitions (deepseek, mimo, claude)
├── settings.json          # Pi agent settings
└── cached-op.sh           # Cached operation helper
```

## Rules

1. No new skill unless it solves a **recurring, narrow, well-defined** problem.
2. New prompts must stay under 200 lines. If it's longer, split it or simplify.
3. No third-party extensions - if it's not in this repo, it's not needed.
4. All prompt templates and skills must follow `APPEND_SYSTEM.md` (no em dashes in prose, minimize semicolons).
5. All changes go through `just check` before `just switch`.
