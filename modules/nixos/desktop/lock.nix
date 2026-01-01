# Hyprlock + Hypridle - lock screen and idle management
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
    environment.systemPackages = with pkgs; [
      hyprlock
      hypridle
    ];

    # Lid switch handling
    services.logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "lock";
    };
  };
}
