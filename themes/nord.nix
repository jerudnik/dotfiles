# Nord color schemes for Stylix
# Based on https://www.nordtheme.com/
{ lib }:
let
  # Helper to strip # from hex colors (Stylix expects bare hex)
  strip = color: lib.removePrefix "#" color;

  # Base16 scheme constructor
  mkScheme =
    {
      slug,
      scheme,
      author,
      palette,
    }:
    {
      inherit slug scheme author;
      base00 = strip palette.base00;
      base01 = strip palette.base01;
      base02 = strip palette.base02;
      base03 = strip palette.base03;
      base04 = strip palette.base04;
      base05 = strip palette.base05;
      base06 = strip palette.base06;
      base07 = strip palette.base07;
      base08 = strip palette.base08;
      base09 = strip palette.base09;
      base0A = strip palette.base0A;
      base0B = strip palette.base0B;
      base0C = strip palette.base0C;
      base0D = strip palette.base0D;
      base0E = strip palette.base0E;
      base0F = strip palette.base0F;
    };
in
{
  # Nord (Dark) - Polar Night background with Snow Storm text
  nord = mkScheme {
    slug = "nord";
    scheme = "Nord";
    author = "arcticicestudio";
    palette = {
      # Polar Night (backgrounds)
      base00 = "#2e3440"; # Background
      base01 = "#3b4252"; # Lighter background
      base02 = "#434c5e"; # Selection
      base03 = "#4c566a"; # Comments, invisibles

      # Snow Storm (foregrounds)
      base04 = "#d8dee9"; # Dark foreground
      base05 = "#e5e9f0"; # Default foreground
      base06 = "#eceff4"; # Light foreground
      base07 = "#8fbcbb"; # Light background (Nord7 - Frost)

      # Aurora (accents)
      base08 = "#bf616a"; # Red - errors, deletions
      base09 = "#d08770"; # Orange - warnings, changes
      base0A = "#ebcb8b"; # Yellow - modified, search
      base0B = "#a3be8c"; # Green - success, additions
      base0C = "#88c0d0"; # Cyan - info, links
      base0D = "#81a1c1"; # Blue - functions, methods
      base0E = "#b48ead"; # Purple - keywords, tags
      base0F = "#5e81ac"; # Dark blue - deprecated
    };
  };

  # Nord Light - Snow Storm background with Polar Night text
  nord-light = mkScheme {
    slug = "nord-light";
    scheme = "Nord Light";
    author = "arcticicestudio";
    palette = {
      # Snow Storm (backgrounds - inverted)
      base00 = "#eceff4"; # Background
      base01 = "#e5e9f0"; # Lighter background
      base02 = "#d8dee9"; # Selection
      base03 = "#c0c8d4"; # Comments, invisibles (lightened)

      # Polar Night (foregrounds - inverted)
      base04 = "#4c566a"; # Dark foreground
      base05 = "#434c5e"; # Default foreground
      base06 = "#3b4252"; # Light foreground
      base07 = "#2e3440"; # Darkest foreground

      # Aurora (same accents, work on light backgrounds)
      base08 = "#bf616a"; # Red
      base09 = "#d08770"; # Orange
      base0A = "#d5a94b"; # Yellow (darkened for contrast)
      base0B = "#a3be8c"; # Green
      base0C = "#88c0d0"; # Cyan
      base0D = "#5e81ac"; # Blue (darkened)
      base0E = "#b48ead"; # Purple
      base0F = "#8fbcbb"; # Teal (Nord7)
    };
  };
}
