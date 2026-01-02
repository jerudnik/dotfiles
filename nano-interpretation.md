{ pkgs, ... }:

{
  stylix.enable = true;

  # Define the custom scheme directly
  stylix.base16Scheme = {
    scheme = "Nano Emacs Dark";
    author = "Nicolas P. Rougier (ported to Base16)";
    
    # --- The Monochrome Ramp ---
    base00 = "1d1e2c"; # Background (Main dark blue-grey)
    base01 = "292a3a"; # Lighter Background (Status bars)
    base02 = "353648"; # Selection / Highlight
    base03 = "555667"; # Comments / Faded text
    base04 = "7a7b8c"; # Darker Foreground
    base05 = "d9d9d9"; # Default Foreground (Main text)
    base06 = "e8e8e8"; # Light Foreground
    base07 = "ffffff"; # Brightest Text

    # --- The Accents ---
    # Nano uses "Critical" (Red) and "Salient" (Blue/Purple) primarily.
    
    base08 = "e06c75"; # Red     (Variables, XML Tags, Diff Deleted) -> Nano Critical
    base09 = "e5c07b"; # Orange  (Integers, Bool, Constants)         -> Nano Popout (shifted)
    base0A = "e5c07b"; # Yellow  (Classes, Search Text)              -> Nano Popout
    base0B = "98c379"; # Green   (Strings, Diff Inserted)            -> Custom Desaturated Green*
    base0C = "6791c9"; # Cyan    (Support, Regex, Escape)            -> Nano Salient (Light)
    base0D = "6791c9"; # Blue    (Functions, Methods, Headings)      -> Nano Salient (Main)
    base0E = "c678dd"; # Purple  (Keywords, Storage, Diff Changed)   -> Nano Strong (or Salient Var)
    base0F = "555667"; # Brown   (Deprecated, Standard Text)         -> Nano Faded (Neutral)
  };

  # Optional: Force wallpaper to match if you don't have one
  stylix.image = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rougier/nano-emacs/master/images/nano-banner.png";
    sha256 = "sha256-placeholder..."; # You'd need a real wallpaper SHA or file path
  };
}
