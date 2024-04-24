#!/bin/bash

# Function to encrypt password
encrypt_password() {
    # Use PBKDF2 for key derivation
    echo "$1" | openssl enc -aes-256-cbc -a -salt -pbkdf2 -pass pass:"$2"
}

# Function to decrypt password
decrypt_password() {
    # Use PBKDF2 for key derivation
    echo "$1" | openssl enc -d -aes-256-cbc -a -salt -pbkdf2 -pass pass:"$2" 2>/dev/null
}

# Main menu
while true; do
    echo "Password Manager Menu"
    echo "1. Add Password"
    echo "2. View Passwords"
    echo "3. Exit"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            read -p "Enter website/service name: " website
            read -p "Enter username: " username
            read -s -p "Enter password: " password
            echo "$(encrypt_password "$website|$username|$password" "$master_password")" >> passwords.txt
            echo "Password added successfully."
            ;;
        2)
            echo "Stored passwords:"
            while read -r line; do
                decrypted=$(decrypt_password "$line" "$master_password")
                IFS='|' read -r website username password <<< "$decrypted"
                echo "Website/Service: $website, Username: $username, Password: $password"
            done < passwords.txt
            ;;
        3)
            exit ;;
        *)
            echo "Invalid choice. Please try again." ;;
    esac
done
