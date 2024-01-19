#!/bin/bash

while true; do
    # Display menu
    echo "Choose an option:"
    echo "1. Secure SSH"
    echo "2. Secure FTP (With VSFTPD)"
    echo "3. Secure FTP (Without VSFTPD)"
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

# Enable password authentication and disable key-based authentication
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication no/' /etc/ssh/sshd_config

# Allow only specific users
read -p "Enter the usernames allowed to SSH (space-separated): " allowed_users
sed -i "/AllowUsers/c\AllowUsers $allowed_users" /etc/ssh/sshd_config

# Reload SSH service
systemctl reload ssh

echo "SSH configuration updated. Please make sure you can log in with password authentication before closing the existing SSH session."
            ;;
        2)
            # Option 2
            echo "You selected Option 2."
            # Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Install vsftpd (if not already installed)
apt-get update
apt-get install -y vsftpd

# Backup vsftpd.conf file
cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

# Configure vsftpd for a more secure setup
cat <<EOL > /etc/vsftpd.conf
listen=NO
listen_ipv6=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1_2=YES
ssl_sslv2=NO
ssl_sslv3=NO
require_ssl_reuse=NO
ssl_ciphers=HIGH
pasv_enable=YES
pasv_min_port=10000
pasv_max_port=10100
allow_writeable_chroot=YES
seccomp_sandbox=NO
EOL

# Create a user for FTP and set a password
read -p "Enter the username for FTP: " ftp_user
adduser $ftp_user

# Restart vsftpd service
systemctl restart vsftpd

echo "vsftpd configured securely. Use the FTP user credentials for authentication."

            ;;
        3)
            # Secure FTP (Without VSFTD)
            echo "Securing FTP (Without VSFTD)..."
            # Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Backup ftpd.conf file (assuming vsftpd is not installed)
cp /etc/inetd.conf /etc/inetd.conf.bak

# Configure ftpd for a more secure setup
cat <<EOL > /etc/inetd.conf
ftp     stream  tcp     nowait  root    /usr/sbin/tcpd  /usr/sbin/in.ftpd -l
EOL

# Restart inetd service
systemctl restart inetd

echo "Traditional FTP configured securely."
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
