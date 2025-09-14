#!/bin/bash

# Check if a Wayland session is active
if [ -n "$WAYLAND_DISPLAY" ]; then
        COPY_CMD="wl-copy"
        # Check if an X11 session is active
elif [ -n "$DISPLAY" ]; then
        # X11, prefer xclip
        if command -v xclip &> /dev/null; then
                COPY_CMD="xclip -selection clipboard"
                # Fallback to xsel if xclip isn't available
        elif command -v xsel &> /dev/null; then
                COPY_CMD="xsel --clipboard"
        else
                echo "Error: Neither wl-copy, xclip, nor xsel found. Please install a clipboard utility." >&2
                exit 1
        fi
else
        echo "Error: Could not detect display server. Neither WAYLAND_DISPLAY nor DISPLAY is set." >&2
        exit 1
fi

if [ $# -eq 0 ]; then
        echo "No arguments provided. Quitting $COPY_CMD"
elif [ -f "$1" ]; then
        cat "$1" | $COPY_CMD
else
        "$@" | $COPY_CMD
fi
