#!/bin/bash

# 1. Grundstruktur och Behörighet
# Scriptet kontrollerar att det körs som root (UID 0)
if [[ $EUID -ne 0 ]]; then
   echo "Detta script måste köras som root."
   exit 1
fi

# 2. Skapa ALLA användare först
# Vi loopar igenom alla argument och skapar användarna så att de finns i /etc/passwd
for username in "$@"; do
    if ! id "$username" &>/dev/null; then
        useradd -m "$username"
    fi
done

# 3. Katalogstruktur och Välkomstmeddelande
# Nu när alla användare finns i systemet skapar vi mappar och filer
for username in "$@"; do
    USER_HOME="/home/$username"

    # Skapa mappar: Documents, Downloads och Work
    mkdir -p "$USER_HOME"/{Documents,Downloads,Work}
    
    # Sätt rättigheter: Endast ägaren får läsa/skriva (700)
    chmod 700 "$USER_HOME/Documents" "$USER_HOME/Downloads" "$USER_HOME/Work"

    # 4. Välkomstmeddelande
    WELCOME_FILE="$USER_HOME/welcome.txt"
    
    # Första raden: Välkommen <användare>
    echo "Välkommen $username" > "$WELCOME_FILE"
    
    # Andra delen: Lista på ALLA andra användare i systemet
    # Vi använder grep -v för att ta bort den aktuella användaren från sin egen lista
    cut -d: -f1 /etc/passwd | grep -v "^$username$" >> "$WELCOME_FILE"