# Darwin modules index
# Imports all darwin-specific modules
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./system.nix
    ./homebrew.nix
    ./sudo.nix
    ./services/sshd.nix
    ./services/ollama.nix
    ./services/tailscale.nix
    ./services/whisper.nix
    ./services/linux-builder.nix
    ./services/harmonia.nix
    ./services/llama-server.nix
  ];
}
