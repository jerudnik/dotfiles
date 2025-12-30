# SSH server (Remote Login) service module
# Enables macOS built-in sshd with hardened configuration
# Uses Yubikey-backed SSH keys via FIDO2/ed25519-sk
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.sshd;
in
{
  options.services.sshd = {
    enable = mkEnableOption "SSH server (Remote Login)";

    authorizedKeysFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to a file containing authorized SSH public keys.
        Typically points to a sops secret path like config.sops.secrets."ssh/authorized_key".path
      '';
    };

    passwordAuthentication = mkOption {
      type = types.bool;
      default = false;
      description = "Allow password authentication (not recommended)";
    };

    permitRootLogin = mkOption {
      type = types.enum [
        "yes"
        "no"
        "prohibit-password"
        "forced-commands-only"
      ];
      default = "no";
      description = "Whether to allow root login via SSH";
    };
  };

  config = mkIf cfg.enable {
    # Hardened sshd configuration via drop-in config
    environment.etc."ssh/sshd_config.d/100-nix-managed.conf".text = ''
      # Managed by nix-darwin - do not edit manually
      PasswordAuthentication ${if cfg.passwordAuthentication then "yes" else "no"}
      KbdInteractiveAuthentication no
      PubkeyAuthentication yes
      PermitRootLogin ${cfg.permitRootLogin}
      AuthenticationMethods publickey
      ${optionalString (cfg.authorizedKeysFile != null) ''
        AuthorizedKeysFile .ssh/authorized_keys /etc/ssh/authorized_keys.d/%u
      ''}
    '';

    # System activation to enable Remote Login and set up authorized keys
    system.activationScripts.postActivation.text = ''
      # Enable Remote Login (SSH server)
      if ! systemsetup -getremotelogin 2>/dev/null | grep -q "On"; then
        echo "Enabling SSH server (Remote Login)..."
        systemsetup -setremotelogin on 2>/dev/null || true
      fi

      ${optionalString (cfg.authorizedKeysFile != null) ''
        # Set up system-wide authorized keys from sops secret
        echo "Setting up SSH authorized keys..."
        mkdir -p /etc/ssh/authorized_keys.d
        for user in $(dscl . -list /Users | grep -v '^_'); do
          if [ -d "/Users/$user" ]; then
            cat ${cfg.authorizedKeysFile} > "/etc/ssh/authorized_keys.d/$user" 2>/dev/null || true
            chmod 644 "/etc/ssh/authorized_keys.d/$user" 2>/dev/null || true
          fi
        done
      ''}
    '';
  };
}
