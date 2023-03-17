#!/bin/bash

# Function to display input box and get user input
get_input() {
  local message=$1
  local default_value=$2
  whiptail --inputbox "$message" 8 78 "$default_value" --title "Create LXC container" 3>&1 1>&2 2>&3
}

# Variables with default values
HOSTNAME=$(get_input "Enter container hostname:" "mycontainer")
TEMPLATE=$(get_input "Enter container template:" "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz")
STORAGE=$(get_input "Enter storage location:" "local-lvm")
MEMORY=$(get_input "Enter memory (MB):" "1024")
SWAP=$(get_input "Enter swap (MB):" "512")
DISK_SIZE=$(get_input "Enter disk size (e.g., 8G):" "8G")
NET_IFACE=$(get_input "Enter network interface (e.g., vmbr0):" "vmbr0")
IP_ADDR=$(get_input "Enter IP address (e.g., 192.168.1.100/24):" "192.168.1.100/24")
GATEWAY=$(get_input "Enter gateway IP address:" "192.168.1.1")

# Create LXC container
echo "Creating LXC container with the following configuration:"
echo "Hostname: $HOSTNAME"
echo "Template: $TEMPLATE"
echo "Storage: $STORAGE"
echo "Memory: $MEMORY MB"
echo "Swap: $SWAP MB"
echo "Disk size: $DISK_SIZE"
echo "Network interface: $NET_IFACE"
echo "IP address: $IP_ADDR"
echo "Gateway: $GATEWAY"
echo ""

CTID=$(pct create "$(pvesh get /cluster/nextid -output-format=json-pretty)" -hostname "$HOSTNAME" -ostemplate "$TEMPLATE" -storage "$STORAGE" -memory "$MEMORY" -swap "$SWAP" -net0 "name=eth0,bridge=$NET_IFACE,ip=$IP_ADDR,gw=$GATEWAY" -rootfs "$STORAGE:$DISK_SIZE" -onboot 1 -start 1 -unprivileged 1 -features "nesting=1" -force 1)

echo "LXC container created with ID $CTID."

# Ask for permission before proceeding to the second script
if (whiptail --title "Install Snapcast Server" --yesno "Do you want to install Snapcast Server in the newly created container?" 8 78); then
  echo "Installing Snapcast Server..."
  ./install_snapcast_server.sh "$CTID"
else
  echo "Snapcast Server installation skipped."
fi
