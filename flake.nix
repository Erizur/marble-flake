{
  description = "Marble Browser";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      version = "G1.0.1";
      downloadUrl = {
		url = "https://github.com/NetworkNeighborhood/Marble/releases/download/${version}/marble-${version}.en-US.linux-x86_64.tar.bz2";
		sha256 = "afe698161689d805adcf13e202d41b1a663f2f4e059d49f28f98788074467b45";
      };

      pkgs = import nixpkgs {
        inherit system;
      };

      runtimeLibs = with pkgs; [
        libGL libGLU libevent libffi libjpeg libpng libstartup_notification libvpx libwebp
        stdenv.cc.cc fontconfig libxkbcommon zlib freetype
        gtk3 libxml2 dbus xcb-util-cursor alsa-lib libpulseaudio pango atk cairo gdk-pixbuf glib
	udev libva mesa libnotify cups pciutils
	ffmpeg libglvnd pipewire
      ] ++ (with pkgs.xorg; [
        libxcb libX11 libXcursor libXrandr libXi libXext libXcomposite libXdamage
	libXfixes libXScrnSaver
      ]);

      mkMarble = { }:
        let
	  downloadData = downloadUrl."${variant}";
	in
             pkgs.stdenv.mkDerivation {
    inherit version;
		pname = "marble-browser";

		src = builtins.fetchTarball {
		  url = downloadData.url;
		  sha256 = downloadData.sha256;
		};
		
		desktopSrc = ./.;

		phases = [ "installPhase" "fixupPhase" ];

		nativeBuildInputs = [ pkgs.makeWrapper pkgs.copyDesktopItems pkgs.wrapGAppsHook ] ;

		installPhase = ''
		  mkdir -p $out/bin && cp -r $src/* $out/bin
		  install -D $desktopSrc/marble-browser.desktop $out/share/applications/marble-browser.desktop
		  install -D $src/browser/chrome/icons/default/default128.png $out/share/icons/hicolor/128x128/apps/marble-browser.png
		  install -D $src/browser/chrome/icons/default/default64.png $out/share/icons/hicolor/64x64/apps/marble-browser.png
		  install -D $src/browser/chrome/icons/default/default48.png $out/share/icons/hicolor/48x48/apps/marble-browser.png
		  install -D $src/browser/chrome/icons/default/default32.png $out/share/icons/hicolor/32x32/apps/marble-browser.png
		  install -D $src/browser/chrome/icons/default/default16.png $out/share/icons/hicolor/16x16/apps/marble-browser.png
		'';

		fixupPhase = ''
		  chmod 755 $out/bin/*
		  patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/marble
		  wrapProgram $out/bin/marble --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath runtimeLibs}" \
                    --set MOZ_LEGACY_PROFILES 1 --set MOZ_ALLOW_DOWNGRADE 1 --set MOZ_APP_LAUNCHER marble --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH"
		  patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/marble-bin
		  wrapProgram $out/bin/marble-bin --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath runtimeLibs}" \
                    --set MOZ_LEGACY_PROFILES 1 --set MOZ_ALLOW_DOWNGRADE 1 --set MOZ_APP_LAUNCHER marble --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH"
		  patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/glxtest
		  wrapProgram $out/bin/glxtest --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath runtimeLibs}"
		  patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/updater
		  wrapProgram $out/bin/updater --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath runtimeLibs}"
		  patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/vaapitest
		  wrapProgram $out/bin/vaapitest --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath runtimeLibs}"
		'';

    meta.mainProgram = "marble";
	      };
    in
    {
      packages."${system}" = {
		default = self.packages."${system}".specific;
      };
    };
}
