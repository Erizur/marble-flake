{
  pkgs,
  system ? pkgs.system,
  ...
}:
let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);
in
rec {
  marble-browser-unwrapped = pkgs.callPackage ./marble-browser-unwrapped.nix {
    inherit (sources.${system}) hash url;
    inherit (sources) version;
  };
  marble-browser = pkgs.callPackage ./marble-browser.nix { inherit marble-browser-unwrapped; };
  default = marble-browser;
}
