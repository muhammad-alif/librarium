#!/bin/bash

# Initial Reconnaissance Script 

# Usage: ./auspex_scan.sh <target>
TARGET=$1

if [ -z "$TARGET" ]; then
    echo "Usage: $0 <target>"
    exit 1
fi

# Check if the 'Enum' folder exists, if not, create it
if [ ! -d "./Enum" ]; then
    echo "[*] 'Enum' folder not found. Creating 'Enum' folder..."
    mkdir Enum
fi

# Change directory to 'Enum'
cd Enum || exit

echo "[*] Starting Recon on $TARGET - By the will of the Omnissiah"

# Nmap TCP Scan for all ports with a rate of 3000 packets per second
echo "[*] Performing Nmap TCP Scan..."
nmap -p- --min-rate=3000 -T4 -Pn $TARGET -oN nmap_tcp_scan.txt

# Nmap Detailed Scan on open ports
echo "[*] Performing Nmap Detailed Scan on Open Ports..."
nmap -sCV -Pn -p $(grep ^[0-9] nmap_tcp_scan.txt | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//) $TARGET -oN nmap_detailed_scan.txt

# Extract domain names from the nmap_detailed_scan.txt file, excluding any that contain "nmap"
DOMAIN_FILE="nmap_detailed_scan.txt"  # Path to the Nmap detailed scan results

# Extract any domain names from the specified file, remove duplicates
DOMAINS=$(grep -Eo '([a-zA-Z0-9._-]+\.[a-zA-Z]{2,})' "$DOMAIN_FILE" | grep -v "nmap" | sort -u)

if [ -n "$DOMAINS" ]; then
    echo "[*] Found domain names:"
    echo "$DOMAINS"

    # Loop through each domain in the list
    for DOMAIN in $DOMAINS; do
        # Check if the DOMAIN is not already in the existing domains
        if [[ ! " ${existing_array[@]} " =~ " ${DOMAIN} " ]]; then
            echo "[*] Successfully added $DOMAIN to /etc/hosts"
            # Uncomment the next line to actually add to /etc/hosts
            echo "$TARGET $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
        else
            echo "[*] $DOMAIN is already present in /etc/hosts"
        fi
    done
else
    echo "[*] No valid domain names found."
fi

# Nmap UDP Scan with a rate of 3000 packets per second
echo "[*] Performing Nmap UDP Scan..."
sudo nmap -sU -p- --min-rate=3000 -T4 $TARGET -oN nmap_udp_scan.txt

# Enum4linux Scan
enum4linux-ng -As $TARGET -oY enum4linuxOut

# Whois lookup
echo "[*] Performing WHOIS Lookup..."
whois $TARGET > whois_lookup.txt

# DNS Enumeration
echo "[*] Performing DNS Enumeration..."
for DOMAIN in $DOMAINS; do
  dnsrecon -d $DOMAIN -t std > dns_std_enum.txt
  dnsrecon -d $DOMAIN -t rvl > dns_rev_lookup.txt
done
#dnsrecon -d $DOMAINS -t brt -D /usr/share/seclists/Discovery/DNS/subdomains-top1million-20000.txt > dns_sub_dom.txt

# Display results
echo "[*] Auspex Scan Complete"
echo "[*] Results saved in the 'Enum' folder:"
echo " - Nmap TCP Scan: nmap_tcp_scan.txt, nmap_detailed_scan.txt"
echo " - Nmap UDP Scan: nmap_udp_scan.txt"
echo " - Enum4Linux Scan: enum4linuxOut.txt"
echo " - WHOIS Lookup: whois_lookup.txt"
echo " - DNS Enumeration: dns_std_enum.txt, dns_sub_dom.txt, dns_rev_lookup.txt"
