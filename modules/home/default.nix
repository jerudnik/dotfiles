# Home Manager modules index
# Imports all home-manager modules
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./shell
    ./git.nix
    ./ssh.nix
    ./editors
    ./terminal
    ./apps
    ./packages.nix
    ./development.nix
    ./python-tools.nix
    ./ai
  ];
}
