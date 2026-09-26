{
  pkgs,
  systemStateVersion ? "25.11",
  ...
}:
{
  system.stateVersion = systemStateVersion;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    git
    wget
  ];

  programs.nix-ld.enable = true;
}
