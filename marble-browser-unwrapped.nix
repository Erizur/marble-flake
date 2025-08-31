{
  stdenv,
  config,
  wrapGAppsHook3,
  autoPatchelfHook,
  patchelfUnstable,
  adwaita-icon-theme,
  dbus-glib,
  libXtst,
  curl,
  gtk3,
  alsa-lib,
  libva,
  pciutils,
  pipewire,
  writeText,
  fetchurl,
  version,
  url,
  hash,
  ...
}:
let
  policies = {
    DisableAppUpdate = true;
  } // config.marble-browser.policies or { };

  policiesJson = writeText "firefox-policies.json" (builtins.toJSON { inherit policies; });
in
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "marble-browser-unwrapped";
  applicationName = "Marble Browser";

  src = fetchurl {
    inherit url hash;
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    autoPatchelfHook
    patchelfUnstable
  ];

  buildInputs = [
    gtk3
    alsa-lib
    adwaita-icon-theme
    dbus-glib
    libXtst
  ];

  runtimeDependencies = [
    curl
    libva.out
    pciutils
  ];

  appendRunpaths = [
    "${pipewire}/lib"
  ];

  installPhase = ''
    mkdir -p "$prefix/lib/marble-${version}"
    cp -r * "$prefix/lib/marble-${version}"

    mkdir -p $out/bin
    ln -s "$prefix/lib/marble-${version}/marble" $out/bin/marble-browser

    mkdir -p "$out/lib/marble-${version}/distribution"
    ln -s ${policiesJson} "$out/lib/marble-${version}/distribution/policies.json"
  '';

  patchelfFlags = [ "--no-clobber-old-sections" ];

  meta = {
    mainProgram = "marble-browser";
    description = ''
      Firefox fork that aims to restore the Photon user interface, along with native controls that were removed in newer versions of Firefox.
    '';
  };

  passthru = {
    inherit gtk3;

    libName = "marble-${version}";
    binaryName = finalAttrs.meta.mainProgram;
    gssSupport = true;
    ffmpegSupport = true;
  };
})
