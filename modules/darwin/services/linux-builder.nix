# Linux builder VM for cross-compilation
# Provides on-demand Linux build capability for darwin machines
# The VM is ephemeral - only runs when Linux builds are requested
{
  config,
  pkgs,
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

  config = mkIf cfg.enable {
    nix.linux-builder = {
      enable = true;

      # Don't persist VM state - start fresh each time
      ephemeral = true;

      # Supported architectures
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # VM resources - generous since it only runs on-demand
      # Mac Studio M2 Ultra has 24 cores, allocate half to VM
      config = {
        virtualisation = {
          cores = 12;
          memorySize = 16384; # 16GB RAM
          diskSize = 40960; # 40GB disk
        };
      };

      # High speed factor = prefer this builder over slower alternatives
      speedFactor = 10;

      # Features this builder supports
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm" # VM has nested virtualization
      ];
    };

    # Allow the builder to use binary caches
    nix.settings.builders-use-substitutes = true;
  };
}
