#!/bin/bash

# Ask for permission before proceeding to the first script
if (whiptail --title "Create LXC Container" --yesno "Do you want to create an LXC container?" 8 78); then
  bash -c "$(wget -qLO - https://raw.githubusercontent.com/levvvy/proxmox-scripts/main/create_lxc_container_interactive.sh)"
else
  echo "LXC container creation skipped."
fi

# Ask for permission before proceeding to the second script
if (whiptail --title "Install Snapcast Server" --yesno "Do you want to install Snapcast Server in the newly created container?" 8 78); then
  bash -c "$(wget -qLO - https://raw.githubusercontent.com/levvvy/proxmox-scripts/main/install_snapcast_server.sh)"
else
  echo "Snapcast Server installation skipped."
fi