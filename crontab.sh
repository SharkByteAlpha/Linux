#!/bin/bash

# Script to allow only root in cron and remove non-root entries

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Backup existing cron table
cp /etc/crontab /etc/crontab.bak

# Remove non-root entries from cron
sed -i '/^[^#].*cron/s/^[^#].*//' /etc/crontab

echo "Only root is allowed in cron. Non-root entries have been removed."
