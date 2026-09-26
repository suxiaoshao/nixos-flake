{
  username ? "nixos",
  homeDirectory ? "/home/${username}",
  ...
}:

{
  imports = [
    ./codex.nix
    ./development.nix
    ./git.nix
    ./shell.nix
  ];

  home.username = username;
  home.homeDirectory = homeDirectory;

  home.stateVersion = "25.11";
}
