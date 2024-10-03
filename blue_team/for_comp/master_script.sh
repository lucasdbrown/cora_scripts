#!/bin/bash

# Defensive Setup Script to run all security scripts in parallel
# Log directory for tracking the overall execution
LOG_DIR="/var/log/defense_setup"
mkdir -p $LOG_DIR

echo "[+] Starting all defensive scripts..."

# Run activity collection script
./activity_collection.sh &> $LOG_DIR/activity_collection.log &

# Run cron job detection script
./cron_detection.sh &> $LOG_DIR/cron_detection.log &

# Run network monitoring script
./network_monitoring.sh &> $LOG_DIR/network_monitoring.log &

# Run suspicious user detection and termination script
./sus_user.sh &> $LOG_DIR/sus_user.log &

# Run advanced defense scripts
./kernel_defense.sh &> $LOG_DIR/kernel_defense.log &
./varying_protection.sh &> $LOG_DIR/varying_protection.log &

# Wait for all scripts to complete
wait

echo "[+] All defensive scripts are running. Logs can be found in $LOG_DIR"