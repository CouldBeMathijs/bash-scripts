#!/bin/bash

if [ $# -eq 0 ]; then
    wl-copy
elif [ -f "$1" ]; then
    cat "$1" | wl-copy
else
    "$@" | wl-copy
fi
