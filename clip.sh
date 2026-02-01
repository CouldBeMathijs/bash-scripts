#!/bin/bash

# Function to copy using OSC 52 (Works over SSH)
osc52_copy() {
    local base64_data
    base64_data=$(base64 | tr -d '\n')
    printf "\e]52;c;%s\a" "$base64_data"
}

# 1. Check if we are in an SSH session
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    COPY_CMD="osc52_copy"
# 2. Local Wayland check
elif [ -n "$WAYLAND_DISPLAY" ]; then
    COPY_CMD="wl-copy"
# 3. Local X11 check
elif [ -n "$DISPLAY" ]; then
    if command -v xclip &> /dev/null; then
        COPY_CMD="xclip -selection clipboard"
    elif command -v xsel &> /dev/null; then
        COPY_CMD="xsel --clipboard"
    else
        COPY_CMD="osc52_copy" # Fallback to OSC52 if utilities are missing
    fi
else
    # Final fallback for headless/TTY
    COPY_CMD="osc52_copy"
fi

# Execution Logic
if [ $# -eq 0 ]; then
    echo "No arguments provided. Usage: script.sh [file] or [command]"
    exit 1
elif [ -f "$1" ]; then
    cat "$1" | $COPY_CMD
else
    "$@" | $COPY_CMD
fi
