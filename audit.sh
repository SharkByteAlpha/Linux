#!/bin/bash

# Script to harden auditing on a Linux system

# Ensure the auditd package is installed
sudo apt-get install auditd   # For Debian/Ubuntu
# or
sudo yum install audit       # For Red Hat/CentOS

# Configure audit rules
sudo cp /etc/audit/audit.rules /etc/audit/audit.rules.bak   # Backup existing rules

# Add specific rules (customize based on your requirements)
echo "-w /etc/passwd -p wa -k identity" | sudo tee -a /etc/audit/audit.rules
echo "-w /etc/shadow -p wa -k identity" | sudo tee -a /etc/audit/audit.rules
echo "-a exit,always -F arch=b64 -S execve -k exec" | sudo tee -a /etc/audit/audit.rules

# Reload audit rules
sudo service auditd reload   # For systemd-based systems
# or
sudo service auditd restart  # For sysvinit-based systems

# Enable auditing at boot time
sudo systemctl enable auditd   # For systemd-based systems
# or
sudo chkconfig auditd on       # For sysvinit-based systems

# Verify that auditing is active
sudo auditctl -l

# Display audit logs
sudo ausearch -m avc -ts today

# Additional hardening steps:
# - Regularly review audit logs
# - Configure log rotation for audit logs
# - Set proper permissions on audit log files
# - Monitor system logs for any suspicious activities

echo "Auditing has been hardened successfully."
