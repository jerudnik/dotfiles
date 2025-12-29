# User john - system-level configuration
# This file is for nix-darwin user settings (not home-manager)
{
  config,
  pkgs,
  lib,
  ...
}:

{
  users.users.john = {
    name = "john";
    home = "/Users/john";
    shell = pkgs.zsh;
    description = "John Rudnik";
  };
}
