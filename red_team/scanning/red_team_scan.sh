#!/bin/bash

# Define target subnet for the competition (10.10.10.128/25 as per rules)
SUBNET="10.10.10.128/25"
OUTPUT_DIR="advanced_scan_results"
CRITICAL_PORTS=(22 80 443 3389 53 21)  # Modify ports based on importance in the environment

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Step 1: Stealthy SYN scan for live hosts (faster than full connect scans)
scan_live_hosts() {
    echo "[*] Running SYN scan on $SUBNET to detect live hosts..."
    nmap -sS -T4 -n -Pn --min-parallelism 10 $SUBNET -oG $OUTPUT_DIR/live_hosts.txt > /dev/null
    LIVE_HOSTS=$(grep "Up" $OUTPUT_DIR/live_hosts.txt | awk '{print $2}')
    
    echo "[+] Found live hosts:"
    echo "$LIVE_HOSTS"
}

# Step 2: Perform an advanced scan for each live host
advanced_scan() {
    local ip_addr=$1
    echo "[*] Performing advanced scan on $ip_addr"
    
    # -sC for default scripts, -sV for version detection, -O for OS fingerprinting, --reason to know why ports are flagged
    nmap -sS -sV -O --reason -p- --script vuln $ip_addr -oN $OUTPUT_DIR/${ip_addr}_detailed_scan.txt > /dev/null

    echo "[+] Saved detailed scan results to $OUTPUT_DIR/${ip_addr}_detailed_scan.txt"
}

# Step 3: Service-specific detection with Netcat and curl for banner grabbing
detect_critical_services() {
    local ip_addr=$1
    echo "[*] Checking critical services on $ip_addr"
    
    for port in "${CRITICAL_PORTS[@]}"; do
        nc -zv -w 1 $ip_addr $port &> /dev/null
        if [ $? -eq 0 ]; then
            echo "[!] Critical service detected on $ip_addr:$port"
            echo "$ip_addr:$port" >> $OUTPUT_DIR/critical_services.txt

            # If port 80 (HTTP) or 443 (HTTPS) is open, grab web banner
            if [[ "$port" == "80" || "$port" == "443" ]]; then
                echo "[*] Grabbing web server banner for $ip_addr:$port"
                curl -sI $ip_addr:$port >> $OUTPUT_DIR/${ip_addr}_web_banner.txt
                echo "[+] Web banner saved in ${ip_addr}_web_banner.txt"
            fi

            # Grab SSH banner if port 22 is open
            if [[ "$port" == "22" ]]; then
                echo "[*] Grabbing SSH banner for $ip_addr:$port"
                nc $ip_addr 22 -w 2 | head -n 1 >> $OUTPUT_DIR/${ip_addr}_ssh_banner.txt
                echo "[+] SSH banner saved in ${ip_addr}_ssh_banner.txt"
            fi
        fi
    done
}

# Main execution function
main() {
    # Step 1: SYN scan to detect live hosts
    scan_live_hosts
    
    # Step 2: Perform an advanced scan on each live host
    for ip in $LIVE_HOSTS; do
        advanced_scan $ip
        detect_critical_services $ip
    done
    
    echo "[+] All advanced scans completed. Results saved in $OUTPUT_DIR/"
}

# Execute the main function
main