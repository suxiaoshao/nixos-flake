{
  username ? "nixos",
  homeDirectory ? "/home/${username}",
  ...
}:

{
  imports = [
    ./codex.nix
    ./shell.nix
  ];

  home.username = username;
  home.homeDirectory = homeDirectory;

  programs.git = {
    enable = true;
    settings.user = {
      name = "suxiaoshao";
      email = "48886207+suxiaoshao@users.noreply.github.com";
    };
  };

  home.stateVersion = "25.11";
}
