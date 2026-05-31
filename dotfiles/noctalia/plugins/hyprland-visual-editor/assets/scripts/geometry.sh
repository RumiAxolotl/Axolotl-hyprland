#!/bin/bash

# geometry.sh - Controls only physical size (Encapsulated)

# --- SELF-CONTAINED PATHS ---
PLUGIN_DIR="$HOME/.config/noctalia/plugins/hyprland-visual-editor"
FRAGMENTS_DIR="$PLUGIN_DIR/assets/fragments"
SCRIPTS_DIR="$PLUGIN_DIR/assets/scripts"

# Ensure the internal folder exists
mkdir -p "$FRAGMENTS_DIR"

SIZE=$1

# Basic validation
if [ -z "$SIZE" ]; then
    SIZE=2
fi

# 1. INTERNAL FRAGMENT GENERATION
# Keep the FIX of not using 'no_border_on_floating'
echo "general {
    border_size = $SIZE
}" > "$FRAGMENTS_DIR/geometry.conf"

# 2. RECONSTRUCTION WITH INTERNAL ASSEMBLER
if [ -f "$SCRIPTS_DIR/assemble.sh" ]; then
    bash "$SCRIPTS_DIR/assemble.sh"
else
    echo "Error: Assembler script not found in $SCRIPTS_DIR"
    exit 1
fi