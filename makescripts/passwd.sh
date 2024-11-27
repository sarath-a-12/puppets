#!/bin/bash

# Script to enforce password conditions on a Linux system

# Backup the original files
cp /etc/pam.d/system-auth /etc/pam.d/system-auth.bak
cp /etc/login.defs /etc/login.defs.bak

echo "Backups of configuration files created."

# Update /etc/pam.d/system-auth
echo "Updating /etc/pam.d/system-auth..."
if ! grep -q "pam_pwhistory.so remember=5" /etc/pam.d/system-auth; then
  echo "password required pam_pwhistory.so remember=5" >> /etc/pam.d/system-auth
  echo "Added pwhistory rule to system-auth."
else
  echo "pwhistory rule already exists in system-auth."
fi

if ! grep -q "pam_pwquality.so retry=3 minlen=12 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1" /etc/pam.d/system-auth; then
  echo "password requisite pam_pwquality.so retry=3 minlen=12 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1" >> /etc/pam.d/system-auth
  echo "Added pwquality rule to system-auth."
else
  echo "pwquality rule already exists in system-auth."
fi

# Update /etc/login.defs
echo "Updating /etc/login.defs..."
if ! grep -q "^PASS_MAX_DAYS" /etc/login.defs; then
  echo "PASS_MAX_DAYS 90" >> /etc/login.defs
  echo "Added PASS_MAX_DAYS to login.defs."
else
  sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/' /etc/login.defs
  echo "Updated PASS_MAX_DAYS in login.defs."
fi

# Verify changes
echo
echo "Verification of changes:"
echo "Contents of /etc/pam.d/system-auth:"
grep "pam_pwhistory.so\|pam_pwquality.so" /etc/pam.d/system-auth
echo
echo "Contents of /etc/login.defs:"
grep "^PASS_MAX_DAYS" /etc/login.defs

echo "Password conditions enforced successfully."
