#!/bin/bash
# hve_watchdog.sh - Monitors if the plugin is still installed and cleans up if not

# 1. Define paths
PLUGIN_DIR="$HOME/.config/noctalia/plugins/hyprland-visual-editor"
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
HVE_SAFE_DIR="$HOME/.cache/noctalia/HVE"

# 2. Check if the original plugin folder has been deleted by the Shell
if [ ! -d "$PLUGIN_DIR" ]; then

    # Block deletion: Safely remove everything from START to END markers
    sed -i '/# >>> HYPRLAND VISUAL EDITOR START <<</,/# >>> HYPRLAND VISUAL EDITOR END <<</d' "$HYPR_CONF"

    # Remove the safe fallback directory and this script itself
    rm -rf "$HVE_SAFE_DIR"
fi