# User jrudnik - system-level configuration
# This file is for nix-darwin user settings (not home-manager)
{
  config,
  pkgs,
  lib,
  ...
}:

{
  users.users.jrudnik = {
    name = "jrudnik";
    home = "/Users/jrudnik";
    shell = pkgs.zsh;
    description = "John Rudnik";
  };
}
