#!/bin/bash
# ============================================================================
# MacBook Air (inOneEar) Setup Script
# ============================================================================
# This script bootstraps the MacBook Air with the nix-darwin configuration
# from the dotfiles repository. It's designed to be run interactively with
# step-by-step prompts.
#
# Prerequisites:
#   - Determinate Nix installed
#   - Yubikey with age identity and SSH resident key configured
#
# Usage:
#   curl -fsSL <gist-url>/setup-macbook-air.sh -o setup.sh
#   chmod +x setup.sh && ./setup.sh
#
# ============================================================================

set -e  # Abort on first error

# ============================================
# Colors and Helpers
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1" >&2
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

step_header() {
    local step_num=$1
    local total_steps=$2
    local title=$3
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  Step ${step_num}/${total_steps}: ${title}${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

prompt_continue() {
    echo ""
    echo -e "${YELLOW}Press Enter to continue (or Ctrl+C to abort)...${NC}"
    read -r
}

prompt_yes_no() {
    local prompt=$1
    local response
    echo -e "${YELLOW}${prompt} [y/N]${NC} "
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

# ============================================
# Configuration
# ============================================

TOTAL_STEPS=7
REPO_URL="https://github.com/jerudnik/dotfiles.git"
DOTFILES_DIR="$HOME/Projects/dotfiles"
AGE_DIR="$HOME/.config/sops/age"
AGE_IDENTITY="$AGE_DIR/yubikey-identity.txt"
SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519_sk"

# ============================================
# Step 1: Pre-flight Checks
# ============================================

step_header 1 $TOTAL_STEPS "Pre-flight Checks"

echo "This step will verify:"
echo "  • You're running macOS"
echo "  • Determinate Nix is installed"
echo "  • Your Yubikey is plugged in"
echo ""

# Check macOS
if [[ "$(uname)" != "Darwin" ]]; then
    error "This script is designed for macOS only."
    exit 1
fi
success "Running on macOS"

# Check Nix
if ! command -v nix &> /dev/null; then
    error "Nix is not installed. Please install Determinate Nix first:"
    echo "  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
    exit 1
fi
success "Nix is installed"

# Check Yubikey
if ! system_profiler SPUSBDataType 2>/dev/null | grep -qi "yubikey"; then
    error "No Yubikey detected. Please plug in your Yubikey and try again."
    exit 1
fi
success "Yubikey detected"

prompt_continue

# ============================================
# Step 2: Install age-plugin-yubikey
# ============================================

step_header 2 $TOTAL_STEPS "Install age-plugin-yubikey"

echo "This step will:"
echo "  • Install age-plugin-yubikey via Nix"
echo "  • This is a temporary install; it will be managed by the config after apply"
echo ""

if command -v age-plugin-yubikey &> /dev/null; then
    success "age-plugin-yubikey is already installed"
else
    info "Installing age-plugin-yubikey..."
    nix profile install nixpkgs#age-plugin-yubikey
    
    # Verify installation
    if command -v age-plugin-yubikey &> /dev/null; then
        success "age-plugin-yubikey installed successfully"
    else
        error "Failed to install age-plugin-yubikey"
        exit 1
    fi
fi

prompt_continue

# ============================================
# Step 3: Setup Age Identity for sops-nix
# ============================================

step_header 3 $TOTAL_STEPS "Setup Age Identity for sops-nix"

echo "This step will:"
echo "  • Create ~/.config/sops/age/ directory"
echo "  • Extract your Yubikey's age identity"
echo ""
warn "Your Yubikey will blink - touch it when prompted!"
echo ""

if [[ -f "$AGE_IDENTITY" ]]; then
    warn "Age identity file already exists: $AGE_IDENTITY"
    if prompt_yes_no "Overwrite existing identity file?"; then
        rm -f "$AGE_IDENTITY"
    else
        success "Keeping existing age identity"
        prompt_continue
        # Skip to next step
        SKIP_AGE_SETUP=true
    fi
fi

if [[ "${SKIP_AGE_SETUP:-}" != "true" ]]; then
    # Create directory
    mkdir -p "$AGE_DIR"
    success "Created $AGE_DIR"
    
    # Extract identity
    info "Extracting age identity from Yubikey..."
    info "Touch your Yubikey when it blinks!"
    echo ""
    
    if age-plugin-yubikey --identity > "$AGE_IDENTITY"; then
        success "Age identity extracted to $AGE_IDENTITY"
    else
        error "Failed to extract age identity"
        exit 1
    fi
    
    prompt_continue
fi

# ============================================
# Step 4: Extract SSH FIDO2 Key from Yubikey
# ============================================

step_header 4 $TOTAL_STEPS "Extract SSH FIDO2 Key from Yubikey"

echo "This step will:"
echo "  • Create ~/.ssh/ directory if needed"
echo "  • Extract resident SSH keys from your Yubikey"
echo ""
warn "Your Yubikey will blink - touch it when prompted!"
echo ""

if [[ -f "$SSH_KEY" ]]; then
    warn "SSH key already exists: $SSH_KEY"
    if prompt_yes_no "Overwrite existing SSH key?"; then
        rm -f "$SSH_KEY" "${SSH_KEY}.pub"
    else
        success "Keeping existing SSH key"
        prompt_continue
        SKIP_SSH_SETUP=true
    fi
fi

if [[ "${SKIP_SSH_SETUP:-}" != "true" ]]; then
    # Create directory
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    success "Created $SSH_DIR"
    
    # Extract SSH key
    info "Extracting SSH key from Yubikey..."
    info "Touch your Yubikey when it blinks!"
    echo ""
    
    # ssh-keygen -K extracts to current directory, so we cd first
    pushd "$SSH_DIR" > /dev/null
    if ssh-keygen -K; then
        success "SSH key extracted"
    else
        error "Failed to extract SSH key"
        popd > /dev/null
        exit 1
    fi
    popd > /dev/null
    
    # Set permissions
    if [[ -f "$SSH_KEY" ]]; then
        chmod 600 "$SSH_KEY"
        chmod 644 "${SSH_KEY}.pub"
        success "SSH key permissions set"
    else
        warn "Expected key at $SSH_KEY but not found"
        info "Listing extracted keys:"
        ls -la "$SSH_DIR"/*.pub 2>/dev/null || true
    fi
    
    prompt_continue
fi

# ============================================
# Step 5: Clone Dotfiles Repository
# ============================================

step_header 5 $TOTAL_STEPS "Clone Dotfiles Repository"

echo "This step will:"
echo "  • Create ~/Projects/ directory if needed"
echo "  • Clone the dotfiles repository from GitHub"
echo ""

if [[ -d "$DOTFILES_DIR" ]]; then
    warn "Dotfiles directory already exists: $DOTFILES_DIR"
    if prompt_yes_no "Remove and re-clone?"; then
        info "Removing existing dotfiles directory..."
        rm -rf "$DOTFILES_DIR"
    else
        info "Keeping existing directory, pulling latest changes..."
        pushd "$DOTFILES_DIR" > /dev/null
        git pull
        popd > /dev/null
        success "Updated dotfiles repository"
        prompt_continue
        SKIP_CLONE=true
    fi
fi

if [[ "${SKIP_CLONE:-}" != "true" ]]; then
    # Create Projects directory
    mkdir -p "$HOME/Projects"
    success "Created ~/Projects/"
    
    # Clone repository
    info "Cloning dotfiles repository..."
    if git clone "$REPO_URL" "$DOTFILES_DIR"; then
        success "Repository cloned to $DOTFILES_DIR"
    else
        error "Failed to clone repository"
        exit 1
    fi
    
    prompt_continue
fi

# ============================================
# Step 6: Apply nix-darwin Configuration
# ============================================

step_header 6 $TOTAL_STEPS "Apply nix-darwin Configuration"

echo "This step will:"
echo "  • Apply the inOneEar (MacBook Air) configuration"
echo "  • Install all packages and configure the system"
echo "  • Set up shell, terminal, editors, and more"
echo ""
warn "You will be prompted for your sudo password."
warn "Your Yubikey may blink during secrets decryption - touch it!"
echo ""

cd "$DOTFILES_DIR"
info "Changed to $DOTFILES_DIR"

prompt_continue

info "Running darwin-rebuild switch..."
echo ""

if sudo darwin-rebuild switch --flake .#inOneEar; then
    success "nix-darwin configuration applied successfully!"
else
    error "darwin-rebuild failed"
    exit 1
fi

prompt_continue

# ============================================
# Step 7: Post-Setup Verification
# ============================================

step_header 7 $TOTAL_STEPS "Post-Setup Verification"

echo "Verifying the setup..."
echo ""

# Check secrets
if [[ -d "/run/secrets" ]]; then
    success "sops-nix secrets are available at /run/secrets"
else
    warn "Secrets directory not found - this may be normal on first boot"
fi

# Check SSH config
if [[ -f "$HOME/.ssh/config" ]]; then
    success "SSH config installed"
else
    warn "SSH config not found"
fi

# Check shell
if command -v zsh &> /dev/null; then
    success "zsh is available"
else
    warn "zsh not found"
fi

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  Setup Complete!${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Next steps:"
echo "  1. Open a new terminal (or run: exec zsh)"
echo "  2. Enter the dev shell: cd ~/Projects/dotfiles && nix develop"
echo "  3. Future applies: just run 'apply' from the dev shell"
echo ""
echo "To connect to Mac Studio:"
echo "  ssh seriousCallersOnly"
echo ""
echo "Enjoy your new setup! 🎉"
