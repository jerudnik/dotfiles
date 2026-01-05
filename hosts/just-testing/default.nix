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

  # Theme
  themes.scheme = "modus";
  themes.mode = "dark";

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
  # Authorized keys are public keys - no need to encrypt them
  services.sshd = {
    enable = true;
    authorizedKeys = [
      # Bitwarden SSH keys (just-testing and serious-callers-only)
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHUET4JHxbky06pOvg0gCE39iTt8X5aeulQPliJoq8Y6 just-testing"
      # Legacy keys for historical access (can be removed once all machines migrated)
      # "ssh-ed25519 AAAAC3... serious-callers-only"
    ];
  };

  # Tailscale - Secure remote access
  services.tailscale.enable = true;

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

  # ============================================================
  # Secrets - DISABLED (using Bitwarden instead of sops-nix)
  # ============================================================
  # This host uses Bitwarden CLI + chezmoi for secrets management
  # instead of sops-nix + Yubikey. Disable all sops secrets.
  sops.secrets = lib.mkForce { };
}
