#!/bin/bash

# Blue Team - Automated Incident Response and Forensic Collection

FORENSIC_DIR="/var/log/forensics_$(date +%F_%T)"
mkdir -p $FORENSIC_DIR

# Function to collect logs
collect_logs() {
    echo "[+] Collecting system logs..." | tee -a $FORENSIC_DIR/incident_report.log
    cp /var/log/auth.log $FORENSIC_DIR/
    cp /var/log/syslog $FORENSIC_DIR/
}

# Function to capture current network connections
capture_network_activity() {
    echo "[+] Capturing network activity..." | tee -a $FORENSIC_DIR/incident_report.log
    netstat -tulnp > $FORENSIC_DIR/network_activity.log
    ss -tnplu >> $FORENSIC_DIR/network_activity.log
}

# Function to list and hash suspicious binaries
hash_binaries() {
    echo "[+] Hashing suspicious binaries..." | tee -a $FORENSIC_DIR/incident_report.log
    find / -type f \( -perm -4000 -o -perm -2000 \) -exec sha256sum {} \; > $FORENSIC_DIR/suspicious_binaries.log
}

# Function to create a process tree snapshot
create_process_snapshot() {
    echo "[+] Creating process snapshot..." | tee -a $FORENSIC_DIR/incident_report.log
    ps auxf > $FORENSIC_DIR/process_snapshot.log
}

# Execute forensic collection functions
echo "[+] Starting forensic data collection for incident response..."
collect_logs &
capture_network_activity &
hash_binaries &
create_process_snapshot &

# Wait for all forensic collection tasks to complete
wait

echo "[+] Forensic data collected at $FORENSIC_DIR"