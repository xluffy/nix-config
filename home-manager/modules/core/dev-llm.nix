{
  pkgs,
  pkgs-unstable,
  llm-agents,
  ...
}: {
  home.packages = with pkgs; [
    pkgs-unstable.llama-cpp
    llm-agents.claude-code
    llm-agents.pi
    pkgs.gitingest
  ];
}
