# Hyprland compositor configuration
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
    # System-level Hyprland
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Required packages
    environment.systemPackages = with pkgs; [
      wezterm
      wl-clipboard
      grim
      slurp
      brightnessctl
      playerctl
      pamixer
      appimage-run
    ];

    # Enable Flatpak for Helium browser
    services.flatpak.enable = true;
  };
}
