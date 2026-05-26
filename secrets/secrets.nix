let
  xluffy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII6gzw6c40c8zowzZ6nR8iRwsYy0qg2sNvro09nFtTzF";

  allKeys = [xluffy];
in {
  "deepseek.age".publicKeys = [xluffy];
}
