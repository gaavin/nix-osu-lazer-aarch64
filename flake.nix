{
  description = "Declarative osu!lazer on aarch64 Nix (native source build, not FEX)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      packages = rec {
        nix-osu-lazer-bin-aarch64 = pkgs.callPackage ./pkgs/nix-osu-lazer-bin-aarch64 { };
        default = nix-osu-lazer-bin-aarch64;
      };
    in
    {
      packages.${system} = packages;

      apps.${system}.default = {
        type = "app";
        program = "${packages.nix-osu-lazer-bin-aarch64}/bin/osu!";
      };

      homeModules.nix-osu-lazer-bin-aarch64 =
        { lib, pkgs, ... }:
        {
          imports = [ ./modules/home-manager/nix-osu-lazer-bin-aarch64.nix ];
          programs.nix-osu-lazer-bin-aarch64.package = lib.mkDefault (
            self.packages.${pkgs.stdenv.hostPlatform.system}.nix-osu-lazer-bin-aarch64
          );
        };
      homeModules.default = self.homeModules.nix-osu-lazer-bin-aarch64;

      overlays.default = final: _prev: {
        inherit (self.packages.${final.stdenv.hostPlatform.system} or packages)
          nix-osu-lazer-bin-aarch64
          ;
      };
    };
}
