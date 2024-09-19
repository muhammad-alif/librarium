#!/bin/bash

# Ferobuster - Directory Busting for the Omnissiah!

# Check if IP and Port were provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <IP> <Port>"
  exit 1
fi

# Inputs for IP and Port
IP=$1
PORT=$2

# Check if the 'ferox' directory exists, if not, create it
if [ ! -d "ferox" ]; then
  echo "[*] Directory 'ferox' does not exist. Creating it now."
  mkdir ferox
fi

# File to check
OUTPUT_FILE="ferox/feroxbuster.txt"

# If the output file exists, back it up
if [ -f "$OUTPUT_FILE" ]; then
  echo "[*] Output file '$OUTPUT_FILE' already exists. Backing it up."
  mv "$OUTPUT_FILE" "$OUTPUT_FILE.bak"
fi

# Execute feroxbuster for directory discovery
echo "[*] Running feroxbuster for http://$IP:$PORT"
feroxbuster -u http://$IP:$PORT -C 400,401,402,403,404,405,500 -N 0 -n --dont-scan css,png,js,gif,svg -o ferox/feroxbuster.txt

# Execute feroxbuster for file discovery
echo "[*] Running feroxbuster for files using raft-large-files-lowercase.txt"
feroxbuster -u http://$IP:$PORT -C 400,401,402,403,404,405,500 -N 0 -n -w /usr/share/seclists/Discovery/Web-Content/raft-large-files-lowercase.txt --dont-scan css,png,js,gif -o ferox/feroxbuster_file.txt

echo "[*] nooSphere scan complete. Results saved in 'ferox' directory."
