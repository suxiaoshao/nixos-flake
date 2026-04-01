{
  description = "NixOS flake for WSL and OrbStack hosts";

  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?ref=nixos-25.11";
    nixpkgs-unstable.url = "git+https://github.com/NixOS/nixpkgs?ref=nixos-unstable";

    nixos-wsl = {
      url = "git+https://github.com/nix-community/nixos-wsl?ref=release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "git+https://github.com/nix-community/home-manager?ref=release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
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
      lib = nixpkgs.lib;

      mkPkgsUnstable =
        system:
        import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };

      mkHomeManagerModule =
        {
          system,
          username,
          homeDirectory,
        }:
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.extraSpecialArgs = {
            inherit username homeDirectory;
            pkgs-unstable = mkPkgsUnstable system;
          };
          home-manager.users.${username} = import ./modules/home;
        };

      mkModules =
        {
          system,
          username,
          homeDirectory ? "/home/${username}",
          hostModules ? [ ],
        }:
        [
          ./modules/nixos/base.nix
          ./modules/nixos/hardware.nix
          home-manager.nixosModules.home-manager
          (mkHomeManagerModule {
            inherit system username homeDirectory;
          })
        ]
        ++ hostModules;

      mkHost =
        {
          system,
          username,
          homeDirectory ? "/home/${username}",
          systemStateVersion ? "25.11",
          hostModules ? [ ],
        }:
        lib.nixosSystem {
          inherit system;
          modules = mkModules {
            inherit system username homeDirectory hostModules;
          };
          specialArgs = {
            inherit rust-overlay systemStateVersion;
            pkgs-unstable = mkPkgsUnstable system;
          };
        };
    in
    {
      nixosConfigurations =
        let
          wslHost = mkHost {
            system = "x86_64-linux";
            username = "nixos";
            hostModules = [
              nixos-wsl.nixosModules.default
              ./hosts/wsl.nix
            ];
          };
        in
        rec {
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
