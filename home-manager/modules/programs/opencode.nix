{
  config,
  pkgs,
  ...
}: let
  homeDir = config.home.homeDirectory;

  opencode-wrapped = pkgs.writeShellScriptBin "opencode" ''
    set -euo pipefail

    CACHED_OP="${homeDir}/.pi/agent/cached-op.sh"
    WORK_DIR="${homeDir}/code/work"

    # ============================================================
    # Work mode — Anthropic Claude Opus via SKM (Vertex AI)
    # ============================================================
    if [[ ''${PWD} == ''${WORK_DIR}* ]]; then
      [[ -f "''${WORK_DIR}/.envrc.local" ]] && source "''${WORK_DIR}/.envrc.local"

      printf "\033[1;35m"
      printf "╔══════════════════════════════════════╗\n"
      printf "║      WORK MODE — Claude Opus         ║\n"
      printf "╚══════════════════════════════════════╝\n"
      printf "\033[0m\n"

      export OPENCODE_CONFIG_CONTENT
      OPENCODE_CONFIG_CONTENT='{"model":"skm/claude-opus-4-6"}'

    # ============================================================
    # Personal mode — DeepSeek V4 Pro / V4 Flash
    # ============================================================
    else
      printf "\033[1;32m"
      printf "╔══════════════════════════════════════╗\n"
      printf "║  PERSONAL — DeepSeekV4               ║\n"
      printf "╚══════════════════════════════════════╝\n"
      printf "\033[0m\n"

      if [[ -x "''${CACHED_OP}" ]]; then
        export DEEPSEEK_API_KEY
        DEEPSEEK_API_KEY=$("''${CACHED_OP}" "op://Private/china-ai-api-key/deepseek-api-key")
      fi
    fi

    exec ${pkgs.opencode}/bin/opencode "$@"
  '';
in {
  home.packages = [opencode-wrapped];

  home.file = {
    ".config/opencode/opencode.json".source = ../../config/opencode/opencode.json;
    ".config/opencode/APPEND_SYSTEM.md".source = ../../config/opencode/APPEND_SYSTEM.md;
    ".config/opencode/skills".source = ../../config/opencode/skills;
  };
}
