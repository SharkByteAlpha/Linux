#!/bin/bash

tools_to_remove=(
    netcat
    john
    hydra
    aircrack-ng
    fcrackzip
    lcrack
    ophcrack
    pdfcrack
    pyrit
    rarcrack
    sipcrack
    irpas
    logkeys
    zeitgeist
    nfs
    nginx
    inetd
    vnc
    snmp
)

for tool in "${tools_to_remove[@]}"; do
    read -p "Do you want to remove $tool? (y/n): " response
    if [ "$response" == "y" ]; then
        sudo apt-get remove --purge $tool   # Replace with the appropriate package manager command for your system
        echo "$tool removed successfully."
    else
        echo "$tool removal skipped."
    fi
done

echo "Removal process completed."

