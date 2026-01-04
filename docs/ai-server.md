# AI Inference Server (Mac Studio)

This document describes how the Mac Studio (M3 Ultra, 256GB) runs local AI services.

## Services (need-to-know)

- **Ollama** – LLM inference, API on `:11434`, exposed over Tailscale
- **Open WebUI** – UI on `:3000` (Docker via OrbStack)
- **Portainer** – Docker admin UI on `:9000` (optional)
- **Whisper.cpp** – Batch transcription, local models
- **Tailscale** – Required for remote access

## How Ollama Is Managed

- Configured via nix-darwin module `modules/darwin/services/ollama.nix`
- Installed as a launchd user service: `com.ollama.server`
- **Upgrades** happen with `apply` / `sudo darwin-rebuild switch --flake .`
- Service binds to `0.0.0.0:${port}` with CORS origins from module options

### Quick Commands

```bash
# Apply config (start/upgrade Ollama)
apply  # or: sudo darwin-rebuild switch --flake .

# Check status
launchctl list | grep ollama
launchctl print gui/$(id -u)/com.ollama.server

# Logs
tail -f /tmp/ollama.log
```

### Models

```bash
ollama pull llama3.1:70b
ollama pull nomic-embed-text
ollama list
ollama run llama3.1:70b
```

Models live in `~/.ollama/models`; 70B fp16 ~140GB, q4 ~40GB.

### Remote Use

On a client machine:

```bash
export OLLAMA_HOST=http://100.x.y.z:11434   # Tailscale IP of Mac Studio
ollama list
```

See `docs/ai-tools-setup.md` for client setup, secrets, and MCP integration that consumes this endpoint.

## Open WebUI (OrbStack/Docker)

```bash
docker run -d \
  --name open-webui \
  -p 3000:8080 \
  -v open-webui:/app/backend/data \
  -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
  -e WEBUI_AUTH=false \
  --restart unless-stopped \
  ghcr.io/open-webui/open-webui:main

# Logs / lifecycle
docker logs -f open-webui
docker restart open-webui
docker stop open-webui
docker rm open-webui  # keeps data volume
```

## Portainer (optional)

```bash
docker volume create portainer_data
docker run -d \
  --name portainer \
  -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  --restart unless-stopped \
  portainer/portainer-ce:latest
```

## Whisper.cpp (batch transcription)

```bash
mkdir -p ~/.whisper/models
whisper-cpp-download-ggml-model large-v3

# Convert and transcribe
ffmpeg -i input.mp3 -ar 16000 -ac 1 -c:a pcm_s16le output.wav
whisper-cpp -m ~/.whisper/models/ggml-large-v3.bin -f output.wav
```

## Troubleshooting

- **Ollama not starting**: `launchctl print gui/$(id -u)/com.ollama.server`; check `/tmp/ollama.error.log`
- **Remote access fails**: ensure Tailscale is up on both ends; verify `lsof -i :11434` shows `*:11434`
- **Disk usage**: `du -sh ~/.ollama` and `du -sh ~/.ollama/models/*`
- **Performance**: use quantized models (e.g., `llama3.1:70b-q4_K_M`) if latency is high

## Maintenance Checklist

- Use `apply` to upgrade Ollama; do **not** run `brew upgrade --cask ollama`
- Keep Tailscale logged in; services are reachable only via Tailscale
- Clean old models with `ollama rm <model>` if space is low
