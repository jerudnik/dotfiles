{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.emacs-daemon;
in
{
  options.services.emacs-daemon = {
    enable = mkEnableOption "Emacs daemon service (Homebrew emacs-plus)";
  };

  config = mkIf cfg.enable {
    launchd.user.agents.emacs = {
      serviceConfig = {
        Label = "org.gnu.emacs.daemon";
        ProgramArguments = [
          "/opt/homebrew/bin/emacs"
          "--fg-daemon"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/emacs-daemon.log";
        StandardErrorPath = "/tmp/emacs-daemon.err";
        EnvironmentVariables = {
          PATH = "/opt/homebrew/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin";
        };
      };
    };

    system.activationScripts.postActivation.text = ''
      echo ""
      echo "======================================================================"
      echo "Emacs daemon service configured."
      echo ""
      echo "Usage:"
      echo "  emacsclient -c           # Open new GUI frame"
      echo "  emacsclient -t           # Open in terminal"
      echo "  emacsclient -n file      # Open file in existing frame (no wait)"
      echo ""
      echo "Aliases (after shell restart):"
      echo "  e   -> emacsclient -c"
      echo "  et  -> emacsclient -t"
      echo "  em  -> emacsclient -n"
      echo ""
      echo "Manage daemon:"
      echo "  launchctl kickstart -k gui/$(id -u)/org.gnu.emacs.daemon  # Restart"
      echo "  launchctl kill SIGTERM gui/$(id -u)/org.gnu.emacs.daemon  # Stop"
      echo "======================================================================"
    '';
  };
}
