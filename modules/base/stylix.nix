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
  cfg = config.themes;

  schemeVariants = {
    modus = {
      light = modusSchemes.operandi;
      dark = modusSchemes.vivendi;
    };
    gruvbox = {
      light = gruvboxSchemes.light-medium;
      dark = gruvboxSchemes.dark-hard;
    };
    nord = {
      light = nordSchemes.nord-light;
      dark = nordSchemes.nord;
    };
    tomorrow = {
      light = tomorrowSchemes.light;
      dark = tomorrowSchemes.dark;
    };
    "atelier-estuary" = {
      light = atelierSchemes.estuary-light;
      dark = atelierSchemes.estuary;
    };
    "atelier-mix" = {
      light = atelierSchemes.dune-light;
      dark = atelierSchemes.cave;
    };
  };

  selectedScheme =
    let
      variants = lib.attrByPath [ cfg.scheme ] { } schemeVariants;
      defaultVariant = if variants == { } then schemeVariants.modus else variants;
    in
    lib.attrByPath [ cfg.mode ] modusSchemes.vivendi defaultVariant;
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
  options.themes.scheme = lib.mkOption {
    type = lib.types.enum [
      "modus"
      "gruvbox"
      "nord"
      "tomorrow"
      "atelier-estuary"
      "atelier-mix"
    ];
    default = "modus";
    description = "Theme family to use (light/dark provided by mode).";
  };

  options.themes.mode = lib.mkOption {
    type = lib.types.enum [
      "light"
      "dark"
    ];
    default = "dark";
    description = "Theme variant to use (light or dark).";
  };

  config = {
    stylix = {
      enable = lib.mkDefault true;
      base16Scheme = lib.mkDefault selectedScheme;
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
