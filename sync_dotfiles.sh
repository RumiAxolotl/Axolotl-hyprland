#!/bin/bash

# Source directory remains the same
SRC_DIR="$HOME/.config"

# Get the directory where this script is located (your Axolotl-hyprland folder)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set destination to the 'dotfiles' folder inside the script's directory
DEST_DIR="$SCRIPT_DIR/dotfiles"

# Array of folders based on your screenshot
FOLDERS=(
    "btop"
    "cava"
    "dunst"
    "fastfetch"
    "fontconfig"
    "fontforge"
    "gtk-3.0"
    "gtk-4.0"
    "hypr"
    "kitty"
    "nwg-dock-hyprland"
    "neofetch"
    "pipewire"
    "rofi"
    "rog"
    "waybar"
    "wlogout"
    "xfce4"
    "zathura"
)

echo "Starting dotfiles sync..."
echo "Source: $SRC_DIR"
echo "Destination: $DEST_DIR"
echo "--------------------------------------"

# Ensure the destination directory exists just in case
mkdir -p "$DEST_DIR"

for folder in "${FOLDERS[@]}"; do
    if [ -d "$SRC_DIR/$folder" ]; then
        echo "Syncing: $folder"
        # -a: archive mode, -v: verbose, --delete: removes deleted source files from destination
        rsync -a --delete "$SRC_DIR/$folder/" "$DEST_DIR/$folder/"
    else
        echo "Warning: Directory $SRC_DIR/$folder does not exist. Skipping."
    fi
done

echo "--------------------------------------"
echo "Sync complete!"
echo "Status of your git repository:"
# Run git status in the root of your repo
git -C "$SCRIPT_DIR" status -s