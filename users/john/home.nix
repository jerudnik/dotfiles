# Home Manager configuration for john
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    # Import all home-manager modules
    ../../modules/home
  ];

  # Link apps to ~/Applications (symlinks, no App Management permission needed)
  # Note: copyApps works better with Spotlight but requires App Management permission
  # which gets revoked during darwin-rebuild. Using linkApps as workaround.
  targets.darwin.linkApps.enable = true;

  # Home Manager needs a bit of information about you and the paths it should manage
  home = {
    username = "john";
    homeDirectory = "/Users/john";

    # Disable nixpkgs release check (using stable nixpkgs with unstable home-manager)
    enableNixpkgsReleaseCheck = false;

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "24.11";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
