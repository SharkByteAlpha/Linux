#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Backup lightdm.conf file
cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.bak

# Configure lightdm for a more secure setup
cat <<EOL > /etc/lightdm/lightdm.conf
[SeatDefaults]
allow-guest=false
greeter-show-manual-login=true
greeter-hide-users=true
allow-user-switching=false
greeter-session=unity-greeter
EOL

# Reload LightDM service
systemctl restart lightdm

echo "LightDM configuration secured. Guest login disabled, manual login shown, and user switching disallowed."
