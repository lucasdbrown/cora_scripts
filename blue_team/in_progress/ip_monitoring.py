import subprocess
import time
import re

# Allowed subnet for in-scope machines
allowed_subnet = "10.10.10.128/25"

def get_active_connections():
    # Use netstat to get current connections
    result = subprocess.run(['netstat', '-tn'], capture_output=True, text=True)
    return result.stdout

def is_ip_in_subnet(ip, subnet):
    # Check if IP is within the allowed subnet
    return re.match(rf"^{subnet.split('/')[0]}", ip)

def block_ip(ip):
    # Block IP using iptables
    subprocess.run(['sudo', 'iptables', '-A', 'INPUT', '-s', ip, '-j', 'DROP'])
    print(f"Blocked suspicious IP: {ip}")

def monitor_connections():
    while True:
        connections = get_active_connections().splitlines()
        for conn in connections:
            if 'ESTABLISHED' in conn:
                parts = conn.split()
                remote_ip = parts[4].split(':')[0]
                if not is_ip_in_subnet(remote_ip, allowed_subnet):
                    block_ip(remote_ip)
        
        time.sleep(10)

if __name__ == "__main__":
    monitor_connections()