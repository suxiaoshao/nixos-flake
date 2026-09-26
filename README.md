# nixos-flake

This repository keeps one shared NixOS base and a small set of host-specific entrypoints.

## Layout

- `flake.nix`: pinned inputs, the shared package overlay, and host assembly
- `hosts/`: platform integration, users, networking, and host-specific settings
- `modules/nixos/base.nix`: shared Nix settings, system maintenance tools, and `nix-ld`
- `modules/home/default.nix`: user identity, state version, and Home Manager imports
- `modules/home/development.nix`: language toolchains, build dependencies, Nix editor tools, and development environment variables
- `modules/home/git.nix`: personal Git configuration, using the system Git package
- `modules/home/shell.nix`: Bash and Starship configuration
- `modules/home/codex.nix`: Codex package and configuration

## System and user tools

The system provides Git and wget for maintenance, plus the runtime loader and
libraries managed by `programs.nix-ld`. Personal development tools belong to Home
Manager: Node.js, pnpm, Rust, Clang, GCC, mold, pkg-config, OpenSSL, PostgreSQL
tools, nixd, nil, and nixfmt. PostgreSQL is installed as a tool package; no
database service is enabled.

Clang provides the default `cc` and `c++` commands; GCC remains available as
`gcc` and `g++`.

`PKG_CONFIG_PATH` is set for the user environment only. Development tools are
available through the user's profile rather than the system-wide PATH; run
development commands as your regular user. The package store is still shared,
and `nixos-rebuild` deploys the system and Home Manager configuration together.

Rust's overlay is shared at the flake level, while installation of the Rust
toolchain is selected by the user's development module.

## Hosts

- `.#wsl`: WSL host, also exported as `.#nixos` for compatibility
- `.#orbstack`: current OrbStack guest on Apple Silicon
- `.#orbstack-aarch64`: incomplete generic ARM VM configuration
- `.#orbstack-x86_64`: incomplete generic x86_64 VM configuration

The generic VM entries require a root filesystem and bootloader configuration
before they can build. Import a generated hardware module from the relevant
host configuration when using these entries.

## Building the OrbStack host

The working repository is `/Users/sushao/Documents/code/nixos-flake` on macOS.
OrbStack exposes the same directory inside the `nixos` guest, where Home Manager
also provides `~/nixos-config` as a shortcut. Edit this shared repository to keep
the host and guest on the same files.

The `orbstack` host imports `/etc/nixos/incus.nix` and `/etc/nixos/orbstack.nix`,
which OrbStack generates inside the guest. These files are outside the flake's
declared inputs, so default pure evaluation rejects access to them. Pass
`--impure` to allow Nix to read these guest-local modules during evaluation.

From the repository root inside the OrbStack guest, build without activating the
result:

```bash
nix build --impure --no-link \
  .#nixosConfigurations.orbstack.config.system.build.toplevel
```

Evaluation then depends on the current contents of those guest files; the
repository and `flake.lock` alone do not fully determine the configuration.
`--impure` does not disable the build sandbox or grant root privileges.

## Updating the OrbStack guest

Run from this repository's root on macOS:

```bash
orb -m nixos -u root nix flake update
orb -m nixos -u root nixos-rebuild build --flake .#orbstack --impure
```

Review the lock file changes and build result before applying. For a routine
update that supports switching the running system:

```bash
orb -m nixos -u root nixos-rebuild switch --flake .#orbstack --impure
```

For the 25.11 to 26.05 upgrade, the default D-Bus implementation changes to
`dbus-broker`, which requires a restart. Prepare the next boot and then restart
the guest:

```bash
orb -m nixos -u root nixos-rebuild boot --flake .#orbstack --impure
orbctl restart nixos
```

To return to the previous system generation:

```bash
orb -m nixos -u root nixos-rebuild boot --rollback
orbctl restart nixos
```

## Notes

- The system uses `nixos-26.05`, with matching Home Manager and NixOS-WSL release branches.
- Selected user tools such as `codex` come from `nixpkgs-unstable`.
- Inputs use shallow HTTPS Git fetches, with exact revisions recorded in `flake.lock`.
- Keep existing `system.stateVersion` and `home.stateVersion` values when updating packages.
- Secrets and local auth state are intentionally excluded from this repository.
