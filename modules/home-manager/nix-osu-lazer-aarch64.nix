{
  config,
  lib,
  ...
}:

let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.programs.nix-osu-lazer-aarch64;
in
{
  options.programs.nix-osu-lazer-aarch64 = {
    enable = mkEnableOption "osu!lazer on aarch64 (native build via nix-osu-lazer-aarch64)";

    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      defaultText = literalExpression "nix-osu-lazer-aarch64.packages.\${pkgs.stdenv.hostPlatform.system}.nix-osu-lazer-aarch64";
      example = literalExpression "nix-osu-lazer-aarch64.packages.\${pkgs.stdenv.hostPlatform.system}.nix-osu-lazer-aarch64";
      description = ''
        nix-osu-lazer-aarch64 package to install. When you import
        `nix-osu-lazer-aarch64.homeModules.nix-osu-lazer-aarch64`
        from the flake, this defaults to that flake's package — you
        usually do not need to set it.
      '';
    };

    nativeWayland = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Set `SDL_VIDEODRIVER=wayland` on the launcher. Disable if you
        need the X11/XWayland backend.
      '';
    };
  };

  config = mkIf cfg.enable (
    let
      finalPackage =
        if cfg.package == null then
          null
        else
          cfg.package.override {
            nativeWayland = cfg.nativeWayland;
          };
    in
    {
      home.packages = lib.optional (finalPackage != null) finalPackage;

      assertions = [
        {
          assertion = cfg.package != null;
          message = ''
            programs.nix-osu-lazer-aarch64.package is unset. Import
            nix-osu-lazer-aarch64.homeModules.nix-osu-lazer-aarch64 from the flake
            (which sets a default), or set package explicitly to
            nix-osu-lazer-aarch64.packages.''${pkgs.stdenv.hostPlatform.system}.nix-osu-lazer-aarch64.
          '';
        }
      ];
    }
  );
}
