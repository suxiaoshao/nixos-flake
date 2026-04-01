# nixos-flake

This repository keeps one shared NixOS base and a small set of host-specific entrypoints.

## Layout

- `flake.nix`: inputs and host definitions
- `hosts/`: host-specific NixOS modules
- `modules/nixos/`: shared system modules
- `modules/home/`: shared Home Manager modules

## Hosts

- `.#wsl`: WSL host, also exported as `.#nixos` for compatibility
- `.#orbstack`: current OrbStack guest on Apple Silicon
- `.#orbstack-aarch64`: generic ARM VM target
- `.#orbstack-x86_64`: generic x86_64 VM target

## Notes

- The system stays on `nixos-25.11`.
- Selected user tools such as `codex` come from `nixpkgs-unstable`.
- Secrets and local auth state are intentionally excluded from this repository.
