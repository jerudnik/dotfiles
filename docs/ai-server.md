# Mac Studio AI Inference Server

This document describes the AI inference server setup on the Mac Studio (M3 Ultra, 256GB).

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Mac Studio                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   Ollama    │  │ Whisper.cpp │  │   OrbStack              │  │
│  │  :11434     │  │  (batch)    │  │  ┌─────────────────┐    │  │
│  └─────────────┘  └─────────────┘  │  │   Open WebUI    │    │  │
│                                    │  │   :3000         │    │  │
│                                    │  └─────────────────┘    │  │
│                                    │  ┌─────────────────┐    │  │
│                                    │  │   Portainer     │    │  │
│                                    │  │   :9000         │    │  │
│                                    └──┴─────────────────┴────┘  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    Tailscale (100.x.y.z)                 │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Services

### Ollama (LLM Inference)

**Port:** 11434
**API:** OpenAI-compatible at `http://<tailscale-ip>:11434/v1`

#### Recommended Models

| Model | Size | Use Case |
|-------|------|----------|
| `llama3.1:70b` | ~40GB | General purpose, excellent quality |
| `qwen2.5:72b` | ~45GB | Strong coding and math |
| `deepseek-coder-v2:16b` | ~9GB | Fast code generation |
| `nomic-embed-text` | ~275MB | Text embeddings |
| `mxbai-embed-large` | ~670MB | Higher quality embeddings |

#### Commands

```bash
# Download models
ollama pull llama3.1:70b
ollama pull nomic-embed-text

# List models
ollama list

# Interactive chat
ollama run llama3.1:70b

# API usage (OpenAI-compatible)
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3.1:70b",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'

# Native Ollama API
curl http://localhost:11434/api/generate \
  -d '{"model": "llama3.1:70b", "prompt": "Hello!"}'
```

#### Logs

```bash
tail -f /tmp/ollama.log
tail -f /tmp/ollama.error.log
```

### Open WebUI (Chat Interface)

**Port:** 3000
**URL:** `http://<tailscale-ip>:3000`

#### Setup

```bash
# Start Open WebUI with Docker (via OrbStack)
docker run -d \
  --name open-webui \
  -p 3000:8080 \
  -v open-webui:/app/backend/data \
  -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
  -e WEBUI_AUTH=false \
  --restart unless-stopped \
  ghcr.io/open-webui/open-webui:main
```

#### Features

- Chat with any Ollama model
- Conversation history
- Multiple model switching
- Document upload for RAG
- Model parameter tuning

#### Management

```bash
# View logs
docker logs -f open-webui

# Restart
docker restart open-webui

# Stop
docker stop open-webui

# Remove (keeps data volume)
docker rm open-webui
```

### Whisper.cpp (Transcription)

**Model:** large-v3 (best quality)

#### Setup

```bash
# Download model
mkdir -p ~/.whisper/models
cd ~/.whisper/models
whisper-cpp-download-ggml-model large-v3
```

#### Usage

```bash
# Convert audio to compatible format (16kHz mono WAV)
ffmpeg -i input.mp3 -ar 16000 -ac 1 -c:a pcm_s16le output.wav

# Transcribe
whisper-cpp -m ~/.whisper/models/ggml-large-v3.bin -f output.wav

# Output formats
whisper-cpp -m ~/.whisper/models/ggml-large-v3.bin -f audio.wav -otxt   # Plain text
whisper-cpp -m ~/.whisper/models/ggml-large-v3.bin -f audio.wav -osrt   # SRT subtitles
whisper-cpp -m ~/.whisper/models/ggml-large-v3.bin -f audio.wav -ovtt   # VTT subtitles
whisper-cpp -m ~/.whisper/models/ggml-large-v3.bin -f audio.wav -ojson  # JSON

# Auto-detect language
whisper-cpp -m ~/.whisper/models/ggml-large-v3.bin -f audio.wav -l auto
```

### Portainer (Container Management)

**Port:** 9000
**URL:** `http://<tailscale-ip>:9000`

