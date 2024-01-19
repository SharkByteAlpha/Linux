#!/bin/bash

# Script to set UID 0 to root

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Specify the username to set UID 0
target_user="your_username"

# Check if the user exists
if id "$target_user" >/dev/null 2>&1; then
    # Set UID 0 for the specified user
    usermod -u 0 "$target_user"
    echo "UID set to 0 for user: $target_user"
else
    echo "User not found: $target_user"
fi
