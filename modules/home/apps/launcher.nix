# Application launcher
# Rofi: Window switcher and application launcher (Linux only)
# macOS uses Raycast via Homebrew
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ============================================================
  # Rofi - Application launcher (Linux only)
  # ============================================================
  programs.rofi = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;

    # Use Wayland-compatible version if available
    package = pkgs.rofi-wayland;

    # Terminal to use for terminal applications
    terminal = "${pkgs.wezterm}/bin/wezterm";

    # Basic settings
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      icon-theme = "Papirus";
      display-drun = "Apps";
      display-run = "Run";
      display-window = "Windows";
      drun-display-format = "{name}";
    };

    # Theme follows system (Stylix will handle this if enabled)
  };
}
