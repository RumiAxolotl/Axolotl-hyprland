#!/bin/bash

# --- PATHS ---
PLUGIN_DIR="$HOME/.config/noctalia/plugins/hyprland-visual-editor"
PRESETS_DIR="$PLUGIN_DIR/assets/borders"      # Where the user saves their .conf files
FRAGMENTS_DIR="$PLUGIN_DIR/assets/fragments"  # Where the temporary fragment is generated
SCRIPTS_DIR="$PLUGIN_DIR/assets/scripts"

mkdir -p "$FRAGMENTS_DIR"
PRESET_NAME=$1

# 1. SHUTDOWN LOGIC (None or empty)
if [ "$PRESET_NAME" == "none" ] || [ -z "$PRESET_NAME" ]; then
    rm -f "$FRAGMENTS_DIR/border.conf"
    echo "Border disabled."
else
    # 2. DYNAMIC LOADING
    # We look for the .conf file in the assets/borders/ folder
    TARGET_FILE="$PRESETS_DIR/$PRESET_NAME"

    if [ -f "$TARGET_FILE" ]; then
        # Copy the preset content to the fragment
        cat "$TARGET_FILE" > "$FRAGMENTS_DIR/border.conf"
        echo "Border preset applied: $PRESET_NAME"
    else
        # Security fallback: if the file doesn't exist, use the base color
        echo "general { col.active_border = \$primary }" > "$FRAGMENTS_DIR/border.conf"
        echo "Warning: Preset $PRESET_NAME not found."
    fi
fi

# 3. ASSEMBLY
bash "$SCRIPTS_DIR/assemble.sh"