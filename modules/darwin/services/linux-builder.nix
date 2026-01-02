# Linux builder VM for cross-compilation
# Provides on-demand Linux build capability for darwin machines
#
# NOTE: Temporarily disabled due to nix.enable=false with Determinate Nix.
# Enable when virtualization access is confirmed and Determinate Nix is reconfigured.
{
  config,
  lib,
  pkgs,
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

  config = mkIf cfg.enable {
    # Temporarily disabled - requires nix.enable=true
    # nix.linux-builder = {
    #   enable = true;
    #   maxJobs = 2;
    #   speedFactor = 2;
    # };
  };
}
