#!/usr/bin/env bash
set -euo pipefail

log() { printf "[setup] %s\n" "$*"; }
warn() { printf "[setup][WARN] %s\n" "$*"; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    warn "Missing command: $1"
    return 1
  fi
}

primary_user=${SUDO_USER:-$USER}
ssh_key="$HOME/.ssh/id_ed25519_sk.pub"
sops_age_key="$HOME/.config/sops/age/yubikey-identity.txt"

log "Checking prerequisites for dotfiles apply"

ok=true

if [ ! -f "$ssh_key" ]; then
  warn "No FIDO2 SSH key at $ssh_key"
  warn "Generate with: ssh-keygen -t ed25519-sk -C '$primary_user'"
  ok=false
fi

if [ ! -f "$sops_age_key" ]; then
  warn "No SOPS age key at $sops_age_key"
  warn "Follow docs/ai-tools-setup.md to create/export the Yubikey age key"
  ok=false
fi

if ! require_cmd ykman; then ok=false; fi
if ! require_cmd sops; then ok=false; fi

if [ "$ok" = false ]; then
  warn "Prerequisites missing. Fix above items, then rerun scripts/setup.sh"
  exit 1
fi

log "All prerequisites satisfied. Running apply..."
exec apply
