#!/usr/bin/env sh

# Define the default path
DEFAULT_PATH="$HOME/.dotfiles"

# Set the FLAKE_DIR
if [ -z "$1" ]; then
    FLAKE_DIR="$DEFAULT_PATH"
else
    FLAKE_DIR="$1"
fi

FLAKE_LOCK="$FLAKE_DIR/flake.lock"

# Check if the provided path is a directory
if [ ! -d "$FLAKE_DIR" ]; then
    echo "Error: Directory '$FLAKE_DIR' not found."
    exit 1
fi

# Check if flake.lock exists in the directory
if [ ! -f "$FLAKE_LOCK" ]; then
    echo "Error: 'flake.lock' not found in '$FLAKE_DIR'. Is this a Nix flake repository?"
    exit 1
fi

echo "--- Updating Nix Flake in $FLAKE_DIR ---"

# Save the pre-pull state of flake.lock using a portable mktemp
TEMP_LOCK=$(mktemp 2>/dev/null || mktemp -t 'flk')
if [ -z "$TEMP_LOCK" ]; then
    echo "Error: Could not create temporary file."
    exit 1
fi

cp "$FLAKE_LOCK" "$TEMP_LOCK"

# Navigate to the directory and run git pull
(
    cd "$FLAKE_DIR" || exit 1
    # The '|| exit 1' ensures the script stops the subshell if git pull fails
    if git pull; then
    else
        echo "Error: Git pull failed in $FLAKE_DIR."
        rm -f "$TEMP_LOCK"
        exit 1
    fi
)

# Check for changes in flake.lock
# Use 'diff' to compare and check the exit status
if ! diff -u "$TEMP_LOCK" "$FLAKE_LOCK" >/dev/null; then
    echo "--- Changes Detected ---"
    # Display the differences
    diff -u "$TEMP_LOCK" "$FLAKE_LOCK"
    echo "-----------------------------------------------------"
fi

# Clean up the temporary file
rm -f "$TEMP_LOCK"

echo "--- Operation Complete ---"
