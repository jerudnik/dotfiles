# Quality of Life applications
# Cross-platform utilities for productivity and daily use
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./file-sharing.nix
    ./file-management.nix
    ./media.nix
    ./productivity.nix
    ./launcher.nix
    ./password-manager.nix
  ];
}
