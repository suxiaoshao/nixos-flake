{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-25.11 branch here
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?ref=nixos-25.11";
    nixos-wsl = {
      url = "git+https://github.com/nix-community/nixos-wsl?ref=release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "git+https://github.com/nix-community/home-manager?ref=release-25.11";
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
  };

  outputs =
    {
      nixpkgs,
      nixos-wsl,
      home-manager,
      rust-overlay,
      ...
    }:
    let
      mkSystem =
        {
          system,
          modules,
          username,
          homeDirectory ? "/home/${username}",
          systemStateVersion ? "25.11",
        }:
        nixpkgs.lib.nixosSystem {
          inherit system modules;
          specialArgs = {
            inherit rust-overlay;
            inherit systemStateVersion;
          };
        };

      mkHomeManagerModule =
        username: homeDirectory: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "bak";
        home-manager.extraSpecialArgs = {
          inherit username homeDirectory;
        };
        home-manager.users.${username} = import ./home.nix;
      };

      mkCommonModules =
        username: homeDirectory: [
        ./common.nix
        ./configuration.nix
        home-manager.nixosModules.home-manager
        (mkHomeManagerModule username homeDirectory)
      ];
    in
    {
      nixosConfigurations = {
        nixos = mkSystem {
          system = "x86_64-linux";
          username = "nixos";
          modules =
            [
              nixos-wsl.nixosModules.default
              ./wsl.nix
            ]
            ++ mkCommonModules "nixos" "/home/nixos";
        };

        wsl = mkSystem {
          system = "x86_64-linux";
          username = "nixos";
          modules =
            [
              nixos-wsl.nixosModules.default
              ./wsl.nix
            ]
            ++ mkCommonModules "nixos" "/home/nixos";
        };

        orbstack = mkSystem {
          system = "aarch64-linux";
          username = "sushao";
          homeDirectory = "/home/sushao";
          systemStateVersion = "26.05";
          modules =
            [
              ./orbstack.nix
            ]
            ++ mkCommonModules "sushao" "/home/sushao";
        };

        orbstack-aarch64 = mkSystem {
          system = "aarch64-linux";
          username = "nixos";
          modules = [ ./vm.nix ] ++ mkCommonModules "nixos" "/home/nixos";
        };

        orbstack-x86_64 = mkSystem {
          system = "x86_64-linux";
          username = "nixos";
          modules = [ ./vm.nix ] ++ mkCommonModules "nixos" "/home/nixos";
        };
      };
    };
}
