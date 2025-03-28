#!/bin/bash

# Use find to locate all .zip files in the current directory and subdirectories
find . -type f -name "*.zip" -print0 | while IFS= read -r -d '' zipfile; do
    # Get the directory and base name of the .zip file
    dir=$(dirname "$zipfile")
    basename=$(basename "$zipfile" .zip)

    # Create a temporary directory for extraction
    tempdir=$(mktemp -d)

    # Extract the .zip file into the temporary directory
    unzip -q "$zipfile" -d "$tempdir" || { echo "Error extracting $zipfile"; rm -rf "$tempdir"; continue; }

    # Create a .tar.xz archive in the same directory as the .zip file
    if tar -cJf "${dir}/${basename}.tar.xz" -C "$tempdir" .; then
        echo "Compressed $zipfile into ${dir}/${basename}.tar.xz"
        # Uncomment the line below if you want to delete the original .zip file
        rm "$zipfile"
    else
        echo "Error compressing $zipfile"
    fi

    # Remove the temporary directory
    rm -rf "$tempdir"
done
echo "Done :)"
