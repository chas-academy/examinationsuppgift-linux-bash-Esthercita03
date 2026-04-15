#!/bin/bash
# ^ ser till att rätt shebang används.

# Kollar så att root används med att kolla vilket UID och det ska vara 0.
if [ "$EUID" -ne 0 ]; then
    echo "Du måste vara root för att köra create_user.sh"
    exit 1
fi

    # I första loopen skapar vi användare och mappar, sätter sedan korrekta rättigheter och ägare.
for user in "$@"; do
    useradd -m "$user"

    # Skapa mapparna i respektive användares home folder.
    mkdir /home/$user/Documents /home/$user/Downloads /home/$user/Work

    # Sätter korrekta läs/skriv rättigheter på mapparna.
    chmod 700 /home/$user/Documents /home/$user/Downloads /home/$user/Work

    # Sätter korrekt ägare av mapparna.
    chown $user:$user /home/$user/Documents /home/$user/Downloads /home/$user/Work

done

    # Andra loopen körs separat för att alla användare ska finnas innan welcome.txt skapas, annars finns dom inte i systemet.
    # Skapa välkomst meddelandet och sorterar och sätter korrekt ägare av filen.

for user in "$@"; do

    # Skapa välkomstfil med personligt meddelande.
    echo "Välkommen $user" > /home/$user/welcome.txt

    # Hämtar listan på alla användare i passwd filen och sorterar sedan bort aktuell användare
    cut -d: -f1 /etc/passwd | grep -v "^$user$" >> /home/$user/welcome.txt

    # Sätter användaren till ägare av välkomstfilen. 
    chown $user:$user /home/$user/welcome.txt

done