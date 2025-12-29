# exo - Run your own AI cluster at home
# https://github.com/exo-explore/exo
{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.services.exo;
  exoDir = "${config.users.users.john.home}/Projects/exo";
in
{
  options.services.exo = {
    enable = mkEnableOption "exo LLM cluster service";

    port = mkOption {
      type = types.port;
      default = 52415;
      description = "Port for exo API and dashboard";
    };

    dataDir = mkOption {
      type = types.str;
      default = exoDir;
      description = "Directory where exo is cloned";
    };

    user = mkOption {
      type = types.str;
      default = "john";
      description = "User to run exo as";
    };

    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Start exo automatically on boot";
    };
  };

  config = mkIf cfg.enable {
    # Ensure required dependencies are available via Homebrew
    homebrew.brews = [
      "uv" # Python package manager
      "node" # For building dashboard
      "macmon" # Hardware monitoring
    ];

    # Install Rust toolchain via nixpkgs
    environment.systemPackages = with pkgs; [
      rustup
      git
    ];

    # Create launchd service for exo
    launchd.user.agents.exo = mkIf cfg.autoStart {
      # Service description
      serviceConfig = {
        Label = "com.exo.service";
        ProgramArguments = [
          "/bin/bash"
          "-c"
          ''
            # Source shell environment to get PATH
            source ~/.zshrc 2>/dev/null || true

            # Ensure we have the right PATH for Homebrew
            export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

            # Change to exo directory
            cd "${cfg.dataDir}" || exit 1

            # Check if exo is cloned
            if [ ! -f "pyproject.toml" ]; then
              echo "exo not found at ${cfg.dataDir}"
              echo "Please clone exo first:"
              echo "  git clone https://github.com/exo-explore/exo ${cfg.dataDir}"
              exit 1
            fi

            # Ensure dashboard is built
            if [ ! -d "dashboard/build" ]; then
              echo "Building exo dashboard..."
              cd dashboard && npm install && npm run build && cd ..
            fi

            # Run exo
            exec uv run exo
          ''
        ];

        # Run at load (boot/login)
        RunAtLoad = true;

        # Keep alive - restart if it exits
        KeepAlive = true;

        # Working directory
        WorkingDirectory = cfg.dataDir;

        # Logging
        StandardOutPath = "/tmp/exo.log";
        StandardErrorPath = "/tmp/exo.error.log";

        # Environment variables
        EnvironmentVariables = {
          PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
          HOME = config.users.users.${cfg.user}.home;
        };
      };
    };

    # Create activation script to help with initial setup
    system.activationScripts.exo-setup.text = ''
      echo "exo service configuration applied."
      echo ""
      echo "To complete exo setup:"
      echo "  1. Clone exo repository (if not already done):"
      echo "     git clone https://github.com/exo-explore/exo ~/Projects/exo"
      echo ""
      echo "  2. Build the dashboard:"
      echo "     cd ~/Projects/exo/dashboard && npm install && npm run build"
      echo ""
      echo "  3. Install Rust nightly (if not already done):"
      echo "     rustup toolchain install nightly"
      echo ""
      echo "  4. The exo service will start automatically on next login."
      echo "     Or start manually: launchctl load ~/Library/LaunchAgents/com.exo.service.plist"
      echo ""
      echo "  5. Access exo at: http://localhost:${toString cfg.port}"
    '';
  };
}
