# Mako notification daemon
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.desktop;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.mako ];
  };
}
