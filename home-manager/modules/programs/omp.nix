{
  config,
  lib,
  pkgs,
  ...
}: let
  agentDirs = [
    ".omp/agent"
    ".omp/profiles/personal/agent"
    ".omp/profiles/work/agent"
  ];
  promptNames = [
    "audit-me"
    "git-ci"
    "grill-me"
    "spec-quick"
    "spec-workflow"
  ];
  promptFiles =
    lib.concatMap (
      agentDir: map (name: "${agentDir}/prompts/${name}.md") promptNames
    )
    agentDirs;
  # OMP appends APPEND_SYSTEM.md from the agent directory to its system prompt.
  appendSystemFiles = map (agentDir: "${agentDir}/APPEND_SYSTEM.md") agentDirs;
  minimalSettings = {
    input.bareSlashCommands = false;
    security.enabled = false;
    plan.enabled = false;
    goal.enabled = false;
    computer.enabled = false;
    ratchet.enabled = false;
    prewalk.enabled = false;
    extendedContext = false;
    collab.autoStart = "off";
    # Structural code search with the built-in ast-grep engine. OMP ships it disabled.
    astGrep.enabled = true;
    spelling = {
      typoDetection = true;
      autocomplete = "auto";
    };
    extensions = [
      "${config.home.homeDirectory}/.omp/minimal-commands.ts"
      "${config.home.homeDirectory}/.omp/profile-indicator.ts"
      "${config.home.homeDirectory}/.omp/repo-map.ts"
    ];
  };
in {
  programs.omp = {
    enable = true;
    settings =
      minimalSettings
      // {
        startup.quiet = true;
        theme.dark = "titanium";
        defaultThinkingLevel = "xhigh";
      };
  };

  # The repo_map tool in repo-map.ts runs this command.
  home.packages = [pkgs.repo-map];

  home.file =
    lib.genAttrs promptFiles (file: {
      source = ../../config/pi/prompts + "/${builtins.baseNameOf file}";
    })
    // lib.genAttrs appendSystemFiles (_: {
      source = ../../config/omp/APPEND_SYSTEM.md;
    })
    // {
      ".omp/minimal-commands.ts".source = ../../config/omp/minimal-commands.ts;
      ".omp/minimal.yml".source = (pkgs.formats.yaml {}).generate "omp-minimal.yml" minimalSettings;
      ".omp/profile-indicator.ts".source = ../../config/omp/profile-indicator.ts;
      ".omp/repo-map.ts".source = ../../config/omp/repo-map.ts;
      ".omp/profile-status.yml".source = ../../config/omp/profile-status.yml;
    };
}
