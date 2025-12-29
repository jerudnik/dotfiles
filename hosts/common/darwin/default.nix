# Common darwin configuration shared across all macOS hosts
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # Import all darwin modules
    ../../../modules/darwin

    # Shared Stylix configuration
    ../../../modules/base/stylix.nix
  ];

  # Required for nix-darwin to work
  system.stateVersion = 5;

  # Let Determinate Nix handle Nix configuration
  nix.enable = false;

  # Custom Determinate Nix settings
  determinate-nix.customSettings = {
    # Enables parallel evaluation
    eval-cores = 0;
    extra-experimental-features = [
      "build-time-fetch-tree"
      "parallel-eval"
    ];
  };

  # Enable Touch ID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;
}
