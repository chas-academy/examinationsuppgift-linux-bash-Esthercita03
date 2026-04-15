#!/bin/bash

# 1. Grundstruktur och Behörighet
if [[ $EUID -ne 0 ]]; then
   exit 1
fi

# Store the list of existing users BEFORE creating new ones
# This ensures "already existing users" doesn't include the one we are currently creating.
EXISTING_USERS=$(cut -d: -f1 /etc/passwd)

for username in "$@"; do
    # 2. Användarskapande
    if id "$username" &>/dev/null; then
        continue
    fi

    useradd -m "$username"
    USER_HOME="/home/$username"

    # 3. Katalogstruktur och Rättigheter
    mkdir -p "$USER_HOME/Documents" "$USER_HOME/Downloads" "$USER_HOME/Work"
    
    # 4. Välkomstmeddelande
    WELCOME_FILE="$USER_HOME/welcome.txt"
    
    # Requirement: "Välkommen <användare>"
    echo "Välkommen $username" > "$WELCOME_FILE"
    
    # Requirement: List of all other users already in the system
    echo "$EXISTING_USERS" >> "$WELCOME_FILE"

    # Set Permissions and Ownership
    # Ensure folders are only readable/writable by the owner (700)
    chmod 700 "$USER_HOME/Documents" "$USER_HOME/Downloads" "$USER_HOME/Work"
    chown -R "$username":"$username" "$USER_HOME"
done