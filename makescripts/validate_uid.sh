#!/bin/bash
# Configure email notifications for checking if the UID is 0
read -p "Enter the admin email: " ADMIN_EMAIL

# Create uid-checker script
cat <<EOT > /usr/local/bin/check_uid0.sh
#!/bin/bash
ADMIN_EMAIL="$ADMIN_EMAIL"

inotifywait -m -e modify /etc/passwd |
while read path action; do
    if awk -F: '\$3 == 0 {print \$1}' /etc/passwd | grep -v "^root$"; then
        MESSAGE="Warning: Non-root user with UID 0 detected!"
        echo -e "Subject: UID 0 Alert\n\n\$MESSAGE" | msmtp "\$ADMIN_EMAIL"
    fi  
done
EOT
chmod +x /usr/local/bin/check_uid0.sh

# Create and enable systemd service
cat <<EOT | sudo tee /etc/systemd/system/validate_uid.service
[Unit]
Description=Watch for any 0 UID user added.

[Service]
ExecStart=/bin/bash /usr/local/bin/check_uid0.sh
StartLimitIntervalSec=30
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOT
sudo systemctl daemon-reload
sudo systemctl start validate_uid.service
sudo systemctl enable validate_uid.service
