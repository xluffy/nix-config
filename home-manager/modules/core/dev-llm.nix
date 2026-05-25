{
  pkgs,
  llm-agents,
  ...
}: {
  home.packages = with pkgs; [
    llama-cpp
    llm-agents.claude-code
    llm-agents.pi
  ];
}
