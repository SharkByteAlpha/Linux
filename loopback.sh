#!/bin/bash

# Script to deny false loopback packets using iptables

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Define loopback address
loopback_address="127.0.0.1"

# Flush existing rules
iptables -F

# Deny false loopback packets
iptables -A INPUT -i lo -s $loopback_address -j DROP
iptables -A OUTPUT -o lo -d $loopback_address -j DROP

# Save iptables rules
service iptables save

echo "False loopback packets have been denied successfully."
