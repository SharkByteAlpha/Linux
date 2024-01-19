#!/bin/bash

# Specify the directory to search for .mp3 files
search_directory="/home"

# Check if the specified directory exists
if [ ! -d "$search_directory" ]; then
    echo "Error: Directory not found."
    exit 1
fi

# Navigate to the specified directory
cd "$search_directory" || exit

# Discover .mp3 files
mp3_files=($(find . -type f -name "*.mp3"))

# Check if any .mp3 files were found
if [ ${#mp3_files[@]} -eq 0 ]; then
    echo "No .mp3 files found in $search_directory."
    exit 0
fi

# Display the list of .mp3 files
echo "Found .mp3 files:"
for file in "${mp3_files[@]}"; do
    echo "$file"
done

# Ask the user if they want to delete the files
read -p "Do you want to delete these .mp3 files? (y/n): " response

if [ "$response" == "y" ]; then
    # Delete .mp3 files
    for file in "${mp3_files[@]}"; do
        rm "$file"
        echo "Deleted: $file"
    done
    echo "Deletion completed."
elif [ "$response" == "n" ]; then
    echo "Files were not deleted."
else
    echo "Invalid response. Files were not deleted."
fi