#### Setup

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

### Tailscale (VPN)

All services are accessible only via Tailscale mesh VPN.

```bash
# Get your Tailscale IP
tailscale ip -4

# Check status
tailscale status

# List all devices
tailscale status --peers
```

## Remote Access

From any device on your Tailscale network:

```bash
# Get the Mac Studio's Tailscale IP (run on Mac Studio)
tailscale ip -4  # e.g., 100.x.y.z

# From remote machine, access services:
curl http://100.x.y.z:11434/v1/models  # Ollama API
open http://100.x.y.z:3000              # Open WebUI
open http://100.x.y.z:9000              # Portainer
```

### Using Ollama from Remote Machines

Set the Ollama host on your laptop/other machines:

```bash
# Temporary (current session)
export OLLAMA_HOST=http://100.x.y.z:11434

# Then use ollama commands normally
ollama list
ollama run llama3.1:70b
```

Or configure applications to use the remote endpoint directly.

## Maintenance

### Service Management

```bash
# Ollama (launchd)
launchctl list | grep ollama
launchctl stop com.ollama.server
launchctl start com.ollama.server

# View service status
launchctl print gui/$(id -u)/com.ollama.server
```

### Model Storage

Models are stored in `~/.ollama/models`. With 70B+ models, expect 40-50GB per model.

```bash
# Check storage usage
du -sh ~/.ollama/models/*

# Total Ollama storage
du -sh ~/.ollama

# Remove a model
ollama rm model-name
```

### Updates

```bash
# Update system configuration
cd ~/Projects/dotfiles
apply  # or: sudo darwin-rebuild switch --flake .

# Update Ollama (via Homebrew)
brew upgrade --cask ollama

# Update Open WebUI container
docker pull ghcr.io/open-webui/open-webui:main
docker stop open-webui
docker rm open-webui
# Re-run the docker run command above
```

## Troubleshooting

### Ollama not starting

```bash
# Check if running
pgrep -l ollama

# Check logs
cat /tmp/ollama.error.log

# Manual start for debugging
/Applications/Ollama.app/Contents/Resources/ollama serve

# Check port binding
lsof -i :11434
```

### Can't connect from remote machine

1. Verify Tailscale is connected on both machines:
   ```bash
   tailscale status
   ```

2. Verify Ollama is binding to 0.0.0.0:
   ```bash
   lsof -i :11434
   # Should show *:11434, not 127.0.0.1:11434
   ```

3. Test local connectivity first:
   ```bash
   curl http://localhost:11434/api/tags
   ```

4. Check macOS firewall isn't blocking connections

### Model too slow

With 256GB unified memory, 70B models should run well. If slow:

```bash
# Check memory pressure
btop

# Check if model is fully loaded
# First request is slow (loading), subsequent should be fast

# Try smaller quantization for faster inference
ollama pull llama3.1:70b-q4_K_M  # 4-bit quantized, smaller and faster
```

### Docker/OrbStack issues

```bash
# Restart OrbStack
osascript -e 'quit app "OrbStack"'
open -a OrbStack

# Check Docker status
docker info

# View all containers
docker ps -a
```

## Performance Tips

### Memory Management

- 70B models in fp16 use ~140GB, leaving room for other tasks
- 70B models in Q4 quantization use ~40GB
- Can run multiple smaller models simultaneously
- Ollama automatically unloads unused models after timeout

### Optimal Models for This Hardware

| RAM Budget | Recommended Model | Quality |
|------------|-------------------|---------|
| 40GB | `llama3.1:70b-q4_K_M` | Great |
| 80GB | `llama3.1:70b` (fp16) | Excellent |
| 130GB | `deepseek-coder-v2:236b-q4_K_M` | Best for code |
| 150GB+ | `qwen2.5:72b` + embeddings | Multi-model |

### Network Performance

For large context windows and fast responses over Tailscale:
- Tailscale uses WireGuard, which is efficient
- Local network will always be faster than VPN
- Consider SSH tunneling for very large file transfers
