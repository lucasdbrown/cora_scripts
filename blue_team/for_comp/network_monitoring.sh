#!/bin/bash

# Blue Team - Network Service Monitoring and Alert

SUSPICIOUS_PORTS=(21 22 23 445 3389)
LOG_FILE="/var/log/network_monitor.log"
ALERT_EMAIL="admin@example.com"

echo "[+] Monitoring network services..."
for port in "${SUSPICIOUS_PORTS[@]}"; do
    if netstat -tuln | grep ":$port " > /dev/null; then
        echo "[ALERT] Suspicious port $port open on $(hostname)" >> $LOG_FILE
        mail -s "Suspicious Port Opened" $ALERT_EMAIL < $LOG_FILE
    fi
done