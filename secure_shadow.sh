#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Set secure permissions for the shadow file
shadow_file="/etc/shadow"
if [ -f "$shadow_file" ]; then
    chmod 000 "$shadow_file"
    chown root:shadow "$shadow_file"
    chmod 640 "$shadow_file"
    echo "Secure permissions set for the shadow file."
else
    echo "Error: Shadow file not found at $shadow_file."
fi
