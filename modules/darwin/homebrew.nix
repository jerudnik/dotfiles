# Homebrew configuration for macOS
# Manages GUI applications (casks) and formulae not in nixpkgs
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Enable Homebrew management through nix-darwin
  homebrew = {
    enable = true;

    # Behavior on activation
    onActivation = {
      # Remove formulae/casks not listed here
      cleanup = "zap";

      # Auto-update Homebrew itself
      autoUpdate = true;

      # Upgrade outdated packages
      upgrade = true;
    };

    # Homebrew taps (repositories)
    taps = [ ];

    # CLI tools installed via Homebrew
    # (Prefer nixpkgs when available, use brew if a package isn't available for macOS)
    brews = [ ];

    # GUI applications
    casks = [
      "ghostty"
      "orbstack"
      "iina"
      "raycast"
      "claude"
      "helium-browser"
      "beeper"
      "spotify"
    ];

    # Mac App Store apps (requires `mas` CLI)
    # Uncomment and add apps as needed:
    # masApps = {
    #   "App Name" = 123456789;  # App Store ID
    # };
  };
}
