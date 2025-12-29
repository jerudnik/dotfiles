# Base modules - cross-platform configuration
# These modules can be imported by both darwin and NixOS hosts
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # This file serves as a placeholder for cross-platform modules.
  #
  # Use this for configuration that should work identically on both
  # macOS (nix-darwin) and Linux (NixOS) systems.
  #
  # Examples of what could go here:
  # - Common environment variables
  # - Cross-platform service configurations
  # - Shared user definitions
  #
  # For now, most cross-platform config lives in home-manager modules
  # (modules/home/) which are inherently cross-platform.
}
