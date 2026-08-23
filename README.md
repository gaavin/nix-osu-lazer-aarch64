<div align="center">

# nix-osu-lazer-bin-aarch64

**osu!lazer on aarch64 NixOS** — native .NET build. Not FEX, Box64, or muvm.

[![NixOS](https://img.shields.io/badge/NixOS-unstable-informational?logo=NixOS)](https://nixos.org)
[![Flake](https://img.shields.io/badge/Flake-enabled-success)](https://nixos.wiki/wiki/Flakes)

<p>
  <img src="assets/osu-logo.svg" alt="osu!" width="96">
</p>

</div>

> [!WARNING]
> **This project was primarily written by an LLM (AI). Review the code yourself before running it. Use at your own risk.**

nixpkgs `osu-lazer-bin` is `x86_64-linux` and `aarch64-darwin` only. The official Linux [AppImage](https://github.com/ppy/osu/releases) is x86_64; there is no ARM64 Linux binary to wrap.

This flake builds [ppy/osu](https://github.com/ppy/osu) natively for `aarch64-linux` (same approach as nixpkgs `osu-lazer`) using the framework's `linux-arm64` native libs (BASS, FFmpeg, veldrid-spirv). It is **not** an emulator wrapper.

Use nixpkgs `osu-lazer-bin` on `x86_64-linux`. This flake is `aarch64-linux` only.

> [!NOTE]
> This is an unofficial source build. Score submission and official multiplayer require peppy's signed release (`osu-lazer-bin` / the AppImage) and will not work here. Local play does.

## Quick Start

```bash
nix run github:gaavin/nix-osu-lazer-bin-aarch64
```

Requires `aarch64-linux`, flakes, and unfree packages (BASS).

## Install with Home Manager

### 1. Add to flake inputs

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-osu-lazer-bin-aarch64.url = "github:gaavin/nix-osu-lazer-bin-aarch64";
    nix-osu-lazer-bin-aarch64.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nix-osu-lazer-bin-aarch64, ... }:
    {
      nixosConfigurations.YOUR_CONFIGURATION = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.YOUR_USERNAME = import ./home.nix;
              sharedModules = [
                nix-osu-lazer-bin-aarch64.homeModules.nix-osu-lazer-bin-aarch64
              ];
            };
          }
        ];
      };
    };
}
```

### 2. Enable in `home.nix`

```nix
{
  programs.nix-osu-lazer-bin-aarch64.enable = true;
}
```

### 3. Build & launch

```bash
nix flake update nix-osu-lazer-bin-aarch64
sudo nixos-rebuild switch --flake .#YOUR_CONFIGURATION
osu!
```

## Commands

| Command | Purpose |
|---------|---------|
| `osu!` | Launch osu!lazer |

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Window never appears | Wayland is the default (`SDL_VIDEODRIVER=wayland`). Set `programs.nix-osu-lazer-bin-aarch64.nativeWayland = false;` for X11/XWayland. |
| No audio | PipeWire/ALSA must be running. This package sets the same audio runtime deps as nixpkgs `osu-lazer`. |
| Self-updater / "update available" | The wrapper sets `OSU_EXTERNAL_UPDATE_PROVIDER=1`. Bump `version` + hashes in `pkgs/nix-osu-lazer-bin-aarch64/` instead. |
| Score submit / multiplayer rejected | Unofficial build. Use nixpkgs `osu-lazer-bin` on x86_64. |
| Missing `libveldrid-spirv` / `libbass` | Those ship in `ppy.Veldrid.SPIRV` and `ppy.osu.Framework.NativeLibs` for `linux-arm64`. Rebuild from this flake; do not copy x86_64 natives. |

## Advanced

Package only:

```nix
home.packages = [
  inputs.nix-osu-lazer-bin-aarch64.packages.${pkgs.stdenv.hostPlatform.system}.nix-osu-lazer-bin-aarch64
];
```

```bash
nix build github:gaavin/nix-osu-lazer-bin-aarch64
```

## Credits

- [ppy/osu](https://github.com/ppy/osu) — osu!lazer
- [ppy/osu-framework](https://github.com/ppy/osu-framework) — `linux-arm64` native libs
- [NixOS/nixpkgs `osu-lazer`](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/os/osu-lazer/package.nix) — packaging approach this flake follows
