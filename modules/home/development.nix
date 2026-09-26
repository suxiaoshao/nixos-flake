{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    nodejs
    pnpm
    rust-bin.stable.latest.default

    # Preserve Clang as the default cc/c++, alongside explicit gcc/g++ commands.
    (lib.hiPrio clang)
    gcc
    mold
    pkg-config
    openssl
    openssl.dev
    postgresql

    nixd
    nil
    nixfmt
  ];

  home.sessionVariables.PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.postgresql.dev}/lib/pkgconfig";
}
