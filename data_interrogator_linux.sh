#!/bin/bash

# Omni-Spider Script - For the Omnissiah!

# Directory to start searching
SEARCH_DIR=${1:-/}  # Default to root if no directory provided

# Log file for results
LOG_FILE="omni_spyder_results.txt"

# Keywords to search for
KEYWORDS="username|user|login|password|pass|pwd|secret"

echo "[*] Starting Omni-Spider Scan - For the Omnissiah!"
echo "[*] Searching in directory: $SEARCH_DIR"
echo "[*] Logging results to: $LOG_FILE"

# Start the search
find "$SEARCH_DIR" \( -path /sys -o -path /snap -o -path /boot -o -path /run -o -path /usr -o \) -prune -o -type f -print 2>/dev/null | while read -r file; do
    echo "[*] Scanning file: $file"
    grep -E -i "$KEYWORDS" "$file" 2>/dev/null >> "$LOG_FILE"
done

# Report findings
echo "[*] Omni-Spider Scan Complete!"
echo "[*] Results have been logged in $LOG_FILE"
