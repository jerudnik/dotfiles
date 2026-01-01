# NixOS module index
# Imports all NixOS-specific modules
{ ... }:
{
  imports = [
    ./system.nix
    ./security.nix
    ./desktop
  ];
}
