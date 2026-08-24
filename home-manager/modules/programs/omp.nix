_: {
  programs.omp = {
    enable = true;
    settings = {
      startup.quiet = true;
      theme.dark = "titanium";
      defaultThinkingLevel = "xhigh";
    };
  };

  home.file = {
    ".omp/agent/prompts/spec-workflow.md".source = ../../config/pi/prompts/spec-workflow.md;
    ".omp/agent/prompts/spec-quick.md".source = ../../config/pi/prompts/spec-quick.md;
    ".omp/agent/prompts/review.md".source = ../../config/pi/prompts/review.md;
    ".omp/agent/prompts/git-ci.md".source = ../../config/pi/prompts/git-ci.md;
    ".omp/agent/prompts/grill-me.md".source = ../../config/pi/prompts/grill-me.md;
    ".omp/agent/prompts/audit-me.md".source = ../../config/pi/prompts/audit-me.md;
    ".omp/agent/prompts/handoff.md".source = ../../config/pi/prompts/handoff.md;
  };
}
