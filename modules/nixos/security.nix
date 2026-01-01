# NixOS security configuration
# SSH server, firewall, and access control
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # ==========================================================================
  # SSH Server
  # ==========================================================================
  services.openssh = {
    enable = true;
    settings = {
      # Security hardening
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;

      # Only allow modern crypto
      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
      ];
      KexAlgorithms = [
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
      ];

      # Connection settings
      X11Forwarding = false;
      MaxAuthTries = 3;
    };

    # Host keys
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  # ==========================================================================
  # Firewall
  # ==========================================================================
  networking.firewall = {
    enable = true;

    # SSH + LocalSend
    allowedTCPPorts = [
      22
      53317
    ];
    allowedUDPPorts = [ 53317 ];

    # Trust Tailscale interface when enabled
    trustedInterfaces = lib.mkIf config.services.tailscale.enable [ "tailscale0" ];
  };

  # ==========================================================================
  # Tailscale
  # ==========================================================================
  services.tailscale = {
    enable = lib.mkDefault true;
    useRoutingFeatures = "client";
  };

  # ==========================================================================
  # Sudo
  # ==========================================================================
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;

    # Allow running certain commands without password
    extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/nixos-rebuild";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/systemctl";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  # ==========================================================================
  # PAM / Authentication
  # ==========================================================================
  security.pam.services = {
    # Enable FIDO2/Yubikey authentication
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  # FIDO2 / Yubikey support
  hardware.gpgSmartcards.enable = true;
  services.pcscd.enable = true;

  environment.systemPackages = with pkgs; [
    yubikey-manager
    yubikey-personalization
    pam_u2f
  ];
}
