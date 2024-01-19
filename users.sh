#!/bin/bash

# Just In Case Stuff
while true; do
    test1=$(cat "$HOME/Linux-main/OHS_UB/users.txt")
    test2=$(cat "$HOME/Linux-main/OHS_UB/admins.txt")

    if [ -z "$test1" ]; then
        echo "Please add authorized users to users.txt"
    fi

    if [ -z "$test2" ]; then
        echo "Please add authorized admins to admins.txt"
    fi

    if [ -z "$test1" ] || [ -z "$test2" ]; then
        read -p "Press Enter to continue..."
    else
        break
    fi
done

# Authorized User Checks
secure_pw="Cyb3rP@tr10t212!"

# Creating User Accounts
while IFS= read -r user; do
    if id "$user" &>/dev/null; then
        continue
    fi

    sudo useradd -m -p "$(echo "$secure_pw" | openssl passwd -1 -stdin)" "$user"
    echo "[01 - User Management] Created User $user"
done < "$HOME/SystemDrive/OHS_WIN/users.txt"

# Creating Admin Accounts
while IFS= read -r admin; do
    if id "$admin" &>/dev/null; then
        continue
    fi

    sudo useradd -m -p "$(echo "$secure_pw" | openssl passwd -1 -stdin)" "$admin"
    sudo usermod -aG users "$admin"
    sudo usermod -aG administrators "$admin"
    echo "[01 - User Management] Created Administrator $admin"
done < "$HOME/SystemDrive/OHS_WIN/admins.txt"

# Enabling User Accounts
while IFS= read -r user; do
    if sudo passwd -S "$user" | grep -q "P 1"; then
        continue
    fi

    sudo passwd -u "$user"
    echo "[01 - User Management] Enabled User $user"
done < "$HOME/SystemDrive/OHS_WIN/users.txt"

# Enabling Admin Accounts
while IFS= read -r admin; do
    if sudo passwd -S "$admin" | grep -q "P 1"; then
        continue
    fi

    sudo passwd -u "$admin"
    echo "[01 - User Management] Enabled Administrator $admin"
done < "$HOME/SystemDrive/OHS_WIN/admins.txt"

# Adding Users to User Group
while IFS= read -r admin; do
    sudo usermod -aG users "$admin"
done < "$HOME/SystemDrive/OHS_WIN/admins.txt"

# Adding Admins to Admin Group
while IFS= read -r admin; do
    sudo usermod -aG users "$admin"
    if ! groups "$admin" | grep -q "administrators"; then
        sudo usermod -aG administrators "$admin"
        echo "[01 - User Management] Made User $admin an Administrator"
    fi
done < "$HOME/SystemDrive/OHS_WIN/admins.txt"

# Unauthorized User Checks
exclude=("Administrator" "DefaultAccount" "WDAGUtilityAccount" "Guest" "OHSadm" "OHSgst" "$USER" $(cat "$HOME/SystemDrive/OHS_WIN/users.txt") $(cat "$HOME/SystemDrive/OHS_WIN/admins.txt"))

while IFS= read -r line; do
    IFS=' ' read -ra parts <<< "$line"
    username="${parts[-1]}"

    if [[ " ${exclude[@]} " =~ " $username " ]]; then
        continue
    fi

    if sudo passwd -S "$username" | grep -q "P 1"; then
        echo "[01 - User Management] Unauthorized user $username is already disabled"
        continue
    fi

    read -p "Would you like to disable $username? (Yes/No): " answer

    if [ "$answer" == "Yes" ]; then
        sudo passwd -l "$username"
        echo "[01 - User Management] Disabled $username"
    else
        echo "[01 - User Management] Manually skipped disabling $username"
    fi
done < <(sudo getent passwd)

# More user/group management...

# User Password Changer
echo "Enter password for all users:"
read -s enteredPassword

if [ -z "$enteredPassword" ]; then
    echo "[01 - User Management] Passwords were not changed because the answer was null. Please try again."
else
    users=$(getent passwd | cut -d: -f1 | grep -v -E "$(IFS=\| ; echo "${exclude[*]}")")
    for user in $users; do
        echo "$enteredPassword" | sudo passwd --stdin "$
