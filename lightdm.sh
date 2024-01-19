#!/bin/bash

# Script to secure LightDM on a Debian-based system

# Install necessary packages
sudo apt-get update
sudo apt-get install apparmor-utils

# Configure AppArmor profile for LightDM
sudo aa-enforce /etc/apparmor.d/usr.sbin.lightdm
sudo systemctl restart lightdm

# Disable guest sessions
echo "allow-guest=false" | sudo tee -a /etc/lightdm/lightdm.conf.d/50-no-guest.conf

# Restrict user access
echo "greeter-show-manual-login=true" | sudo tee -a /etc/lightdm/lightdm.conf.d/50-show-manual-login.conf

# Enable automatic login (optional, only if needed)
# echo "autologin-user=username" | sudo tee -a /etc/lightdm/lightdm.conf.d/60-autologin.conf

# Set session timeout (optional)
# echo "session-setup-script=/path/to/script.sh" | sudo tee -a /etc/lightdm/lightdm.conf.d/60-session-timeout.conf

# Restrict access to LightDM configuration files
sudo chown root:root /etc/lightdm/lightdm.conf.d/*
sudo chmod 600 /etc/lightdm/lightdm.conf.d/*

# Ensure permissions on LightDM executable
sudo chown root:root /usr/sbin/lightdm
sudo chmod 755 /usr/sbin/lightdm

echo "LightDM has been secured successfully."
