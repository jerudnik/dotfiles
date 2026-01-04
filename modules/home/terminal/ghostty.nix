# Ghostty terminal configuration
# Ghostty is installed via Homebrew cask (modules/darwin/homebrew.nix)
{
  lib,
  pkgs,
  ...
}:

{
  # Ghostty config now lives in chezmoi (dot_config/ghostty/config.tmpl)
  # Only ensure the package is present on Linux; macOS uses Homebrew.
  home.packages = lib.optionals pkgs.stdenv.isLinux [ pkgs.ghostty ];
}
