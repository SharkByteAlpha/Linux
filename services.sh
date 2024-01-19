#!/bin/bash

while true; do
    # Display menu
    echo "Choose an option:"
    echo "1. Securing SSH"
    echo "2. Option 2"
    echo "3. Option 3"
    echo "4. Option 4"
    echo "5. Option 5"
    echo "6. Exit"

    # Read user input
    read -p "Enter the number of your choice: " choice

    # Execute the selected option
    case $choice in
        1)
            # Option 1
            echo "You selected Option 1."
            # Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Backup sshd_config file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Disable root login
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Disable password authentication and only allow key-based authentication
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Set SSH protocol version to 2 only
sed -i 's/#Protocol 2/Protocol 2/' /etc/ssh/sshd_config

# Allow only specific users
read -p "Enter the usernames allowed to SSH (space-separated): " allowed_users
sed -i "/AllowUsers/c\AllowUsers $allowed_users" /etc/ssh/sshd_config

# Reload SSH service
systemctl reload ssh

echo "SSH configuration secured. Please make sure you can log in with the specified users before closing the existing SSH session."
            ;;
        2)
            # Option 2
            echo "You selected Option 2."
            # Place your Option 2 logic here
            ;;
        3)
            # Option 3
            echo "You selected Option 3."
            # Place your Option 3 logic here
            ;;
        4)
            # Option 4
            echo "You selected Option 4."
            # Place your Option 4 logic here
            ;;
        5)
            # Option 5
            echo "You selected Option 5."
            # Place your Option 5 logic here
            ;;
        6)
            # Exit
            echo "Exiting..."
            exit 0
            ;;
        *)
            # Invalid choice
            echo "Invalid choice. Please enter a number between 1 and 6."
            ;;
    esac
done
