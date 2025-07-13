{
  home-manager,
  self,
  name,
}: {
  config,
  pkgs,
  lib,
  ...
}: let
  applicationName = "Marble Browser";
  modulePath = [
    "programs"
    "marble-browser"
  ];

  mkFirefoxModule = import "${home-manager.outPath}/modules/programs/firefox/mkFirefoxModule.nix";
in {
  imports = [
    (mkFirefoxModule {
      inherit modulePath;
      name = applicationName;
      wrappedPackageName = "marble-browser-unwrapped";
      unwrappedPackageName = "marble-browser";
      visible = true;
      platforms = {
        linux = {
          vendorPath = ".network neighborhood";
          configPath = ".network neighborhood";
        };
        darwin = {
          configPath = "Library/Application Support/Network Neighborhood";
        };
      };
    })
  ];

  config = lib.mkIf config.programs.marble-browser.enable {
    programs.marble-browser = {
      package = pkgs.wrapFirefox (self.packages.${pkgs.stdenv.system}."marble-browser-unwrapped".override {
        policies = config.programs.marble-browser.policies;
      }) {};
      policies = lib.mkDefault {
        DisableAppUpdate = true;
        DisableTelemetry = true;
      };
    };
  };
}
