# Home Manager configuration for jrudnik (MacBook Air)
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    # Import all home-manager modules (shared with john)
    ../../modules/home
  ];

  # Copy apps to ~/Applications for Spotlight integration (replaces mac-app-util)
  # See: https://github.com/nix-community/home-manager/pull/8031
  targets.darwin.copyApps.enable = true;
  targets.darwin.linkApps.enable = false;

  # Home Manager needs a bit of information about you and the paths it should manage
  home = {
    username = "jrudnik";
    homeDirectory = "/Users/jrudnik";

    # Disable nixpkgs release check (using stable nixpkgs with unstable home-manager)
    enableNixpkgsReleaseCheck = false;
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    stateVersion = "24.11";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
