{
  pkgs ? import <nixpkgs> {},
  system ? pkgs.stdenv.hostPlatform.system,
}: let
  mkMarble = pkgs: name: system: entry: let
    variant = (builtins.fromJSON (builtins.readFile ./sources.json)).${entry}.${system};

    desktopFile = "marble-browser.desktop";
  in
    pkgs.callPackage ./package.nix {
      inherit name desktopFile variant;
    };
in rec {
  marble-unwrapped = mkMarble pkgs "marble" system "marble";
  marble = pkgs.wrapFirefox marble-unwrapped {};

  default = marble;
}
