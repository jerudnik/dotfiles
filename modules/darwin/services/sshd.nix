# SSH server (Remote Login) service module
# Enables macOS built-in sshd with hardened configuration
# Supports authorized keys as inline strings or file paths
{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.sshd;
  # Combine inline keys into a single string
  inlineKeysContent = concatStringsSep "\n" cfg.authorizedKeys;
in
{
  options.services.sshd = {
    enable = mkEnableOption "SSH server (Remote Login)";

    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        List of SSH public keys (as strings) to authorize.
        These are written directly to the authorized_keys file.
      '';
      example = [ "ssh-ed25519 AAAAC3... user@host" ];
    };

    authorizedKeysFiles = mkOption {
      type = types.listOf types.path;
      default = [ ];
      description = ''
        List of paths to files containing authorized SSH public keys.
        All keys from all files will be combined into the authorized_keys.
        Typically points to sops secret paths.
      '';
    };

    # Legacy option for backwards compatibility
    authorizedKeysFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Deprecated: Use authorizedKeysFiles or authorizedKeys instead";
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
    # Combine legacy option with new list
    services.sshd.authorizedKeysFiles = mkIf (cfg.authorizedKeysFile != null) [
      cfg.authorizedKeysFile
    ];

    # Hardened sshd configuration via drop-in config
    environment.etc."ssh/sshd_config.d/100-nix-managed.conf".text = ''
      # Managed by nix-darwin - do not edit manually
      PasswordAuthentication ${if cfg.passwordAuthentication then "yes" else "no"}
      KbdInteractiveAuthentication no
      PubkeyAuthentication yes
      PermitRootLogin ${cfg.permitRootLogin}
      AuthenticationMethods publickey
      ${optionalString (cfg.authorizedKeys != [ ] || cfg.authorizedKeysFiles != [ ]) ''
        AuthorizedKeysFile .ssh/authorized_keys /etc/ssh/authorized_keys.d/%u
      ''}
    '';

    # Pre-activation: Remove authorized_keys.d to prevent nix-darwin security check failure
    system.activationScripts.preActivation.text =
      mkIf (cfg.authorizedKeys != [ ] || cfg.authorizedKeysFiles != [ ])
        ''
          # Remove existing authorized_keys.d to prevent nix-darwin aborting
          if [ -d /etc/ssh/authorized_keys.d ]; then
            echo "Removing /etc/ssh/authorized_keys.d for re-activation..."
            rm -rf /etc/ssh/authorized_keys.d
          fi
        '';

    # System activation to enable Remote Login and set up authorized keys
    system.activationScripts.postActivation.text = ''
      # Enable Remote Login (SSH server)
      if ! systemsetup -getremotelogin 2>/dev/null | grep -q "On"; then
        echo "Enabling SSH server (Remote Login)..."
        systemsetup -setremotelogin on 2>/dev/null || true
      fi

      ${optionalString (cfg.authorizedKeys != [ ] || cfg.authorizedKeysFiles != [ ]) ''
        # Set up system-wide authorized keys
        echo "Setting up SSH authorized keys..."
        mkdir -p /etc/ssh/authorized_keys.d
        for user in $(dscl . -list /Users | grep -v '^_'); do
          if [ -d "/Users/$user" ]; then
            # Start with inline keys
            ${optionalString (cfg.authorizedKeys != [ ]) ''
              echo ${escapeShellArg inlineKeysContent} > "/etc/ssh/authorized_keys.d/$user"
            ''}
            # Append keys from files
            ${optionalString (cfg.authorizedKeysFiles != [ ]) ''
              cat ${concatStringsSep " " (map (f: toString f) cfg.authorizedKeysFiles)} ${
                if cfg.authorizedKeys != [ ] then ">>" else ">"
              } "/etc/ssh/authorized_keys.d/$user" 2>/dev/null || true
            ''}
            chmod 644 "/etc/ssh/authorized_keys.d/$user" 2>/dev/null || true
          fi
        done
      ''}
    '';
  };
}
