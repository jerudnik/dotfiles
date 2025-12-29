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
  ];

  # Primary user for nix-darwin (required for user-specific settings)
  system.primaryUser = "john";

  # Host-specific settings
  networking.hostName = "johns-Mac-Studio";
  networking.computerName = "John's Mac Studio";

  # User configuration
  users.users.john = {
    name = "john";
    home = "/Users/john";
    shell = pkgs.zsh;
  };

  # ============================================================
  # AI Inference Services
  # ============================================================

  # Disable exo for now (using Ollama instead)
  services.exo.enable = false;

  # Ollama - LLM inference server
  services.ollama = {
    enable = true;
    host = "0.0.0.0"; # Network accessible
    port = 11434;
  };

  # Whisper.cpp - Speech-to-text transcription
  services.whisper = {
    enable = true;
    model = "large-v3";
  };

  # Tailscale - Secure remote access
  services.tailscale.enable = true;

  # ============================================================
  # Editor Services
  # ============================================================

  # Emacs - daemon mode for instant startup
  services.emacs-daemon.enable = true;
}
