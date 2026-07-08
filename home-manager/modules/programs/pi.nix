_: {
  home.file = {
    ".pi/agent/settings.json".source = ../../config/pi/settings.json;
    ".pi/agent/models.json".source = ../../config/pi/models.json;
    ".pi/agent/cached-op.sh" = {
      source = ../../config/pi/cached-op.sh;
      executable = true;
    };
    ".pi/agent/skills/bash-scripting/SKILL.md".source = ../../config/pi/skills/bash-scripting/SKILL.md;
    ".pi/agent/skills/laravel-helper/SKILL.md".source = ../../config/pi/skills/laravel-helper/SKILL.md;
    ".pi/agent/skills/nix-config-helper/SKILL.md".source = ../../config/pi/skills/nix-config-helper/SKILL.md;
    ".pi/agent/skills/nix-helper/SKILL.md".source = ../../config/pi/skills/nix-helper/SKILL.md;
    ".pi/agent/skills/laravel-best-practices" = {
      source = ../../config/pi/skills/laravel-best-practices;
      recursive = true;
    };
    ".pi/agent/extensions/company-provider.ts".source = ../../config/pi/extensions/company-provider.ts;
    ".pi/agent/extensions/minimal-footer.ts".source = ../../config/pi/extensions/minimal-footer.ts;
    ".pi/agent/APPEND_SYSTEM.md".source = ../../config/pi/APPEND_SYSTEM.md;
    ".pi/agent/README.md".source = ../../config/pi/README.md;
    ".pi/agent/prompts/audit-me.md".source = ../../config/pi/prompts/audit-me.md;
    ".pi/agent/prompts/review.md".source = ../../config/pi/prompts/review.md;
    ".pi/agent/prompts/git-ci.md".source = ../../config/pi/prompts/git-ci.md;
    ".pi/agent/prompts/spec-workflow.md".source = ../../config/pi/prompts/spec-workflow.md;
    ".pi/agent/prompts/spec-quick.md".source = ../../config/pi/prompts/spec-quick.md;
    ".pi/agent/prompts/grill-me.md".source = ../../config/pi/prompts/grill-me.md;
    ".pi/agent/prompts/quiz-me.md".source = ../../config/pi/prompts/quiz-me.md;
    ".pi/agent/prompts/handoff.md".source = ../../config/pi/prompts/handoff.md;
  };
}
