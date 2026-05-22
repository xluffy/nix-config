{
  pkgs,
  pkgs-unstable,
  llm-agents,
  ...
}: {
  home.packages = with pkgs; [
    llm-agents.claude-code
    llm-agents.codex
    llm-agents.gemini-cli
    llm-agents.qwen-code
    llama-cpp
    pkgs-unstable.llm
  ];
}
