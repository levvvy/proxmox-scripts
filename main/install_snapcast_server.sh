#!/bin/bash

# Function to display input box and get user input
get_input() {
  local message=$1
  local default_value=$2
  whiptail --inputbox "$message" 8 78 "$default_value" --title "Install Snapcast Server" 3>&1 1>&2 2>&3
}

CTID="$1"

# Check if the container ID is valid
if ! pct status "$CTID" > /dev/null 2>&1; then
  echo "Invalid container ID. Exiting."
  exit 1
fi

# Update container and install dependencies
echo "Updating container and installing dependencies..."
pct exec "$CTID" -- apt-get update
pct exec "$CTID" -- apt-get install -y curl gnupg

# Add Snapcast repository and install Snapcast server
echo "Adding Snapcast repository and installing Snapcast server..."
pct exec "$CTID" -- sh -c "echo 'deb http://apt.mopidy.com/ jessie main contrib non-free' > /etc/apt/sources.list.d/mopidy.list"
pct exec "$CTID" -- sh -c "curl -sL https://apt.mopidy.com/mopidy.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/mopidy.gpg > /dev/null"
pct exec "$CTID" -- apt-get update
pct exec "$CTID" -- apt-get install -y snapserver

# Get user input for Snapcast server configuration
SNAPCAST_PORT=$(get_input "Enter the Snapcast server port:" "1704")
SNAPCAST_BUFFER=$(get_input "Enter the buffer size in ms (e.g., 1000):" "1000")
SNAPCAST_SOURCE=$(get_input "Enter the source (e.g., pipe:///tmp/snapfifo?name=default):" "pipe:///tmp/snapfifo?name=default")

# Update Snapcast server configuration
echo "Updating Snapcast server configuration..."
pct exec "$CTID" -- sh -c "sed -i 's/^#BIND_TO_ADDRESS=0.0.0.0/BIND_TO_ADDRESS=0.0.0.0/' /etc/default/snapserver"
pct exec "$CTID" -- sh -c "sed -i 's/^#TCP_PORT=1704/TCP_PORT=$SNAPCAST_PORT/' /etc/default/snapserver"
pct exec "$CTID" -- sh -c "sed -i 's/^#BUFFER_SIZE=1000/BUFFER_SIZE=$SNAPCAST_BUFFER/' /etc/default/snapserver"
pct exec "$CTID" -- sh -c "sed -i 's|^#SOURCE=pipe:///tmp/snapfifo?name=default|SOURCE=$SNAPCAST_SOURCE|' /etc/default/snapserver"

# Restart Snapcast server
echo "Restarting Snapcast server..."
pct exec "$CTID" -- systemctl restart snapserver

echo "Snapcast server installed and configured."
