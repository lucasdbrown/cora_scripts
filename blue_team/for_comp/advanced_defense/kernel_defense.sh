#!/bin/bash

LOG_FILE="/var/log/blue_team_defense.log"
echo "[*] Blue Team Defense initiated at $(date)" >> $LOG_FILE

# Step 1: Detect unauthorized users and backdoor accounts
echo "[*] Checking for unauthorized users..." >> $LOG_FILE
UNAUTHORIZED_USERS=("backdoor" "attacker" "testuser")
for user in "${UNAUTHORIZED_USERS[@]}"; do
    if id "$user" &>/dev/null; then
        echo "[!] Unauthorized user '$user' detected. Removing user..." >> $LOG_FILE
        userdel -r "$user"
    fi
done

# Step 2: Scan for suspicious reverse shells
echo "[*] Checking for reverse shells..." >> $LOG_FILE
PORTS=(4441 4480 4444 9000)  # Known reverse shell ports used in the scripts
for port in "${PORTS[@]}"; do
    if lsof -i :$port | grep LISTEN &>/dev/null; then
        echo "[!] Reverse shell detected on port $port. Killing the process..." >> $LOG_FILE
        fuser -k "$port"/tcp
    fi
done

# Step 3: Scan and remove malicious cron jobs
echo "[*] Checking for malicious cron jobs..." >> $LOG_FILE
CRON_DIR="/var/spool/cron/crontabs"
if grep -E 'bash -i|nc|/dev/tcp|reverse_shell' "$CRON_DIR"/* &>/dev/null; then
    echo "[!] Malicious cron jobs detected. Removing suspicious entries..." >> $LOG_FILE
    sed -i '/bash -i/d' "$CRON_DIR"/*
    sed -i '/nc/d' "$CRON_DIR"/*
    sed -i '/reverse_shell/d' "$CRON_DIR"/*
fi

# Step 4: Check for PAM backdoors
echo "[*] Checking for PAM backdoor..." >> $LOG_FILE
PAM_FILE="/etc/pam.d/sshd"
if grep -q "pam_exec.so" "$PAM_FILE"; then
    echo "[!] PAM backdoor detected. Restoring original configuration..." >> $LOG_FILE
    cp "$PAM_FILE.bak" "$PAM_FILE"
    systemctl restart sshd
fi

# Step 5: Check for kernel rootkits
echo "[*] Scanning for kernel rootkits..." >> $LOG_FILE
if lsmod | grep -E 'rootkit|netfilter' &>/dev/null; then
    echo "[!] Kernel rootkit detected. Removing malicious module..." >> $LOG_FILE
    rmmod rootkit
    rmmod netfilter
fi

# Step 6: Validate system binaries (e.g., ls, ps) for tampering
echo "[*] Validating system binaries for tampering..." >> $LOG_FILE
CHECK_BINARIES=("/bin/ls" "/bin/ps" "/bin/netstat")
for binary in "${CHECK_BINARIES[@]}"; do
    if [[ $(md5sum "$binary" | awk '{print $1}') != $(md5sum --quiet /usr/bin/$(basename "$binary")) ]]; then
        echo "[!] System binary '$binary' may be tampered with. Reinstalling..." >> $LOG_FILE
        apt-get install --reinstall "$(dpkg -S "$binary" | awk -F: '{print $1}')"
    fi
done

# Step 7: Monitor for traffic manipulation
echo "[*] Checking for traffic manipulation..." >> $LOG_FILE
if lsmod | grep "netfilter" &>/dev/null; then
    echo "[!] Network rootkit detected. Removing module..." >> $LOG_FILE
    rmmod netfilter
fi

# Step 8: Clean suspicious modifications to /etc/hosts
echo "[*] Cleaning suspicious modifications to /etc/hosts..." >> $LOG_FILE
sed -i '/google.com/d' /etc/hosts
sed -i '/attacker/d' /etc/hosts

# Step 9: Restore important directories and file permissions
echo "[*] Restoring permissions on system directories..." >> $LOG_FILE
chown root:root /etc /var /home
chmod 755 /etc /var /home

# Step 10: Monitor system logs for abnormal activity
echo "[*] Scanning logs for suspicious activity..." >> $LOG_FILE
grep -E 'Memory Corruption|Critical Error|CRITICAL ERROR' /var/log/syslog
if [ $? -eq 0 ]; then
    echo "[!] Fake log entries detected. Cleaning up logs..." >> $LOG_FILE
    sed -i '/Memory Corruption/d' /var/log/syslog
    sed -i '/Critical Error/d' /var/log/syslog
fi

# Step 11: Check for firmware-level tampering
echo "[*] Checking for firmware-level backdoors..." >> $LOG_FILE
if hdparm --fwdownload-mode3 /dev/sda &>/dev/null; then
    echo "[!] Firmware tampering detected. Alerting sysadmin for manual intervention." >> $LOG_FILE
    echo "Potential firmware tampering detected on /dev/sda. Please inspect." | mail -s "Firmware Alert" admin@example.com
fi

# Step 12: Restart services that may have been tampered with
echo "[*] Restarting critical services..." >> $LOG_FILE
systemctl restart ssh apache2

# Final log
echo "[*] Blue Team Defense completed at $(date)" >> $LOG_FILE