#!/bin/bash

# 1. Grundstruktur och Behörighet
if [[ $EUID -ne 0 ]]; then
   echo "Error: Must be root"
   exit 1
fi

for username in "$@"; do
    # 2. Användarskapande
    # Create user only if they don't exist
    if ! id "$username" &>/dev/null; then
        useradd -m "$username"
    fi

    USER_HOME="/home/$username"

    # 3. Katalogstruktur och Rättigheter
    # Create folders first
    mkdir -p "$USER_HOME/Documents" "$USER_HOME/Downloads" "$USER_HOME/Work"
    
    # 4. Välkomstmeddelande
    WELCOME_FILE="$USER_HOME/welcome.txt"
    
    # Create the file content exactly as requested
    echo "Välkommen $username" > "$WELCOME_FILE"
    cut -d: -f1 /etc/passwd >> "$WELCOME_FILE"

    # Final Security/Permission Step
    # Set ownership for the entire home directory and all files inside
    chown -R "$username":"$username" "$USER_HOME"
    
    # Set specific permissions for the folders (Requirement: only owner can read/write)
    chmod 700 "$USER_HOME/Documents" "$USER_HOME/Downloads" "$USER_HOME/Work"
    # Ensure the welcome file is also private
    chmod 600 "$WELCOME_FILE"
	

done
