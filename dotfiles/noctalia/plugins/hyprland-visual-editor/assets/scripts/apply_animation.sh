#!/bin/bash

# --- PATHS ---
PLUGIN_DIR="$HOME/.config/noctalia/plugins/hyprland-visual-editor"
PRESETS_DIR="$PLUGIN_DIR/assets/animations"   # Presets folder
FRAGMENTS_DIR="$PLUGIN_DIR/assets/fragments"
SCRIPTS_DIR="$PLUGIN_DIR/assets/scripts"

mkdir -p "$FRAGMENTS_DIR"
PRESET_NAME=$1

# 1. SHUTDOWN LOGIC
if [ "$PRESET_NAME" == "none" ] || [ -z "$PRESET_NAME" ]; then
    rm -f "$FRAGMENTS_DIR/animation.conf"
    echo "Animations disabled."
else
    # 2. DYNAMIC LOADING
    TARGET_FILE="$PRESETS_DIR/$PRESET_NAME"

    if [ -f "$TARGET_FILE" ]; then
        cat "$TARGET_FILE" > "$FRAGMENTS_DIR/animation.conf"
        echo "Animation applied: $PRESET_NAME"
    else
        # If it doesn't exist, we don't apply anything to avoid breaking Hyprland
        rm -f "$FRAGMENTS_DIR/animation.conf"
        echo "Error: Animation $PRESET_NAME not found."
    fi
fi

# 3. ASSEMBLY
bash "$SCRIPTS_DIR/assemble.sh"