#!/bin/bash

# Check if required tools are installed
if ! command -v nmap &> /dev/null; then
    echo "nmap is required but not installed. Please install it."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "jq is required but not installed. Please install it."
    exit 1
fi

# Check if an IP address is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <IP_ADDRESS>"
    exit 1
fi

TARGET_IP="$1"

# Step 1: Perform an nmap scan to detect OS version and services
echo "Scanning $TARGET_IP for open services and OS information..."
nmap_output=$(nmap -O -sV "$TARGET_IP")

# Step 2: Extract Ubuntu version (if any) from nmap scan
ubuntu_version=$(echo "$nmap_output" | grep -i "ubuntu" | awk '{print $NF}')

if [ -z "$ubuntu_version" ]; then
    echo "Could not detect Ubuntu version on $TARGET_IP. Continuing with service detection."
else
    echo "Detected Ubuntu version: $ubuntu_version"
fi

# Step 3: Extract open services and ports
open_services=$(echo "$nmap_output" | grep open | awk '{print $3}')

if [ -z "$open_services" ]; then
    echo "No open services found on $TARGET_IP. Exiting."
    exit 1
fi

echo "Detected open services: $open_services"

# Step 4: Query CVE-Search for relevant vulnerabilities
echo "Querying CVE database for vulnerabilities related to Ubuntu $ubuntu_version and services: $open_services..."

# For each service detected, query cve-search API for related CVEs
for service in $open_services; do
    echo "Checking CVEs for service: $service"
    
    # Query cve-search API (replace <API_ENDPOINT> with the actual cve-search API URL)
    cve_response=$(curl -s "http://<API_ENDPOINT>/api/search/$service")

    # Check if the response contains any CVEs
    cve_count=$(echo "$cve_response" | jq '. | length')

    if [ "$cve_count" -eq 0 ]; then
        echo "No CVEs found for $service."
    else
        echo "Found CVEs for $service:"
        echo "$cve_response" | jq '.[] | {CVE: .id, Summary: .summary}'
    fi
done

# Step 5: Check for OS-related CVEs (if Ubuntu version was detected)
if [ -n "$ubuntu_version" ]; then
    echo "Checking for Ubuntu $ubuntu_version related CVEs..."
    
    ubuntu_cve_response=$(curl -s "http://<API_ENDPOINT>/api/search/ubuntu/$ubuntu_version")

    ubuntu_cve_count=$(echo "$ubuntu_cve_response" | jq '. | length')

    if [ "$ubuntu_cve_count" -eq 0 ]; then
        echo "No Ubuntu $ubuntu_version related CVEs found."
    else
        echo "Found Ubuntu $ubuntu_version related CVEs:"
        echo "$ubuntu_cve_response" | jq '.[] | {CVE: .id, Summary: .summary}'
    fi
fi

echo "Scan complete."