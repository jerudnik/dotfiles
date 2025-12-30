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

  # ============================================================
  # Editor Configuration
  # ============================================================

  # Emacs - knowledge management and programmable notes
  programs.myEmacs.enable = true;
}
