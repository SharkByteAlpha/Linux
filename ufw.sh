#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Update and install UFW if not installed
apt update
apt install -y ufw

# Set default policies
ufw default deny incoming
ufw default allow outgoing

# Allow SSH connections
ufw allow ssh

# Prompt user to enter ports
read -p "Enter the ports you want to open (space-separated): " ports

# Allow specified ports
for port in $ports; do
    ufw allow "$port"
done

# Enable UFW
ufw enable

# Enable logging of dropped packets
ufw logging on

echo "UFW is now configured. Only SSH connections are allowed, and specified ports are open."
