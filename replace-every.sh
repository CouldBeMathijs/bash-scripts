#!/usr/bin/env bash

# Exit on error
set -e

# --- Configuration ---

# Check for exactly 3 arguments
if [ "$#" -ne 3 ]; then
        # echo "Usage: $0 <search_string> <replace_string> <folder_path>"
        echo "Usage: replace-every <folder_path> <search_string> <replace_string>"
        exit 1
fi

folder="$1"
search="$2"
replace="$3"

# Ensure folder exists
if [ ! -d "$folder" ]; then
        echo "ERROR: Folder '$folder' does not exist."
        exit 1
fi

# --- Core Functions ---

# Function to perform a dry-run check for content replacement
dry_run_content() {
        local file="$1"
        # Check if the file contains the search string using grep
        if grep -qF "$search" "$file" 2>/dev/null; then
                echo "  - CONTENT CHANGE: $file"
                return 0 # True (will be edited)
        fi
        return 1 # False
}

# Function to perform a dry-run check for file/directory renaming
dry_run_rename() {
        local path="$1"
        local base=$(basename "$path")
        if [[ "$base" == *"$search"* ]]; then
                local dir=$(dirname "$path")
                local new_base="${base//$search/$replace}"
                local new_path="$dir/$new_base"
                echo "  - RENAME: $path -> $new_path"
                return 0 # True (will be renamed)
        fi
        return 1 # False
}

# Function to replace content inside a file (actual run)
replace_in_file() {
        local file="$1"
        if [ -f "$file" ]; then
                if dry_run_content "$file" >/dev/null; then 
                        echo "Updating contents in file: $file"
                        sed -i "s/${search}/${replace}/g" "$file" 
                fi
        fi
}

FIND_CMD="find \"$folder\" -depth \( -path '*/.git' -o -path '*/.git/*' \) -prune -o -print"


# --- Dry Run Execution ---

echo "=== DRY RUN: Proposed Changes ==="
echo "The following files/directories would be affected:"

AFFECTED_COUNT=0
while read -r path; do
        # Only check files for content changes
        if [ -f "$path" ]; then
                if dry_run_content "$path"; then
                        AFFECTED_COUNT=$((AFFECTED_COUNT + 1))
                fi
        fi

    # Check all paths (files and directories) for rename
    if dry_run_rename "$path"; then
            AFFECTED_COUNT=$((AFFECTED_COUNT + 1))
    fi
done < <(eval "$FIND_CMD")

if [ "$AFFECTED_COUNT" -eq 0 ]; then
        echo "No files or directories found containing '$search' within '$folder'."
        echo "=== Replacement Skipped ==="
        exit 0
fi

echo
echo "--- Dry Run Complete ---"

# --- Confirmation ---

read -r -p "Do you want to proceed with these changes? [y/N] " response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        # --- Actual Execution ---
        echo
        echo "=== Execution Confirmed: Applying Changes ==="

        while read -r path; do

        # 1. Replace contents if file
        if [ -f "$path" ]; then
                replace_in_file "$path"
        fi

        # 2. Rename file or directory if name contains search string
        base=$(basename "$path")
        dir=$(dirname "$path")
        if [[ "$base" == *"$search"* ]]; then
                new_base="${base//$search/$replace}"
                new_path="$dir/$new_base"

                if [ -e "$path" ]; then
                        echo "Renaming: $path"
                        echo "      to: $new_path"
                        mv "$path" "$new_path"
                else
                        echo "Skipping rename for '$path': Path no longer exists (likely renamed by a parent)."
                fi
        fi
done < <(eval "$FIND_CMD")

echo
echo "=== Replacement Completed Successfully ==="
else
        echo
        echo "=== Operation Cancelled by User ==="
fi
