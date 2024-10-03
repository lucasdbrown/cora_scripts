
# lkm_rootkit.sh description
Uses a simple loadable kernel module (LKM) that hides processes, 
files, and network connections from detection tools, while giving the attacker
root privileges and the ability to remove user access stealthily.

# syscall_hooking.sh description
This script exploits a live kernel vulnerability to dynamically hook system calls (like read, write, open) to hide files, mask network activity, or elevate privileges. It patches the syscall table in memory, a highly stealthy and dangerous operation.

Use Cases: Could extend this to hook other syscalls like read, write, or even execve to hide processes, network connections, or even commands.

# traffic_manipulation.sh description
This rootkit hooks into the Linux kernel's network stack using the Netfilter framework. It drops or manipulates network packets destined for a specific port (port 4444, for example), effectively hiding the attacker's backdoor traffic from being captured by network monitoring tools.

Use Case: Could modify this to inspect packets for specific keywords or inject malicious payloads into HTTP traffic dynamically.

# firmware_injection.sh description
This method writes a backdoor directly to the firmware of a network interface card (NIC) or hard drive, allowing the attacker to maintain access even if the operating system is reinstalled. Firmware-level persistence is extremely hard to detect and remove without specialized tools.

## multi_port_infiltration.sh description
Here is an advanced Red Team script that uses multiple port infiltration by setting up backdoors on 20+ ports, escalates privileges on each port, and floods the system with multiple cron jobs. It manipulates system services, creates persistent cron jobs, adds backdoor users, and performs other disruptive actions like log manipulation, creating fake files and folders, and interfering with system directories.
Creates 200 random directories as well.

## Running `reverse_shell.c`
check if gcc is installed
`gcc --version`

install gcc
`sudo apt-get update`
`sudo apt-get install gcc`

compiling
`gcc -o reverse_shell reverse_shell.c`

run in the background
`./reverse_shell &`


