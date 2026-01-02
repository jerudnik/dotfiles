{
  config,
  lib,
  pkgs,
  ...
}:
let
  themeScript = pkgs.writeShellApplication {
    name = "theme-switch";
    text = builtins.readFile ../../scripts/theme-switch.sh;
  };
in
{
  services.darkman = {
    enable = true;
    settings = {
      useGeoclue = true;
    };
    lightModeScripts = ''
      ${themeScript}/bin/theme-switch light
    '';
    darkModeScripts = ''
      ${themeScript}/bin/theme-switch dark
    '';
  };
}
