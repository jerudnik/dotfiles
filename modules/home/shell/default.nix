# Shell configuration index
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./zsh.nix
    ./starship.nix
    ./aliases.nix
  ];
}
