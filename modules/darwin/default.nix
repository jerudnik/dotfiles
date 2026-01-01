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
    ./secrets.nix
    ./services/sshd.nix
    ./services/exo.nix
    ./services/ollama.nix
    ./services/tailscale.nix
    ./services/whisper.nix
    ./services/emacs.nix
    ./services/linux-builder.nix
  ];
}
