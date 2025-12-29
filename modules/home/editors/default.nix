# Editor configuration index
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./helix.nix
    ./emacs
  ];
}
