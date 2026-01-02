#!/usr/bin/env bash
# theme-switch.sh - Theme switcher with notification UI
# Called by darkman on sunrise/sunset transitions

set -euo pipefail

TARGET_THEME="$1"
SKIP_FILE="$HOME/.cache/theme-switch-skip-$(date +%Y%m%d)"
CACHE_DIR="$HOME/.cache"
CONFIG_DIR="$HOME/.config/dotfiles"

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# Skip if user already opted out for today
if [[ -f "$SKIP_FILE" ]]; then
    exit 0
fi

# Determine the theme variant to use
case "$TARGET_THEME" in
    light)
        THEME_NAME="atelier-estuary-light"
        ;;
    dark)
        THEME_NAME="atelier-estuary"
        ;;
    *)
        echo "Unknown theme mode: $TARGET_THEME" >&2
        exit 1
        ;;
esac

# Function to run rebuild
do_rebuild() {
    local theme="$1"
    notify-send "Theme Switch" "Switching to $theme mode..." --urgency=normal

    if [[ -f "$CONFIG_DIR/apply" ]]; then
        "$CONFIG_DIR/apply" "$theme" 2>&1 | while read -r line; do
            notify-send "Theme Switch" "$line" --urgency=low
        done
        notify-send "Theme Switch" "$theme mode is now active" --urgency=normal
    else
        # Fallback: just regenerate home-manager
        home-manager switch --flake "$CONFIG_DIR#" 2>&1 | while read -r line; do
            notify-send "Theme Switch" "$line" --urgency=low
        done
        notify-send "Theme Switch" "$theme mode is now active" --urgency=normal
    fi
}

# Send notification with actions
notify-send "Theme Switch" \
    "Switching to $TARGET_THEME mode ($THEME_NAME) in 60 seconds..." \
    --action="now=Switch Now" \
    --action="defer=Defer 30m" \
    --action="skip=Skip Today" \
    --wait --timeout=60000

case "$?" in
    0|"now")
        do_rebuild "$THEME_NAME"
        ;;
    "defer")
        notify-send "Theme Switch" "Deferring for 30 minutes..." --urgency=low
        (sleep 1800 && "$0" "$TARGET_THEME") &
        ;;
    "skip"|*)
        touch "$SKIP_FILE"
        notify-send "Theme Switch" "Skipped for today" --urgency=low
        ;;
esac
