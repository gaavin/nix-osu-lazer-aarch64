{
  lib,
  stdenvNoCC,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  makeDesktopItem,
  copyDesktopItems,
  makeWrapper,
  ffmpeg,
  alsa-lib,
  SDL2,
  sdl3,
  lttng-ust,
  numactl,
  libglvnd,
  libxi,
  udev,
  vulkan-loader,
  icu,
  nativeWayland ? true,
}:

buildDotnetModule rec {
  pname = "nix-osu-lazer-bin-aarch64";
  version = "2026.804.2";

  src = fetchFromGitHub {
    owner = "ppy";
    repo = "osu";
    tag = "${version}-lazer";
    hash = "sha256-1cUR3Z3TCNfnkyNkxlb+rmsFkYZ0WMBBRQwvRqoXUfw=";
  };

  projectFile = "osu.Desktop/osu.Desktop.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  runtimeDeps = [
    ffmpeg
    alsa-lib
    SDL2
    sdl3
    lttng-ust
    numactl
    icu

    # Failed to create SDL window. SDL Error: Could not initialize OpenGL / GLES library
    libglvnd

    # needed for the window to actually appear
    libxi

    # SDL bundled natives look up udev at runtime
    udev

    # vulkan renderer; can fall back to opengl if omitted
    vulkan-loader
  ];

  executables = [ "osu!" ];

  fixupPhase = ''
    runHook preFixup

    wrapProgram $out/bin/osu! \
      ${lib.optionalString nativeWayland "--set SDL_VIDEODRIVER wayland"} \
      --set OSU_EXTERNAL_UPDATE_PROVIDER 1

    for i in 16 32 48 64 96 128 256 512 1024; do
      install -D ./assets/lazer.png $out/share/icons/hicolor/''${i}x$i/apps/osu.png
    done

    ln -sft $out/lib/${pname} ${SDL2}/lib/libSDL2${stdenvNoCC.hostPlatform.extensions.sharedLibrary}
    ln -sft $out/lib/${pname} ${sdl3}/lib/libSDL3${stdenvNoCC.hostPlatform.extensions.sharedLibrary}

    runHook postFixup
  '';

  desktopItems = [
    (makeDesktopItem {
      desktopName = "osu!";
      name = "osu";
      exec = "osu!";
      icon = "osu";
      comment = "Rhythm is just a *click* away";
      type = "Application";
      categories = [ "Game" ];
    })
  ];

  meta = {
    description = "Rhythm is just a *click* away (native aarch64-linux osu!lazer)";
    homepage = "https://github.com/gaavin/nix-osu-lazer-bin-aarch64";
    license = with lib.licenses; [
      mit
      cc-by-nc-40
      unfreeRedistributable # osu-framework contains libbass.so in repository
    ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
    platforms = [ "aarch64-linux" ];
    mainProgram = "osu!";
  };
}
