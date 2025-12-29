# File sharing and sync utilities
# LocalSend: Cross-platform AirDrop alternative
# Syncthing: Continuous file synchronization
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ============================================================
  # LocalSend - Local network file sharing
  # ============================================================
  # Cross-platform AirDrop alternative for sharing files between devices
  home.packages = with pkgs; [
    localsend
  ];

  # ============================================================
  # Syncthing - Continuous file synchronization
  # ============================================================
  services.syncthing = {
    enable = true;

    # Syncthing tray icon (Linux only, requires a system tray)
    # tray.enable = lib.mkIf pkgs.stdenv.isLinux true;
  };
}
