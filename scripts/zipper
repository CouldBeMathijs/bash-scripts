#!/bin/bash

# Prompt the user for the output zip file name
read -p "Enter the desired output zip file name (without .zip): " output_file
output_file="${output_file}.zip"

# Find all .cpp files excluding main.cpp and all .h files, then zip them
zip "$output_file" $(find . -maxdepth 1 -type f \( -name "*.cpp" ! -name "main.cpp" -o -name "*.h" -o -name "*.hpp" \))

# Confirm the result
if [ $? -eq 0 ]; then
    echo "Done :)"
else
    echo "An error occurred while zipping the files."
fi

