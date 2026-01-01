# Desktop environment module index
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
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./launcher.nix
    ./notifications.nix
    ./lock.nix
  ];

  options.desktop = {
    enable = mkEnableOption "desktop environment (Hyprland + supporting tools)";
  };

  config = mkIf cfg.enable {
    # XDG portal configuration for Wayland
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    # Enable dconf for GTK settings
    programs.dconf.enable = true;

    # Fonts
    fonts.packages = with pkgs; [
      nerd-fonts.im-writing
      ibm-plex
      noto-fonts-color-emoji
    ];
  };
}
