# Harmonia - Nix binary cache service for macOS (launchd)
# Based on nix-darwin service patterns (mkEnableOption, launchd.daemons)
{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.services.harmonia;

  configFile = pkgs.writeText "harmonia.toml" ''
    bind = "${cfg.bind}"
    workers = ${toString cfg.workers}
    max_connection_rate = ${toString cfg.maxConnectionRate}
    priority = ${toString cfg.priority}
    ${optionalString cfg.enableCompression "enable_compression = true"}
    ${optionalString (cfg.signKeyPath != null) ''sign_key_paths = ["${cfg.signKeyPath}"]''}
  '';

in
{
  options.services.harmonia = {
    enable = mkEnableOption "Harmonia Nix binary cache service";

    bind = mkOption {
      type = types.str;
      default = "0.0.0.0:5000";
      description = "Address and port to bind Harmonia server (e.g., 0.0.0.0:5000).";
    };

    signKeyPath = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''Path to the binary cache signing key (private). Managed via sops; required for production use.'';
    };

    workers = mkOption {
      type = types.int;
      default = 4;
      description = "Number of worker threads.";
    };

    maxConnectionRate = mkOption {
      type = types.int;
      default = 256;
      description = "Maximum concurrent connections per worker.";
    };

    priority = mkOption {
      type = types.int;
      default = 30;
      description = ''Binary cache priority (lower = higher priority). cache.nixos.org is 40.'';
    };

    enableCompression = mkOption {
      type = types.bool;
      default = false;
      description = "Enable zstd compression for responses (may reduce resume reliability on flaky links).";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.signKeyPath != null;
        message = "services.harmonia.enable requires services.harmonia.signKeyPath to be set.";
      }
    ];

    environment.systemPackages = [ pkgs.harmonia ];

    launchd.daemons.harmonia = {
      serviceConfig = {
        Label = "org.nixos.harmonia";
        ProgramArguments = [ "${pkgs.harmonia}/bin/harmonia" ];
        EnvironmentVariables = {
          CONFIG_FILE = toString configFile;
          RUST_LOG = "info";
        };
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/var/log/harmonia.log";
        StandardErrorPath = "/var/log/harmonia.error.log";
        UserName = "root";
        GroupName = "wheel";
      };
    };

    system.activationScripts.harmonia-info.text = ''
      echo ""
      echo "════════════════════════════════════════════════════════════════"
      echo "  Harmonia Binary Cache"
      echo "════════════════════════════════════════════════════════════════"
      echo "  Hostname: ${config.networking.hostName}"
      echo "  Bind:     ${cfg.bind}"
      echo "  Priority: ${toString cfg.priority}"
      echo "  Config:   ${configFile}"
      echo "  Logs:     /var/log/harmonia.log"
      echo "           /var/log/harmonia.error.log"
      echo ""
      echo "  Test endpoints:"
      echo "    curl http://${cfg.bind}/nix-cache-info"
      echo "    curl http://${cfg.bind}/metrics"
      echo "════════════════════════════════════════════════════════════════"
    '';
  };
}
