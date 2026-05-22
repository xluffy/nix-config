{
  pkgs,
  pkgs-unstable,
  llm-agents,
  ...
}: {
  home.packages = with pkgs; [
    llama-cpp
    llm-agents.claude-code
    llm-agents.codex
    llm-agents.gemini-cli
    llm-agents.qwen-code
    pkgs-unstable.llm
  ];
}
