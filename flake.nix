{
  description = "NixOS flake for WSL and OrbStack hosts";

  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?ref=nixos-26.05&shallow=1";
    nixpkgs-unstable.url = "git+https://github.com/NixOS/nixpkgs?ref=nixos-unstable&shallow=1";

    nixos-wsl = {
      url = "git+https://github.com/nix-community/NixOS-WSL?ref=release-26.05&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "git+https://github.com/nix-community/home-manager?ref=release-26.05&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "git+https://github.com/oxalica/rust-overlay?ref=master&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      nixos-wsl,
      home-manager,
      rust-overlay,
      ...
    }:
    let
      mkHost =
        {
          system,
          username,
          homeDirectory ? "/home/${username}",
          systemStateVersion ? "25.11",
          hostModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit systemStateVersion;
          };
          modules = [
            ./modules/nixos/base.nix
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [ rust-overlay.overlays.default ];

              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "bak";
                extraSpecialArgs = {
                  inherit username homeDirectory;
                  pkgs-unstable = import nixpkgs-unstable {
                    inherit system;
                    config.allowUnfree = true;
                  };
                };
                users.${username} = import ./modules/home;
              };
            }
          ]
          ++ hostModules;
        };

      wslHost = mkHost {
        system = "x86_64-linux";
        username = "nixos";
        hostModules = [
          nixos-wsl.nixosModules.default
          ./hosts/wsl.nix
        ];
      };
    in
    {
      nixosConfigurations = {
        nixos = wslHost;
        wsl = wslHost;

        orbstack = mkHost {
          system = "aarch64-linux";
          username = "sushao";
          homeDirectory = "/home/sushao";
          systemStateVersion = "26.05";
          hostModules = [ ./hosts/orbstack.nix ];
        };

        orbstack-aarch64 = mkHost {
          system = "aarch64-linux";
          username = "nixos";
          hostModules = [ ./hosts/vm.nix ];
        };

        orbstack-x86_64 = mkHost {
          system = "x86_64-linux";
          username = "nixos";
          hostModules = [ ./hosts/vm.nix ];
        };
      };
    };
}
