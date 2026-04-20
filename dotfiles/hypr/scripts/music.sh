#!/bin/bash
# Music info script for hyprlock
# Usage: music.sh --title | --artist | --source | --art | --status

get_title() {
    title=$(playerctl metadata --format '{{ title }}' 2>/dev/null)
    if [ -z "$title" ]; then
        echo ""
    else
        # Truncate long titles
        if [ ${#title} -gt 30 ]; then
            echo "${title:0:27}..."
        else
            echo "$title"
        fi
    fi
}

get_artist() {
    artist=$(playerctl metadata --format '{{ artist }}' 2>/dev/null)
    if [ -z "$artist" ]; then
        echo ""
    else
        if [ ${#artist} -gt 30 ]; then
            echo "${artist:0:27}..."
        else
            echo "$artist"
        fi
    fi
}

get_source() {
    player=$(playerctl metadata --format '{{ playerName }}' 2>/dev/null)
    if [ -z "$player" ]; then
        echo ""
    else
        # Capitalize first letter
        echo "${player^}"
    fi
}

get_art() {
    art_url=$(playerctl metadata mpris:artUrl 2>/dev/null)
    cache_dir="/tmp/hyprlock_music"
    cache_file="$cache_dir/album_art.png"
    placeholder="$cache_dir/no_art.png"

    mkdir -p "$cache_dir"

    # Create a transparent placeholder if it doesn't exist
    if [ ! -f "$placeholder" ]; then
        if command -v convert &>/dev/null; then
            convert -size 86x86 xc:transparent "$placeholder" 2>/dev/null
        else
            # Create a minimal 1x1 transparent PNG
            printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n\xb4\x00\x00\x00\x00IEND\xaeB`\x82' > "$placeholder"
        fi
    fi

    if [ -z "$art_url" ]; then
        echo "$placeholder"
        return
    fi

    # Hash the URL to detect changes
    url_hash=$(echo "$art_url" | md5sum | cut -d' ' -f1)
    hash_file="$cache_dir/current_hash"
    downloading_file="$cache_dir/downloading"

    # Check if art has changed
    if [ -f "$hash_file" ] && [ "$(cat "$hash_file")" = "$url_hash" ] && [ -f "$cache_file" ]; then
        echo "$cache_file"
        return
    fi

    # If currently downloading, just return existing art to avoid blocking
    if [ -f "$downloading_file" ] && [ "$(cat "$downloading_file")" = "$url_hash" ]; then
        if [ -f "$cache_file" ]; then
            echo "$cache_file"
        else
            echo "$placeholder"
        fi
        return
    fi

    # Record that we are downloading this specific hash
    echo "$url_hash" > "$downloading_file"

    # Download new art
    if [[ "$art_url" == file://* ]]; then
        local_path="${art_url#file://}"
        cp "$local_path" "$cache_file" 2>/dev/null
        echo "$url_hash" > "$hash_file"
        rm -f "$downloading_file"
        echo "$cache_file"
    else
        (
            curl --max-time 5 -sL "$art_url" -o "${cache_file}.tmp" 2>/dev/null
            if [ -s "${cache_file}.tmp" ]; then
                mv "${cache_file}.tmp" "$cache_file"
                echo "$url_hash" > "$hash_file"
            fi
            rm -f "$downloading_file"
        ) &
        
        if [ -f "$cache_file" ]; then
            echo "$cache_file"
        else
            echo "$placeholder"
        fi
    fi
}

get_status() {
    playerctl status 2>/dev/null || echo "Stopped"
}

case "$1" in
    --title)  get_title ;;
    --artist) get_artist ;;
    --source) get_source ;;
    --art)    get_art ;;
    --status) get_status ;;
    *)        echo "Usage: $0 --title|--artist|--source|--art|--status" ;;
esac
