#!/bin/bash

# ==============================================================================
# Script: create_users.sh
# Description: Automates user creation, directory setup, and welcome messages.
# Requirements: Must be run as root (UID 0).
# ==============================================================================

# 1. Check if the user running the script is root
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root (use sudo)."
   exit 1
fi

# Check if at least one username was provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 username1 username2 ..."
    exit 1
fi

# Loop through all arguments (usernames) passed to the script
for username in "$@"; do

    # 2. User Creation
    # Check if the user already exists to avoid errors
    if id "$username" &>/dev/null; then
        echo "User '$username' already exists. Skipping..."
        continue
    fi

    # Create the user with a home directory (-m)
    useradd -m "$username"
    echo "Successfully created user: $username"

    # Define the path to the user's home directory
    USER_HOME="/home/$username"

    # 3. Directory Structure and Permissions
    # Create the required subfolders: Documents, Downloads, and Work
    mkdir -p "$USER_HOME"/{Documents,Downloads,Work}

    # Set ownership so the new user owns their folders
    chown -R "$username":"$username" "$USER_HOME"

    # Set permissions: Only the owner can read, write, and execute (700)
    chmod 700 "$USER_HOME/Documents"
    chmod 700 "$USER_HOME/Downloads"
    chmod 700 "$USER_HOME/Work"

    # 4. Welcome Message
    WELCOME_FILE="$USER_HOME/welcome.txt"
    
    # Line 1: Personalized welcome message
    echo "Välkommen $username" > "$WELCOME_FILE"
    
    # Line 2+: List of all existing users in the system
    cut -d: -f1 /etc/passwd >> "$WELCOME_FILE"

    # Ensure the user owns their welcome file
    chown "$username":"$username" "$WELCOME_FILE"

    echo "Folders and welcome.txt created for $username."

done

echo "Process complete!"