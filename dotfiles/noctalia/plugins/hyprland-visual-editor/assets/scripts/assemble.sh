#!/bin/bash

# --- SELF-CONTAINED PATH CONFIGURATION ---
PLUGIN_DIR="$HOME/.config/noctalia/plugins/hyprland-visual-editor"
FRAGMENTS_DIR="$PLUGIN_DIR/assets/fragments"

# [CHANGE 1] Define the new safe path outside the plugin
HVE_SAFE_DIR="$HOME/.cache/noctalia/HVE"

# [CHANGE 2] Point the temporary and final files to the new path
FINAL_FILE="$HVE_SAFE_DIR/overlay.conf"
TEMP_FILE="$HVE_SAFE_DIR/overlay.tmp"

# Official Noctalia colors path
COLORS_FILE="$HOME/.config/hypr/noctalia/noctalia-colors.conf"

# Ensure the fragments folder exists within the plugin
mkdir -p "$FRAGMENTS_DIR"

# [CHANGE 3] Ensure the safe refuge exists before writing to it
mkdir -p "$HVE_SAFE_DIR"

# 1. TEMPORARY FILE CREATION
echo "# HYPRLAND VISUAL EDITOR - MASTER OVERLAY" > "$TEMP_FILE"
echo "# Automatically generated on: $(date)" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

# --- [CRITICAL: COLORS FIRST] ---
# Load variables ($primary, $secondary...) before anything else.
if [ -f "$COLORS_FILE" ]; then
    echo "# [SYSTEM: COLORS]" >> "$TEMP_FILE"
    echo "source = $COLORS_FILE" >> "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
else
    echo "# [WARNING] Colors file not found: $COLORS_FILE" >> "$TEMP_FILE"
fi

# --- [CRITICAL FIX: IMMORTAL CURVE] ---
# Inject the linear curve GLOBALLY here.
echo "bezier = linear, 0, 0, 1, 1" >> "$TEMP_FILE"
echo "# ----------------------------------------------------" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"


# 2. ORDERED ASSEMBLY (POWER HIERARCHY)

# -- A) ANIMATIONS --
if [ -f "$FRAGMENTS_DIR/animation.conf" ]; then
    echo "# [MODULE: ANIMATIONS]" >> "$TEMP_FILE"
    cat "$FRAGMENTS_DIR/animation.conf" >> "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
fi

# -- B) BORDERS (Style and Color) --
if [ -f "$FRAGMENTS_DIR/border.conf" ]; then
    echo "# [MODULE: BORDERS]" >> "$TEMP_FILE"
    cat "$FRAGMENTS_DIR/border.conf" >> "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
fi

# -- C) SHADERS --
if [ -f "$FRAGMENTS_DIR/shader.conf" ]; then
    echo "# [MODULE: SHADERS]" >> "$TEMP_FILE"
    cat "$FRAGMENTS_DIR/shader.conf" >> "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
fi

# -- D) GEOMETRY (The Supreme Boss) --
# We put this AT THE END so the slider always dictates the size,
# overriding any errors coming from previous borders.
if [ -f "$FRAGMENTS_DIR/geometry.conf" ]; then
    echo "# [MODULE: GEOMETRY]" >> "$TEMP_FILE"
    cat "$FRAGMENTS_DIR/geometry.conf" >> "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
fi

# 3. MASTER MOVE
mv "$TEMP_FILE" "$FINAL_FILE"

# 4. APPLICATION
if pgrep -x "Hyprland" > /dev/null; then
    # Use reload to apply changes without restarting the session
    hyprctl reload
fi