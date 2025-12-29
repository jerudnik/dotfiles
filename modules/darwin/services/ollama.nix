# Ollama - Local LLM inference server
# https://ollama.ai
{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.services.ollama;
in
{
  options.services.ollama = {
    enable = mkEnableOption "Ollama LLM inference service";

    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Host to bind Ollama server (0.0.0.0 for network access)";
    };

    port = mkOption {
      type = types.port;
      default = 11434;
      description = "Port for Ollama API";
    };

    origins = mkOption {
      type = types.str;
      default = "*";
      description = "Allowed origins for CORS (needed for Open WebUI)";
    };
  };

  config = mkIf cfg.enable {
    # Install Ollama via Homebrew cask
    homebrew.casks = [ "ollama" ];

    # Create launchd service for Ollama
    launchd.user.agents.ollama = {
      serviceConfig = {
        Label = "com.ollama.server";
        ProgramArguments = [
          "/Applications/Ollama.app/Contents/Resources/ollama"
          "serve"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/ollama.log";
        StandardErrorPath = "/tmp/ollama.error.log";
        EnvironmentVariables = {
          OLLAMA_HOST = "${cfg.host}:${toString cfg.port}";
          OLLAMA_ORIGINS = cfg.origins;
        };
      };
    };

    # Setup instructions
    system.activationScripts.ollama-setup.text = ''
      echo ""
      echo "════════════════════════════════════════════════════════════"
      echo "  Ollama Configuration Applied"
      echo "════════════════════════════════════════════════════════════"
      echo ""
      echo "  API Endpoint: http://localhost:${toString cfg.port}"
      echo "  Network Access: http://\$(hostname):${toString cfg.port}"
      echo ""
      echo "  Quick Start:"
      echo "    ollama pull qwen3-coder:30b   # Primary coding model (~20GB)"
      echo "    ollama pull deepseek-r1:70b   # Reasoning model (~45GB)"
      echo "    ollama list                   # Show downloaded models"
      echo "    ollama run qwen3-coder:30b    # Interactive chat"
      echo ""
      echo "  Recommended Models for 256GB RAM (OpenCode Subagents):"
      echo "    qwen3-coder:30b      - Fast code generation (20GB) - @local-builder"
      echo "    devstral:123b        - Deep code analysis (80GB) - @local-analyst"
      echo "    deepseek-r1:70b      - Reasoning/planning (45GB) - @local-reasoner"
      echo ""
      echo "  Additional Models:"
      echo "    nemotron-3-nano:30b  - General purpose (20GB)"
      echo "    nomic-embed-text     - Embeddings (275MB)"
      echo ""
      echo "  Logs: /tmp/ollama.log"
      echo "════════════════════════════════════════════════════════════"
    '';
  };
}
