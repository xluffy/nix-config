_: {
  home.file = {
    ".pi/agent/settings.json".source = ../../config/pi/settings.json;
    ".pi/agent/models.json".source = ../../config/pi/models.json;
    ".pi/agent/cached-op.sh" = {
      source = ../../config/pi/cached-op.sh;
      executable = true;
    };
    ".pi/agent/skills/nix-helper/SKILL.md".source = ../../config/pi/skills/nix-helper/SKILL.md;
    ".pi/agent/skills/git-helper/SKILL.md".source = ../../config/pi/skills/git-helper/SKILL.md;
    ".pi/agent/skills/nix-config-helper/SKILL.md".source = ../../config/pi/skills/nix-config-helper/SKILL.md;
  };
}
