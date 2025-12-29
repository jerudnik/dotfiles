#!/usr/bin/env bash
# Helper script for managing Ollama models
# Usage: ./ollama-models.sh [command]

set -euo pipefail

RECOMMENDED_MODELS=(
    "llama3.1:70b"
    "qwen2.5:72b"
    "nomic-embed-text"
    "mxbai-embed-large"
)

CODING_MODELS=(
    "deepseek-coder-v2:16b"
    "qwen2.5-coder:32b"
)

show_help() {
    cat << 'EOF'
Ollama Model Manager

Commands:
  pull-recommended  Download recommended models for 256GB system
  pull-coding       Download coding-focused models
  list              List downloaded models
  storage           Show model storage usage
  running           Show currently loaded models
  help              Show this help message

Recommended models for 256GB unified memory:
  llama3.1:70b         - General purpose (40GB)
  qwen2.5:72b          - Strong coding/math (45GB)
  nomic-embed-text     - Fast embeddings (275MB)
  mxbai-embed-large    - Quality embeddings (670MB)

Coding models:
  deepseek-coder-v2:16b  - Fast code generation (9GB)
  qwen2.5-coder:32b      - Strong code model (20GB)
EOF
}

pull_models() {
    local models=("$@")
    for model in "${models[@]}"; do
        echo "Pulling $model..."
        ollama pull "$model"
        echo ""
    done
}

case "${1:-help}" in
    pull-recommended)
        echo "Pulling recommended models for 256GB system..."
        echo "This may take a while (100GB+ total download)..."
        echo ""
        pull_models "${RECOMMENDED_MODELS[@]}"
        echo "Done! Run 'ollama list' to see downloaded models."
        ;;
    pull-coding)
        echo "Pulling coding-focused models..."
        echo ""
        pull_models "${CODING_MODELS[@]}"
        echo "Done!"
        ;;
    list)
        ollama list
        ;;
    storage)
        echo "Model storage usage:"
        echo ""
        if [ -d ~/.ollama/models ]; then
            du -sh ~/.ollama/models/manifests/registry.ollama.ai/library/* 2>/dev/null | sort -h || echo "No models found"
            echo ""
            echo "Total Ollama storage:"
            du -sh ~/.ollama 2>/dev/null || echo "~/.ollama not found"
        else
            echo "No models downloaded yet (~/.ollama/models not found)"
        fi
        ;;
    running)
        echo "Currently loaded models:"
        ollama ps
        ;;
    help|--help|-h|*)
        show_help
        ;;
esac
