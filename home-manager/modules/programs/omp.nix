{
  config,
  lib,
  pkgs,
  ...
}: let
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
    ) [
      ".omp/agent"
      ".omp/profiles/personal/agent"
      ".omp/profiles/work/agent"
    ];
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
    spelling = {
      typoDetection = true;
      autocomplete = "auto";
    };
    extensions = [
      "${config.home.homeDirectory}/.omp/minimal-commands.ts"
      "${config.home.homeDirectory}/.omp/profile-indicator.ts"
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

  home.file =
    lib.genAttrs promptFiles (file: {
      source = ../../config/pi/prompts + "/${builtins.baseNameOf file}";
    })
    // {
      ".omp/minimal-commands.ts".source = ../../config/omp/minimal-commands.ts;
      ".omp/minimal.yml".source = (pkgs.formats.yaml {}).generate "omp-minimal.yml" minimalSettings;
      ".omp/profile-indicator.ts".source = ../../config/omp/profile-indicator.ts;
      ".omp/profile-status.yml".source = ../../config/omp/profile-status.yml;
    };
}
