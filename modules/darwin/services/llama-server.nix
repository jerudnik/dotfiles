# llama-server - Local LLM inference via llama.cpp
# https://github.com/ggerganov/llama.cpp
{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.services.llama-server;
in
{
  options.services.llama-server = {
    enable = mkEnableOption "llama-server LLM inference service";

    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Host to bind llama-server (0.0.0.0 for network access)";
    };

    port = mkOption {
      type = types.port;
      default = 11434;
      description = "Port for llama-server API (11434 = Ollama compatibility)";
    };

    model = mkOption {
      type = types.str;
      default = "";
      description = "Model to load (HuggingFace repo or local path). Empty = no default model.";
    };

    ctxSize = mkOption {
      type = types.int;
      default = 0;
      description = "Context window size (0 = from model metadata)";
    };

    gpuLayers = mkOption {
      type = types.str;
      default = "auto";
      description = "GPU layers to offload (auto/all/N)";
    };

    parallel = mkOption {
      type = types.int;
      default = -1;
      description = "Concurrent request slots (-1 = auto)";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional arguments for llama-server";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.llama-cpp ];

    launchd.user.agents.llama-server = {
      serviceConfig = {
        Label = "com.llama.server";
        ProgramArguments = [
          "${pkgs.llama-cpp}/bin/llama-server"
          "--host"
          cfg.host
          "--port"
          (toString cfg.port)
        ]
        ++ lib.optionals (cfg.model != "") [
          "--hf"
          cfg.model
        ]
        ++ lib.optionals (cfg.ctxSize != 0) [
          "--ctx-size"
          (toString cfg.ctxSize)
        ]
        ++ lib.optionals (cfg.gpuLayers != "auto") [
          "--n-gpu-layers"
          cfg.gpuLayers
        ]
        ++ lib.optionals (cfg.parallel != -1) [
          "--parallel"
          (toString cfg.parallel)
        ]
        ++ cfg.extraArgs;

        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/llama-server.log";
        StandardErrorPath = "/tmp/llama-server.error.log";
      };
    };

    system.activationScripts.llama-server-setup.text = ''
      echo ""
      echo "════════════════════════════════════════════════════════════"
      echo "  llama-server Configuration Applied"
      echo "════════════════════════════════════════════════════════════"
      echo ""
      echo "  API Endpoint: http://localhost:${toString cfg.port}"
      echo "  Network Access: http://$(hostname):${toString cfg.port}"
      echo ""
      echo "  Quick Start (no default model configured):"
      echo "    llama-server --hf <repo>:<quant> --port ${toString cfg.port}"
      echo ""
      echo "  Logs: /tmp/llama-server.log"
      echo "════════════════════════════════════════════════════════════"
    '';
  };
}
