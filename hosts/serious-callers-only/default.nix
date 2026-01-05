# Mac Studio host configuration
# AI Inference Server Setup
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

    # Harmonia secrets (cache signing key)
    ../../modules/darwin/secrets.nix
  ];

  # Primary user for nix-darwin (required for user-specific settings)
  system.primaryUser = "john";

  # Host-specific settings
  networking.hostName = "serious-callers-only";
  networking.computerName = "serious-callers-only";

  # Theme
  themes.scheme = "nord";
  themes.mode = "light";

  # ============================================================
  # Native Linux builds
  # ============================================================
  # Determinate Nix external-builders handle Linux builds automatically on
  # Darwin, so no explicit `services.linux-builder` configuration is required.

  # User configuration
  users.users.john = {
    name = "john";
    home = "/Users/john";
    shell = pkgs.zsh;

    # SSH authorized keys for:
    # - Interactive access from both Macs (Bitwarden-managed keys)
    # - Automated access via the builder key (for inbound CI/build hosts)
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPHqpAWaR2rb6eHxcW2dr1qEzELbonR5vczp5srxgp2W serious-callers-only"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHUET4JHxbky06pOvg0gCE39iTt8X5aeulQPliJoq8Y6 just-testing"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHKv76hdR1c0Uu7bcd2WUNisuSmQA1k/uPZsF5dDrT2z builder@serious-callers-only"
    ];
  };

  # ============================================================
  # AI Inference Services
  # ============================================================

  # Ollama - LLM inference server
  services.ollama = {
    enable = false;
    host = "0.0.0.0"; # Network accessible
    port = 11434;
  };

  # llama.cpp - Local LLM inference via llama-server
  services.llama-server = {
    enable = true;
    host = "0.0.0.0";
    port = 11434;
  };

  # Whisper.cpp - Speech-to-text transcription
  services.whisper = {
    enable = true;
    model = "large-v3";
  };

  # Tailscale - Secure remote access
  services.tailscale.enable = true;

  # SSH server for remote access
  services.sshd = {
    enable = true;
    # Authorized keys are now managed outside of sops-nix (e.g., via chezmoi)
  };

  # Harmonia binary cache
  services.harmonia = {
    enable = true;
    signKeyPath = config.sops.secrets."harmonia/signing_key".path;
    # bind/priority defaults set in module
  };

}
