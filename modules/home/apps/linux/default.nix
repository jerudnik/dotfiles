# Linux-specific applications
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  home.packages = with pkgs; [
    # File management
    thunar
    thunar-archive-plugin
    thunar-volman
    file-roller

    # Clipboard
    wl-clipboard
    cliphist

    # Screenshots
    grim
    slurp

    # File sharing
    localsend

    # Media
    imv # Image viewer
    mpv # Video player

    # Chat
    beeper

    # System utilities
    pavucontrol # Audio control
    networkmanagerapplet # Network management
    blueman # Bluetooth management
  ];

  # Thunar configuration
  xdg.mimeApps.defaultApplications = {
    "inode/directory" = [ "thunar.desktop" ];
  };
}
