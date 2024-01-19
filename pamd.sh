#!/bin/bash

# Script to set login.defs and PAM password policies

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Set login.defs password policies
echo "Setting login.defs password policies..."
echo "PASS_MAX_DAYS   90" >> /etc/login.defs
echo "PASS_MIN_DAYS   7" >> /etc/login.defs
echo "PASS_WARN_AGE   14" >> /etc/login.defs

# Set PAM password policies
echo "Setting PAM password policies..."

# Edit /etc/pam.d/common-password or equivalent file
pam_file="/etc/pam.d/common-password"
if [ -f "$pam_file" ]; then
    sed -i '/^password.*pam_unix.so/s/$/ minlen=8 remember=5/' "$pam_file"
    echo "Password policies updated in $pam_file."
else
    echo "Error: $pam_file not found."
fi

echo "Password policies have been set successfully."
