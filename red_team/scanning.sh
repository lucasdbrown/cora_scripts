#!/bin/bash

# Red Team - Multi-threaded Network Scanner and Exploiter

TARGET=$1
THREADS=5
SCAN_LOG="scan_result_$TARGET.log"
EXPLOIT_LOG="exploit_result_$TARGET.log"

# Function to scan the target with Nmap
scan_target() {
    local ip=$1
    echo "[+] Scanning $ip for open ports..."
    nmap -sV -T4 -p- --open -oN $SCAN_LOG $ip

    # Extract open ports and services
    grep -Eo "[0-9]{1,5}/tcp.*open.*" $SCAN_LOG | awk '{print $1 " " $3}' > services_$ip.txt
}

# Function to exploit services using Metasploit
exploit_target() {
    local service=$1
    local port=$(echo $service | awk '{print $1}' | cut -d'/' -f1)
    local service_name=$(echo $service | awk '{print $2}')

    echo "[+] Searching exploits for $service_name on port $port..."
    msfconsole -q -x "search $service_name; exit" | grep -i exploit >> $EXPLOIT_LOG

    # Simulate exploitation (replace with actual Metasploit script if needed)
    echo "[+] Attempting exploitation on $TARGET at port $port..."
}

# Run Nmap scan in parallel
echo "[+] Starting Nmap scan on $TARGET with $THREADS threads..."
scan_target $TARGET &

# Wait for scan completion
wait

# Parallel exploitation of services found
echo "[+] Exploiting services found..."
while read -r service; do
    exploit_target "$service" &
    if (( $(jobs | wc -l) >= THREADS )); then
        wait -n
    fi
done < services_$TARGET.txt

# Wait for all exploitation attempts to finish
wait

echo "[+] Exploit log saved in $EXPLOIT_LOG"