#!/bin/bash

# Initial Reconnaissance Script 

# Usage: ./auspex_scan.sh <target>
TARGET=$1

if [ -z "$TARGET" ]; then
    echo "Usage: $0 <target>"
    exit 1
fi

echo "[*] Starting Recon on $TARGET - By the will of the Omnissiah"

# Nmap TCP Scan for all ports with a rate of 3000 packets per second
echo "[*] Performing Nmap TCP Scan..."
nmap -p- --min-rate=3000 -T4 -Pn $TARGET -oN nmap_tcp_scan.txt

# Nmap Detailed Scan on open ports
echo "[*] Performing Nmap Detailed Scan on Open Ports..."
nmap -sCV -Pn -p $(grep ^[0-9] nmap_tcp_scan.txt | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//) $TARGET -oN nmap_detailed_scan.txt

# Nmap UDP Scan with a rate of 3000 packets per second
echo "[*] Performing Nmap UDP Scan..."
sudo nmap -sU -p- --min-rate=3000 -T4 $TARGET -oN nmap_udp_scan.txt

# Enum4linux Scan
enum4linux-ng -As $TARGET -oY enum4linuxOut

# Whois lookup
echo "[*] Performing WHOIS Lookup..."
whois $TARGET > whois_lookup.txt

# DNS Enumeration
#echo "[*] Performing DNS Enumeration..."
dnsrecon -d $TARGET -t axfr > dns_enum.txt

# Dig for DNS Records
#echo "[*] Performing DIG DNS Lookup..."
#dig A $TARGET +short > dig_a_records.txt
#dig MX $TARGET +short > dig_mx_records.txt
#dig NS $TARGET +short > dig_ns_records.txt

# Display results
echo "[*] Auspex Scan Complete"
echo "[*] Results:"
echo " - Nmap TCP Scan: nmap_tcp_scan.txt"
echo " - Nmap UDP Scan: nmap_udp_scan.txt"
echo " - Nmap Detailed Scan: nmap_detailed_scan.txt"
echo " - Enum4Linux Scan: enum4linuxOut.txt"
echo " - WHOIS Lookup: whois_lookup.txt"
echo " - DNS Enumeration: dns_enum.txt"
#echo " - DIG A Records: dig_a_records.txt"
#echo " - DIG MX Records: dig_mx_records.txt"
#echo " - DIG NS Records: dig_ns_records.txt"
