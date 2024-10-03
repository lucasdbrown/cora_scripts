#!/bin/bash

# Subnet to scan
SUBNET="10.10.10.128/25"
OUTPUT_DIR="scan_results"
CRITICAL_PORTS=(22 80 443 3389)  # Add or modify ports as needed

# Create directory to store results
mkdir -p $OUTPUT_DIR

# Function to scan the subnet for live hosts
scan_subnet() {
    echo "[*] Scanning subnet: $SUBNET"
    nmap -sn $SUBNET -oG $OUTPUT_DIR/live_hosts.txt > /dev/null
    LIVE_HOSTS=$(grep "Up" $OUTPUT_DIR/live_hosts.txt | awk '{print $2}')
    echo "[+] Live hosts found:"
    echo "$LIVE_HOSTS"
}

# Function to perform an aggressive scan on each live host
aggressive_scan() {
    local ip_addr=$1
    echo "[*] Performing aggressive scan on $ip_addr"
    nmap -A -p- $ip_addr -oN $OUTPUT_DIR/${ip_addr}_aggressive_scan.txt > /dev/null
    echo "[+] Aggressive scan for $ip_addr saved in ${OUTPUT_DIR}/${ip_addr}_aggressive_scan.txt"
}

# Function to check for critical services on specific ports
check_critical_services() {
    local ip_addr=$1
    echo "[*] Checking critical ports on $ip_addr"
    for port in "${CRITICAL_PORTS[@]}"; do
        nc -zv -w 1 $ip_addr $port &> /dev/null
        if [ $? -eq 0 ]; then
            echo "[!] Critical service detected on $ip_addr:$port"
            echo "$ip_addr:$port" >> $OUTPUT_DIR/critical_services.txt
        fi
    done
}

# Main function
main() {
    # Step 1: Scan the subnet for live hosts
    scan_subnet

    # Step 2: Perform aggressive scans and check for critical services
    for ip in $LIVE_HOSTS; do
        aggressive_scan $ip
        check_critical_services $ip
    done

    echo "[+] All scans complete. Results stored in $OUTPUT_DIR/"
}

# Run the main function
main