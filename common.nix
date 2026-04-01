{
  pkgs,
  rust-overlay,
  systemStateVersion ? "25.11",
  ...
}:
{
  system.stateVersion = systemStateVersion;

  nixpkgs.overlays = [ rust-overlay.overlays.default ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    git
    wget

    nodejs
    pnpm

    rust-bin.stable.latest.default
    openssl
    openssl.dev
    pkg-config
    clang
    gcc
    mold
    postgresql

    nix-ld
  ];

  environment.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.postgresql.dev}/lib/pkgconfig";
  };

  programs.nix-ld.enable = true;
}
