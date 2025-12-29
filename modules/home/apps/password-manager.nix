# Password management
# Bitwarden: Open source password manager
{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    # ============================================================
    # Bitwarden - Password manager
    # ============================================================
    # Desktop application
    bitwarden-desktop

    # CLI tool for scripting and terminal access
    bitwarden-cli
  ];
}
