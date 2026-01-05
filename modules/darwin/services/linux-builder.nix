# Linux builder - handled by Determinate Nix external builders
# Determinate Nix ships native Linux build support via external-builders, so
# there is no longer any explicit `services.linux-builder` configuration.
{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.services.linux-builder = lib.mkRemovedOptionModule [ "services" "linux-builder" ] ''
    Determinate Nix now provisions native Linux builders automatically via
    `external-builders`. Remove any lingering `services.linux-builder` options
    and rely on Determinate Nix for cross-compilation support.
  '';
}
