#!/bin/bash

# Specify backup directory
backup_dir="/path/to/backup"

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$backup_dir"

# Array of critical files to back up
critical_files=(
    "/etc"
    "/var/www/html"
    "/home/user/documents"
    # Add more files and directories as needed
)

# Perform backup
for file in "${critical_files[@]}"; do
    if [ -e "$file" ]; then
        echo "Backing up $file..."
        cp -r "$file" "$backup_dir"
    else
        echo "Warning: $file does not exist."
    fi
done

echo "Backup completed. Files are stored in $backup_dir."
