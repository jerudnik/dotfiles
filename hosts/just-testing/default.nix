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
    authorizedKeysFiles = [
      config.sops.secrets."ssh/authorized_key_secretive".path
      config.sops.secrets."ssh/authorized_key_builder".path
      config.sops.secrets."ssh/authorized_key_yubikey".path
    ];
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

  services.ollama.enable = false;
  services.whisper.enable = false;

  # ============================================================
  # Remote Building
  # ============================================================
  # NOTE: Remote builder config requires nix.enable = true, which conflicts
  # with Determinate Nix. To use serious-callers-only as a remote builder,
  # configure it manually in /etc/nix/machines or use:
  #   nix build --builders 'ssh://john@serious-callers-only'
  #
  # Once Determinate Nix supports distributed builds natively, we can
  # enable this configuration:
  #
  # nix.distributedBuilds = true;
  # nix.buildMachines = [{
  #   hostName = "serious-callers-only";
  #   sshUser = "john";
  #   sshKey = "/Users/jrudnik/.ssh/id_ed25519_sk";
  #   systems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
  #   maxJobs = 8;
  #   speedFactor = 10;
  #   supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" ];
  # }];
  # nix.extraOptions = ''
  #   builders-use-substitutes = true
  # '';
}
