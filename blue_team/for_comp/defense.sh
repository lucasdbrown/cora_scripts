#!/bin/bash

# Blue Team Script - Defend the Network

# Check for open ports
echo "Checking for open ports with Nmap..."
nmap -sV localhost > open_ports.txt
echo "Open ports report saved to open_ports.txt"

# Monitor running processes for suspicious activity
echo "Monitoring processes for suspicious activity..."
ps aux | grep -v root > process_report.txt
echo "Process report saved to process_report.txt"

# Ensure essential services are running
services=("nginx" "sshd" "docker" "ufw")
echo "Checking essential services..."
for service in "${services[@]}"
do
  if systemctl is-active --quiet $service; then
    echo "$service is running."
  else
    echo "$service is not running, restarting it..."
    sudo systemctl start $service
    echo "$service started."
  fi
done

# Check for rootkits
echo "Running chkrootkit for rootkit detection..."
chkrootkit > rootkit_report.txt
echo "Rootkit check report saved to rootkit_report.txt"

# Backup logs
echo "Backing up syslog and auth.log..."
sudo cp /var/log/syslog /var/log/auth.log ~/logs/
echo "Logs backed up."

echo "Defensive checks complete!"