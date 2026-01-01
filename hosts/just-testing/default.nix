# MacBook Air host configuration
# Work laptop - shares most config with Mac Studio but NO AI model hosting
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    # Common darwin configuration
    ../common/darwin
  ];

  # Primary user for nix-darwin (required for user-specific settings)
  system.primaryUser = "jrudnik";

  # Host-specific settings
  networking.hostName = "just-testing";
  networking.computerName = "just-testing";

  # User configuration
  users.users.jrudnik = {
    name = "jrudnik";
    home = "/Users/jrudnik";
    shell = pkgs.zsh;
  };

  # ============================================================
  # Services
  # ============================================================

  # SSH server for remote access
  services.sshd = {
    enable = true;
    authorizedKeysFile = config.sops.secrets."ssh/authorized_key".path;
  };

  # Tailscale - Secure remote access
  services.tailscale.enable = true;

  # ============================================================
  # Editor Services
  # ============================================================

  # Emacs - daemon mode for instant startup
  services.emacs-daemon.enable = true;

  # ============================================================
  # AI Services - DISABLED on MacBook Air
  # ============================================================
  # This machine does not run local AI models
  # Use AI tools that connect to serious-callers-only or remote APIs

  services.exo.enable = false;
  services.ollama.enable = false;
  services.whisper.enable = false;

  # ============================================================
  # Remote Building
  # ============================================================
  # Use Mac Studio as remote builder for faster builds and Linux support
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "serious-callers-only";
      sshUser = "john";
      sshKey = "/Users/jrudnik/.ssh/id_ed25519_sk";
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      maxJobs = 8;
      speedFactor = 10;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
      ];
    }
  ];
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
