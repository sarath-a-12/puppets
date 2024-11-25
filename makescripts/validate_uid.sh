#!/bin/bash
# Install auditd and add rules to validate UID
sudo dnf install auditd -y
sudo systemctl start auditd
sudo systemctl enable auditd
sudo auditctl -w /etc/passwd -p wa -k detect_uid0
echo "-w /etc/passwd -p wa -k detect_uid0" | sudo tee -a /etc/audit/rules.d/audit.rules

# Add UID check script to /usr/local/bin
cat <<EOT > /usr/local/bin/check_uid0.sh
#!/bin/bash
if awk -F: '\$3 == 0 {print \$1}' /etc/passwd | grep -v "^root$"; then
    ADMIN_EMAIL="admin@example.com"
    MESSAGE="Warning: Non-root user with UID 0 detected!"
    # Uncomment the line below to send an email alert
    echo -e "Subject: UID 0 Alert\n\n$MESSAGE" | msmtp "$ADMIN_EMAIL"
fi
EOT
chmod +x /usr/local/bin/check_uid0.sh
