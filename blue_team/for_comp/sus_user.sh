#!/bin/bash

# Blue Team - User Session Termination Script

SUSPICIOUS_USERS=("hacker" "testuser")
LOG_FILE="/var/log/suspicious_user_termination.log"

echo "[+] Checking for suspicious users..."
for user in "${SUSPICIOUS_USERS[@]}"; do
    if who | grep $user > /dev/null; then
        pts=$(who | grep $user | awk '{print $2}')
        echo "[+] Terminating session for $user on pts/$pts" >> $LOG_FILE
        pkill -9 -t $pts
    fi
done
