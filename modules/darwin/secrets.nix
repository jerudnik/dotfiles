# sops-nix secrets configuration
# Secrets are decrypted at system activation and placed in /run/secrets/
# Uses Yubikey-backed age keys via age-plugin-yubikey
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # sops-nix configuration
  sops = {
    # Default encrypted secrets file
    defaultSopsFile = ../../secrets/secrets.yaml;

    # Age key configuration - Yubikey identity file
    # Use primaryUser to support different users on different machines
    age = {
      keyFile = "/Users/${config.system.primaryUser}/.config/sops/age/yubikey-identity.txt";
      # Don't generate a new key - we're using Yubikey
      generateKey = false;
      # Disable SSH key paths - we only use Yubikey
      sshKeyPaths = [ ];
    };

    # Disable gnupg SSH key paths as well
    gnupg.sshKeyPaths = [ ];

    # Set environment for sops-install-secrets to find the age plugin and macOS binaries
    # Needs: hdiutil (/usr/bin), newfs_hfs (/sbin), mount (/sbin) for ramdisk secrets
    environment.PATH = lib.makeBinPath [ pkgs.age-plugin-yubikey ] + ":/usr/bin:/sbin";

    # Declare secrets to be decrypted
    secrets = {
      # Harmonia signing key (private)
      "harmonia/signing_key" = {
        owner = "root";
        group = "wheel";
        mode = "0400";
      };
    };
  };

  # Ensure age-plugin-yubikey is available system-wide
  environment.systemPackages = with pkgs; [
    age-plugin-yubikey
  ];
}
