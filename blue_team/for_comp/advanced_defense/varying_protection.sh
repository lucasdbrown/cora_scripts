#!/bin/bash

LOG_FILE="/var/log/blue_team_defense.log"
echo "[*] Blue Team Defense initiated at $(date)" >> $LOG_FILE

# Step 1: Remove unauthorized users and backdoor accounts
echo "[*] Checking for unauthorized users..." >> $LOG_FILE
UNAUTHORIZED_USERS=("backdoor" "attacker" "testuser")
for user in "${UNAUTHORIZED_USERS[@]}"; do
    if id "$user" &>/dev/null; then
        echo "[!] Unauthorized user '$user' detected. Removing user..." >> $LOG_FILE
        userdel -r "$user"
    fi
done

# Step 2: Detect and kill reverse shells
echo "[*] Checking for reverse shells..." >> $LOG_FILE
PORTS=(4444 5555 9000 4441 4480)
for port in "${PORTS[@]}"; do
    if lsof -i :$port | grep LISTEN &>/dev/null; then
        echo "[!] Reverse shell detected on port $port. Killing process..." >> $LOG_FILE
        fuser -k "$port"/tcp
    fi
done

# Step 3: Remove malicious cron jobs (Cron Flood & Path Abuse Defense)
echo "[*] Checking for malicious cron jobs..." >> $LOG_FILE
CRON_DIR="/var/spool/cron/crontabs"
if grep -E 'bash -i|nc|/dev/tcp|persistence.sh|.backdoor.sh' "$CRON_DIR"/* &>/dev/null; then
    echo "[!] Malicious cron jobs detected. Removing suspicious entries..." >> $LOG_FILE
    crontab -r  # Remove all cron jobs
fi

# Step 4: Fix writable /etc/passwd issues (Privilege Escalation Defense)
echo "[*] Checking for writable /etc/passwd..." >> $LOG_FILE
if [ -w /etc/passwd ]; then
    echo "[!] /etc/passwd is writable. Correcting permissions..." >> $LOG_FILE
    chmod 644 /etc/passwd
fi

# Step 5: Check and remove SUID binaries used for privilege escalation
echo "[*] Scanning for suspicious SUID binaries..." >> $LOG_FILE
SUID_BINARIES=$(find / -perm -4000 2>/dev/null)
for suid_bin in $SUID_BINARIES; do
    if [[ "$suid_bin" != "/bin/su" && "$suid_bin" != "/usr/bin/sudo" ]]; then
        echo "[!] Suspicious SUID binary detected: $suid_bin. Removing SUID bit..." >> $LOG_FILE
        chmod u-s "$suid_bin"
    fi
done

# Step 6: Remove NFS exploitation vectors (NFS Share Manipulation)
echo "[*] Checking for mounted NFS shares..." >> $LOG_FILE
MOUNTED_NFS=$(mount | grep nfs)
if [ -n "$MOUNTED_NFS" ]; then
    echo "[!] NFS share detected. Unmounting..." >> $LOG_FILE
    umount -f $(echo "$MOUNTED_NFS" | awk '{print $3}')
fi

# Step 7: Remove malicious systemd services and backdoors
echo "[*] Checking for malicious systemd services..." >> $LOG_FILE
SYSTEMD_SERVICES=("ssh.service" "annoy.service")
for service in "${SYSTEMD_SERVICES[@]}"; do
    if [ -f "/etc/systemd/system/$service" ]; then
        echo "[!] Malicious service detected: $service. Removing service..." >> $LOG_FILE
        systemctl stop "$service"
        systemctl disable "$service"
        rm -f "/etc/systemd/system/$service"
        systemctl daemon-reload
    fi
done

# Step 8: Check for persistence mechanisms in /tmp
echo "[*] Checking for persistent backdoor scripts in /tmp..." >> $LOG_FILE
TMP_BACKDOORS=("/tmp/.backdoor.sh" "/tmp/persistence.sh")
for file in "${TMP_BACKDOORS[@]}"; do
    if [ -f "$file" ]; then
        echo "[!] Backdoor script found: $file. Removing..." >> $LOG_FILE
        rm -f "$file"
    fi
done

# Step 9: Monitor system logs for suspicious activity
echo "[*] Monitoring logs for suspicious activity..." >> $LOG_FILE
if grep -E 'Memory Corruption|Critical Error|CRITICAL ERROR' /var/log/syslog &>/dev/null; then
    echo "[!] Fake log entries detected. Cleaning logs..." >> $LOG_FILE
    sed -i '/Memory Corruption/d' /var/log/syslog
    sed -i '/Critical Error/d' /var/log/syslog
fi

# Step 10: Restore permissions on critical directories and files
echo "[*] Restoring permissions on critical directories..." >> $LOG_FILE
chown root:root /etc /var /home
chmod 755 /etc /var /home

# Final log
echo "[*] Blue Team Defense completed at $(date)" >> $LOG_FILE