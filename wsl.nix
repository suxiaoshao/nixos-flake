{
  pkgs,
  ...
}:
{
  wsl.enable = true;
  wsl.defaultUser = "nixos";
  wsl.docker-desktop.enable = true;
}
