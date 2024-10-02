#!/bin/bash

# List of unnecessary services to disable
services_to_disable=("telnet" "rsh" "rexec" "rlogin")

# Disable unwanted services
for service in "${services_to_disable[@]}"
do
    if systemctl is-active --quiet "$service"; then
        echo "[+] Disabling $service service"
        sudo systemctl stop "$service"
        sudo systemctl disable "$service"
    fi
done

# Restrict SSH to only allow key-based authentication
echo "[+] Configuring SSH settings"
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Configure firewall rules
echo "[+] Configuring firewall rules"
sudo iptables -F
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p icmp -j ACCEPT
sudo iptables -P INPUT DROP
sudo iptables-save | sudo tee /etc/iptables/rules.v4

echo "[+] Service hardening complete!"