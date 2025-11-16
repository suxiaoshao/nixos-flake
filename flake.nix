{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-25.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      home-manager,
      rust-overlay,
      flake-utils,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
      };
    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            nixos-wsl.nixosModules.default
            {
              system.stateVersion = "25.05";
              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
              environment.systemPackages = with pkgs; [
                # self
                git
                wget

                # node
                nodejs

                # rust dev
                openssl
                openssl.dev
                pkg-config
                clang
                gcc
                mold
                postgresql
                rust-bin.stable.latest.default
              ];
              # nixpkgs.overlays = [ rust-overlay.overlays.default ];
              # devShells.${system}.default =
              #   with pkgs;
              #   mkShell {
              #     packages = [

              #     ];
              #   };
              environment.sessionVariables = {
                PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
              };
            }
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # TODO replace ryan with your own username
              home-manager.users.nixos = import ./home.nix;

              # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
            }
            ./wsl.nix
          ];
        };
      };
    };
}
