#!/bin/bash

# Red Team - Automated Privilege Escalation

LOG_FILE="privesc_result.log"
USER=$(whoami)
PRIVES_PATH="/tmp/privesc_$USER.sh"

# Function to check SUID binaries
check_suid() {
    echo "[+] Checking for SUID binaries..." | tee -a $LOG_FILE
    find / -perm -4000 2>/dev/null >> $LOG_FILE
}

# Function to check writable paths in root PATH variable
check_writable_path() {
    echo "[+] Checking writable directories in PATH..." | tee -a $LOG_FILE
    for dir in $(echo $PATH | tr ':' ' '); do
        if [ -w $dir ]; then
            echo "[*] Writable directory: $dir" | tee -a $LOG_FILE
        fi
    done
}

# Function to check sudo rights for current user
check_sudo_rights() {
    echo "[+] Checking sudo rights for $USER..." | tee -a $LOG_FILE
    sudo -l | tee -a $LOG_FILE
}

# Function to simulate SUID exploitation
exploit_suid() {
    echo "[+] Trying SUID exploitation on binaries..." | tee -a $LOG_FILE
    while IFS= read -r binary; do
        if [[ $binary == *"bash"* ]]; then
            echo "[+] Potential escalation path through $binary" | tee -a $LOG_FILE
        fi
    done < <(find / -perm -4000 2>/dev/null)
}

# Start automated privilege escalation checks
echo "[+] Starting automated privilege escalation on $(hostname)" | tee -a $LOG_FILE
check_suid
check_writable_path
check_sudo_rights

# Attempt exploitation if possible SUID is found
exploit_suid

echo "[+] Privilege escalation log saved in $LOG_FILE"