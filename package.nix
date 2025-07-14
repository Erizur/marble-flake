{
  name,
  variant,
  desktopFile,
  policies ? {},
  lib,
  stdenv,
  config,
  wrapGAppsHook3,
  autoPatchelfHook,
  alsa-lib,
  curl,
  dbus-glib,
  gtk3,
  libXtst,
  libva,
  libGL,
  pciutils,
  pipewire,
  adwaita-icon-theme,
  writeText,
  patchelfUnstable, # have to use patchelfUnstable to support --no-clobber-old-sections
  applicationName ? "Marble",
}: let
  binaryName = "marble";

  libName = "marble-bin";

  mozillaPlatforms = {
    x86_64-linux = "linux-x86_64";
  };

  firefoxPolicies =
    (config.firefox.policies or {})
    // policies;

  policiesJson = writeText "firefox-policies.json" (builtins.toJSON {policies = firefoxPolicies;});

  pname = "marble-bin-unwrapped";
in
  stdenv.mkDerivation {
    inherit pname;
    inherit (variant) version;

    src = builtins.fetchTarball {inherit (variant) url sha256;};
    desktopSrc = ./assets/desktop;

    nativeBuildInputs = [
      wrapGAppsHook3
      autoPatchelfHook
      patchelfUnstable
    ];
    buildInputs = [
      gtk3
      adwaita-icon-theme
      alsa-lib
      dbus-glib
      libXtst
    ];
    runtimeDependencies = [
      curl
      libva.out
      pciutils
      libGL
    ];
    appendRunpaths = [
      "${libGL}/lib"
      "${pipewire}/lib"
    ];
    # Firefox uses "relrhack" to manually process relocations from a fixed offset
    patchelfFlags = ["--no-clobber-old-sections"];

    preFixup = ''
      gappsWrapperArgs+=(
        --add-flags "--name=''${MOZ_APP_LAUNCHER:-${binaryName}}"
      )
    '';

    installPhase = ''
      mkdir -p "$out/bin"
      cp -r "$src"/* "$out/bin"
      ln -s "$out/bin/${binaryName}" "$out/bin/marble-browser"

      install -D $desktopSrc/${desktopFile} $out/share/applications/${desktopFile}

      install -D $src/browser/chrome/icons/default/default16.png $out/share/icons/hicolor/16x16/apps/marble-browser.png
      install -D $src/browser/chrome/icons/default/default32.png $out/share/icons/hicolor/32x32/apps/marble-browser.png
      install -D $src/browser/chrome/icons/default/default48.png $out/share/icons/hicolor/48x48/apps/marble-browser.png
      install -D $src/browser/chrome/icons/default/default64.png $out/share/icons/hicolor/64x64/apps/marble-browser.png
      install -D $src/browser/chrome/icons/default/default128.png $out/share/icons/hicolor/128x128/apps/marble-browser.png
    '';

    passthru = {
      inherit applicationName binaryName libName;
      ffmpegSupport = true;
      gssSupport = true;
      gtk3 = gtk3;
    };

    meta = {
      inherit desktopFile;
      description = "Firefox fork that aims to restore the Photon user interface, along with native controls that were removed in newer versions of Firefox.";
      homepage = "https://github.com/NetworkNeighborhood/Marble";
      downloadPage = "https://github.com/NetworkNeighborhood/Marble/releases";
      changelog = "https://github.com/NetworkNeighborhood/Marble/releases";
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      platforms = builtins.attrNames mozillaPlatforms;
      hydraPlatforms = [];
      mainProgram = binaryName;
    };
  }
