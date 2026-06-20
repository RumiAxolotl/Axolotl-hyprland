#!/bin/bash

# --- MAIN PATHS ---
PLUGIN_DIR="$HOME/.config/noctalia/plugins/hyprland-visual-editor"
FRAGMENTS_DIR="$PLUGIN_DIR/assets/fragments"

# 🌟 NEW SAFE PATH (The Refuge) 🌟
HVE_SAFE_DIR="$HOME/.cache/noctalia/HVE"
OVERLAY_FILE="$HVE_SAFE_DIR/overlay.conf" # The overlay now lives outside the plugin
WATCHDOG_FILE="$HVE_SAFE_DIR/hve_watchdog.sh"

# Keep the colors path
COLORS_FILE="$HOME/.config/hypr/noctalia/noctalia-colors.conf"
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

# Internal assembler path
ASSEMBLE_SCRIPT="$PLUGIN_DIR/assets/scripts/assemble.sh"

# --- HYPRLAND MARKERS ---
MARKER_START="# >>> HYPRLAND VISUAL EDITOR START <<<"
MARKER_END="# >>> HYPRLAND VISUAL EDITOR END <<<"

# --- CONTENT TO INJECT ---
LINE_WATCHDOG="exec-once = $WATCHDOG_FILE" # Watchdog injection
LINE_COLORS="source = $COLORS_FILE"
LINE_OVERLAY="source = $OVERLAY_FILE"

ACTION=$1

# --- CLEANUP FUNCTION ---
clean_hyprland_conf() {
    # 1. Delete the entire block between markers
    sed -i "/$MARKER_START/,/$MARKER_END/d" "$HYPR_CONF"

    # 2. Security cleanup in case old loose lines remained
    sed -i "\|source = .*hyprland-visual-editor/overlay.conf|d" "$HYPR_CONF"
    sed -i "\|$LINE_OVERLAY|d" "$HYPR_CONF"
    sed -i "\|$LINE_COLORS|d" "$HYPR_CONF"

    # 3. Remove extra empty lines at the end
    sed -i '${/^$/d;}' "$HYPR_CONF"
}

# --- SETUP FUNCTION ---
setup_files() {
    echo "Preparing safe environment and watchdog..."

    # Create fragments folder and the new HVE refuge
    mkdir -p "$FRAGMENTS_DIR"
    mkdir -p "$HVE_SAFE_DIR"

    # Grant execution permissions to internal scripts
    chmod +x "$PLUGIN_DIR/assets/scripts/"*.sh

    # 🛡️ Deploy the watchdog script
    cp "$PLUGIN_DIR/assets/scripts/hve_watchdog.sh" "$WATCHDOG_FILE"
    chmod +x "$WATCHDOG_FILE"

    # Execute the internal assembler
    # Export the variable so assemble.sh knows where to save the final file
    export OVERLAY_FILE="$HVE_SAFE_DIR/overlay.conf"

    if [ -f "$ASSEMBLE_SCRIPT" ]; then
        bash "$ASSEMBLE_SCRIPT"

        # SECURITY PATCH: In case assemble.sh has the old hardcoded path
        if [ -f "$PLUGIN_DIR/overlay.conf" ]; then
            mv "$PLUGIN_DIR/overlay.conf" "$HVE_SAFE_DIR/overlay.conf"
        fi
    else
        echo "# Hyprland Visual Editor Overlay Base" > "$OVERLAY_FILE"
    fi
}

# --- MAIN LOGIC ---

if [ "$ACTION" == "enable" ]; then
    setup_files
    clean_hyprland_conf # Clean duplicates

    # Inject the COMPLETE BLOCK pointing to the safe refuge
    echo "" >> "$HYPR_CONF"
    echo "$MARKER_START" >> "$HYPR_CONF"
    echo "# 1. Active Uninstall Watchdog" >> "$HYPR_CONF"
    echo "$LINE_WATCHDOG" >> "$HYPR_CONF"
    echo "# 2. Variable Definition (Color Palette)" >> "$HYPR_CONF"
    echo "$LINE_COLORS" >> "$HYPR_CONF"
    echo "# 3. Effects Application (Visual Editor)" >> "$HYPR_CONF"
    echo "$LINE_OVERLAY" >> "$HYPR_CONF"
    echo "$MARKER_END" >> "$HYPR_CONF"

    # Final reload
    hyprctl reload
    
elif [ "$ACTION" == "disable" ]; then
    clean_hyprland_conf # Deletes the block from hyprland.conf

    # 🧹 Total cleanup: delete the refuge folder with the overlay and watchdog
    rm -rf "$HVE_SAFE_DIR"

fi