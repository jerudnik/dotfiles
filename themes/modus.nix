{ lib }:
let
  strip = color: lib.removePrefix "#" color;
  mkScheme =
    {
      slug,
      scheme,
      palette,
    }:
    {
      inherit slug scheme;
      author = "Protesilaos Stavrou";
    }
    // lib.mapAttrs (_: value: strip value) palette;
in
{
  operandi = mkScheme {
    slug = "modus-operandi";
    scheme = "Modus Operandi";
    palette = {
      base00 = "#ffffff";
      base01 = "#f2f2f2";
      base02 = "#e0e0e0";
      base03 = "#9f9f9f";
      base04 = "#595959";
      base05 = "#000000";
      base06 = "#1f1f1f";
      base07 = "#193668";
      base08 = "#a60000";
      base09 = "#973300";
      base0A = "#6f5500";
      base0B = "#006800";
      base0C = "#005e8b";
      base0D = "#0031a9";
      base0E = "#721045";
      base0F = "#80601f";
    };
  };

  vivendi = mkScheme {
    slug = "modus-vivendi";
    scheme = "Modus Vivendi";
    palette = {
      base00 = "#000000";
      base01 = "#1e1e1e";
      base02 = "#303030";
      base03 = "#535353";
      base04 = "#989898";
      base05 = "#ffffff";
      base06 = "#c6daff";
      base07 = "#f5f5f5";
      base08 = "#ff5f59";
      base09 = "#ff6b55";
      base0A = "#d0bc00";
      base0B = "#44bc44";
      base0C = "#00d3d0";
      base0D = "#2fafff";
      base0E = "#feacd0";
      base0F = "#c0965b";
    };
  };
}
