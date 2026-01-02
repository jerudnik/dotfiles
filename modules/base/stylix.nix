{
  config,
  lib,
  pkgs,
  ...
}:
let
  modusSchemes = import ../../themes/modus.nix { inherit lib; };
  nordSchemes = import ../../themes/nord.nix { inherit lib; };
  atelierSchemes = import ../../themes/atelier.nix { inherit lib; };
  gruvboxSchemes = import ../../themes/gruvbox.nix { inherit lib; };
  tomorrowSchemes = import ../../themes/tomorrow.nix { inherit lib; };
  nanoSchemes = import ../../themes/nano.nix { inherit lib; };
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
    else if schemeName == "atelier-estuary" then
      atelierSchemes.estuary
    else if schemeName == "atelier-estuary-light" then
      atelierSchemes.estuary-light
    else if schemeName == "atelier-dune" then
      atelierSchemes.dune
    else if schemeName == "atelier-dune-light" then
      atelierSchemes.dune-light
    else if schemeName == "atelier-cave" then
      atelierSchemes.cave
    else if schemeName == "atelier-cave-light" then
      atelierSchemes.cave-light
    else if schemeName == "atelier-mix" then
      atelierSchemes.mix
    else if schemeName == "gruvbox-material-dark-hard" then
      gruvboxSchemes.dark-hard
    else if schemeName == "tomorrow" then
      tomorrowSchemes.light
    else if schemeName == "tomorrow-night" then
      tomorrowSchemes.dark
    else if schemeName == "nano" then
      nanoSchemes.nano
    else
      modusSchemes.vivendi;
  fontPackages = [
    pkgs.ia-writer-mono
    pkgs.ia-writer-duospace
    pkgs.ia-writer-quattro
    pkgs.ibm-plex
    pkgs.noto-fonts-color-emoji
    pkgs.phosphor-icons
  ];
in
{
  options.themes.variant = lib.mkOption {
    type = lib.types.enum [
      "modus-operandi"
      "modus-vivendi"
      "nord"
      "nord-light"
      "atelier-estuary"
      "atelier-estuary-light"
      "atelier-dune"
      "atelier-dune-light"
      "atelier-cave"
      "atelier-cave-light"
      "atelier-mix"
      "gruvbox-material-dark-hard"
      "tomorrow"
      "tomorrow-night"
      "nano"
    ];
    default = "modus-vivendi";
    description = ''
      Select the global theme variant.
      Light variants: modus-operandi, nord-light, atelier-estuary-light,
        atelier-dune-light, atelier-cave-light, tomorrow.
      Dark variants: modus-vivendi, nord, atelier-estuary, atelier-dune,
        atelier-cave, atelier-mix, gruvbox-material-dark-hard,
        tomorrow-night, nano.
      "atelier-mix" uses dune-light for light mode and cave for dark mode.
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
          package = pkgs.ia-writer-quattro;
          name = "iA Writer Quattro";
        };
        monospace = {
          package = pkgs.ia-writer-mono;
          name = "iA Writer Mono";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          applications = 12;
          terminal = 13;
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
