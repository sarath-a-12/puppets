#!/bin/bash
# Configure email notifications for sudo usage

# Install inotify-tools for file watching
sudo dnf install inotify-tools -y

# Install msmtp for email sending
sudo dnf install msmtp -y

# Prompt for admin email and password
read -p "Enter the admin email: " ADMIN_EMAIL
read -s -p "Enter the password for $ADMIN_EMAIL: " ADMIN_PASSWORD
echo

# Configure msmtp
cat <<EOT > ~/.msmtprc
account default
host smtp.gmail.com
port 587
auth on
user $ADMIN_EMAIL
password $ADMIN_PASSWORD
from $ADMIN_EMAIL
tls on
EOT
chmod 600 ~/.msmtprc

# Create sudo watcher script
cat <<EOT > /usr/local/bin/sudo_watcher.sh
#!/bin/bash
ADMIN_EMAIL="$ADMIN_EMAIL"

inotifywait -m -e modify /var/log/sudo.log |
while read path action; do
    MESSAGE=\$(tail -n 2 /var/log/sudo.log)
    echo -e "Subject: Sudo Alert\n\n\$MESSAGE" | msmtp "\$ADMIN_EMAIL"
done
EOT
chmod +x /usr/local/bin/sudo_watcher.sh

# Create and enable systemd service
cat <<EOT | sudo tee /etc/systemd/system/mail_sudo.service
[Unit]
Description=Watch for changes to sudo log file

[Service]
ExecStart=/bin/bash /usr/local/bin/sudo_watcher.sh
StartLimitIntervalSec=30
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOT
sudo systemctl daemon-reload
sudo systemctl start mail_sudo.service
sudo systemctl enable mail_sudo.service
