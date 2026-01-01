# Linux builder VM for cross-compilation
# Provides on-demand Linux build capability for darwin machines
#
# NOTE: nix.linux-builder requires nix.enable = true, which conflicts with
# Determinate Nix (used in this repo). This module is currently a no-op.
# For Linux builds from macOS, use one of these alternatives:
#   1. OrbStack (recommended) - provides seamless Linux VM with Nix support
#   2. UTM/QEMU - manual Linux VM setup
#   3. Remote builder - SSH to a Linux machine (e.g., sleeper-service)
#
# TODO: Re-enable when Determinate Nix supports linux-builder, or switch
# to using OrbStack/remote builders for Linux compilation.
{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.services.linux-builder;
in
{
  options.services.linux-builder = {
    enable = mkEnableOption "Linux builder VM for cross-compilation";
  };

  # Currently a no-op - nix.linux-builder requires nix.enable = true
  # which conflicts with Determinate Nix
  config = mkIf cfg.enable {
    warnings = [
      ''
        services.linux-builder.enable is set but has no effect.
        nix.linux-builder requires nix.enable = true, which conflicts
        with Determinate Nix. Consider using OrbStack or a remote Linux
        builder (e.g., ssh://john@sleeper-service) instead.
      ''
    ];
  };
}
