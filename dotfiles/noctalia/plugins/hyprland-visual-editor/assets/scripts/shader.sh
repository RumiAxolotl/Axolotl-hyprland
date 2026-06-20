#!/bin/bash

# --- SELF-CONTAINED PATHS ---
PLUGIN_DIR="$HOME/.config/noctalia/plugins/hyprland-visual-editor"
FRAGMENTS_DIR="$PLUGIN_DIR/assets/fragments"
SCRIPTS_DIR="$PLUGIN_DIR/assets/scripts"
SHADERS_DIR="$PLUGIN_DIR/assets/shaders"

# Ensure the internal fragments folder exists
mkdir -p "$FRAGMENTS_DIR"

# The preset is the filename (e.g., 02_monocromo.frag)
PRESET=$1

# --- SHADER LOGIC ---

# Case 1: Disable (None, empty, or 'clean' shader)
if [ "$PRESET" == "none" ] || [ -z "$PRESET" ] || [ "$PRESET" == "00_limpio.frag" ]; then

    # Delete the internal fragment
    rm -f "$FRAGMENTS_DIR/shader.conf"

    # PRO TIP: Force Hyprland to clear the shader in memory immediately
    # so the change is instant upon clicking.
    hyprctl keyword decoration:screen_shader ""

    echo "Syncing: Shaders disabled."

# Case 2: Enable a specific filter
else
    SHADER_PATH="$SHADERS_DIR/$PRESET"

    # Security check in the internal path
    if [ ! -f "$SHADER_PATH" ]; then
        notify-send "HVE Error" "Shader not found: $PRESET" -i dialog-error
        exit 1
    fi

    # Write the fragment in the new internal path
    echo "decoration {
    screen_shader = $SHADER_PATH
}" > "$FRAGMENTS_DIR/shader.conf"

    echo "Syncing: Applying shader $PRESET"
fi

# --- CALL THE MASTER ASSEMBLER ---
if [ -f "$SCRIPTS_DIR/assemble.sh" ]; then
    bash "$SCRIPTS_DIR/assemble.sh"
else
    # Fallback in case assemble.sh is missing for some reason
    hyprctl reload
fi