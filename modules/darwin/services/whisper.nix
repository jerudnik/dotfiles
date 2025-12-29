# Whisper.cpp - Local speech-to-text transcription
# https://github.com/ggerganov/whisper.cpp
{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.services.whisper;
  modelsDir = "${config.users.users.${config.system.primaryUser}.home}/.whisper/models";
in
{
  options.services.whisper = {
    enable = mkEnableOption "Whisper.cpp transcription";

    model = mkOption {
      type = types.enum [
        "base"
        "small"
        "medium"
        "large-v3"
      ];
      default = "large-v3";
      description = "Whisper model size to use";
    };
  };

  config = mkIf cfg.enable {
    # Install whisper.cpp via Homebrew
    homebrew.brews = [ "whisper-cpp" ];

    # Install ffmpeg for audio conversion
    environment.systemPackages = with pkgs; [ ffmpeg ];

    # Setup instructions
    system.activationScripts.whisper-setup.text = ''
      echo ""
      echo "════════════════════════════════════════════════════════════"
      echo "  Whisper.cpp Configuration Applied"
      echo "════════════════════════════════════════════════════════════"
      echo ""
      echo "  Download Model (${cfg.model}):"
      echo "    mkdir -p ${modelsDir}"
      echo "    cd ${modelsDir}"
      echo "    whisper-cpp-download-ggml-model ${cfg.model}"
      echo ""
      echo "  Transcribe Audio:"
      echo "    whisper-cpp -m ${modelsDir}/ggml-${cfg.model}.bin -f audio.wav"
      echo ""
      echo "  Options:"
      echo "    -l auto        # Auto-detect language"
      echo "    -otxt          # Output as plain text"
      echo "    -osrt          # Output as SRT subtitles"
      echo "    -ovtt          # Output as VTT subtitles"
      echo "    -ojson         # Output as JSON"
      echo ""
      echo "  Convert audio to compatible format:"
      echo "    ffmpeg -i input.mp3 -ar 16000 -ac 1 -c:a pcm_s16le output.wav"
      echo "════════════════════════════════════════════════════════════"
    '';
  };
}
