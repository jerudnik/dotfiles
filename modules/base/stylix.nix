{
  config,
  lib,
  pkgs,
  ...
}:
let
  modusSchemes = import ../../themes/modus.nix { inherit lib; };
  nordSchemes = import ../../themes/nord.nix { inherit lib; };
  cfg = config.themes;
  variantScheme =
    schemeName:
    if schemeName == "modus-operandi" then
      modusSchemes.operandi
    else if schemeName == "modus-vivendi" then
      modusSchemes.vivendi
    else if schemeName == "nord" then
      nordSchemes.nord
    else if schemeName == "nord-light" then
      nordSchemes.nord-light
    else
      modusSchemes.vivendi;
  fontPackages = [
    pkgs.nerd-fonts.im-writing
    pkgs.ibm-plex
    pkgs.noto-fonts-color-emoji
  ];
in
{
  options.themes.variant = lib.mkOption {
    type = lib.types.enum [
      "modus-operandi"
      "modus-vivendi"
      "nord"
      "nord-light"
    ];
    default = "modus-vivendi";
    description = ''
      Select the global theme variant.
      "modus-operandi" is light, "modus-vivendi" is dark.
      "nord" is dark, "nord-light" is light.
    '';
  };

  config = {
    stylix = {
      enable = lib.mkDefault true;
      base16Scheme = lib.mkDefault (variantScheme cfg.variant);
      fonts = {
        serif = {
          package = pkgs.ibm-plex;
          name = "IBM Plex Serif";
        };
        sansSerif = {
          package = pkgs.nerd-fonts.im-writing;
          name = "iMWritingQuattro Nerd Font";
        };
        monospace = {
          package = pkgs.nerd-fonts.im-writing;
          name = "iMWritingMono Nerd Font";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          applications = 12;
          terminal = 15; # 15 * 4/3 = 20 on macOS (avoids float warning)
        };
      };
      opacity.terminal = lib.mkDefault 0.95;
      homeManagerIntegration.followSystem = true;
    };

    fonts = {
      packages = lib.mkDefault fontPackages;
    };
  };
}
