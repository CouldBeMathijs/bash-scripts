#!/bin/bash

# Exit on error
set -e

# Check for exactly 3 arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <search_string> <replace_string> <folder_path>"
    exit 1
fi

search="$1"
replace="$2"
folder="$3"

echo "=== Replacement Script Started ==="
echo "Search string   : '$search'"
echo "Replace string  : '$replace'"
echo "Target directory: '$folder'"
echo

# Ensure folder exists
if [ ! -d "$folder" ]; then
    echo "ERROR: Folder '$folder' does not exist."
    exit 1
fi

# Function to replace content inside a file
replace_in_file() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "Updating contents in file: $file"
        sed -i "s/${search}/${replace}/g" "$file"
    fi
}

# Depth-first traversal to avoid rename conflicts
find "$folder" -depth | while read -r path; do
    # Replace contents if file
    replace_in_file "$path"

    # Rename file or directory if name contains search string
    base=$(basename "$path")
    dir=$(dirname "$path")
    if [[ "$base" == *"$search"* ]]; then
        new_base="${base//$search/$replace}"
        new_path="$dir/$new_base"
        echo "Renaming: $path"
        echo "     to: $new_path"
        mv "$path" "$new_path"
    fi
done

echo
echo "=== Replacement Completed ==="
