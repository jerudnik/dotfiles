# Waybar status bar - ChromeOS-inspired styling
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.desktop;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.waybar ];
  };
}
