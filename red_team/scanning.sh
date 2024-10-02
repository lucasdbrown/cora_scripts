#!/bin/bash

# Red Team - Automated Nmap scan with Metasploit exploit search

TARGET=$1
SCAN_RESULT="nmap_scan_$TARGET.txt"
EXPLOIT_SEARCH_RESULT="exploit_search_$TARGET.txt"

# Run Nmap scan
echo "[+] Scanning $TARGET with Nmap..."
nmap -sV -O -oN $SCAN_RESULT $TARGET

# Extract services and versions from the scan result
echo "[+] Extracting services and versions..."
services=$(grep -Eo "[0-9]{1,5}/tcp.*open.*" $SCAN_RESULT | awk '{print $1 " " $3}')

# Loop through services and search for exploits in Metasploit
echo "[+] Searching for exploits in Metasploit..."
for service in $services; do
    search=$(echo $service | cut -d '/' -f 1 | tr -d '\n')
    msfconsole -q -x "search $search; exit" | grep -i exploit >> $EXPLOIT_SEARCH_RESULT
done

echo "[+] Exploits saved in $EXPLOIT_SEARCH_RESULT"