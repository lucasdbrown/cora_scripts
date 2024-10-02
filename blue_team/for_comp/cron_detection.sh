#!/bin/bash

# Blue Team - Suspicious Cron Job Detection

SUSPICIOUS_CMDS=("/bin/bash" "/nc" "/bin/sh")
LOG_FILE="/var/log/cron_job_detection.log"

echo "[+] Checking for suspicious cron jobs..."
for cmd in "${SUSPICIOUS_CMDS[@]}"; do
    if crontab -l | grep "$cmd" > /dev/null; then
        echo "[ALERT] Suspicious cron job detected: $cmd" >> $LOG_FILE
    fi
done