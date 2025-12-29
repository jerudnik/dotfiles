# Tailscale - Mesh VPN for secure remote access
# https://tailscale.com
#
# This module wraps the built-in nix-darwin services.tailscale
# and adds Homebrew installation + setup instructions.
{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.services.tailscale;
in
{
  # No custom options - we use the built-in services.tailscale.enable

  config = mkIf cfg.enable {
    # Install Tailscale via Homebrew cask (GUI app with menu bar)
    homebrew.casks = [ "tailscale" ];

    # Setup instructions
    system.activationScripts.tailscale-setup.text = ''
      echo ""
      echo "════════════════════════════════════════════════════════════"
      echo "  Tailscale Configuration Applied"
      echo "════════════════════════════════════════════════════════════"
      echo ""
      echo "  Setup Steps:"
      echo "    1. Open Tailscale from menu bar (or /Applications)"
      echo "    2. Click 'Log in' and authenticate"
      echo "    3. Approve the device in Tailscale admin console"
      echo ""
      echo "  After Setup:"
      echo "    tailscale ip -4              # Show your Tailscale IP"
      echo "    tailscale status             # Show connected devices"
      echo ""
      echo "  Access Services from Other Devices:"
      echo "    Ollama API:  http://<tailscale-ip>:11434"
      echo "    Open WebUI:  http://<tailscale-ip>:3000"
      echo "    Portainer:   http://<tailscale-ip>:9000"
      echo "════════════════════════════════════════════════════════════"
    '';
  };
}
