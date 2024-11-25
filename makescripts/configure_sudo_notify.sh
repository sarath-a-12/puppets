#!/bin/bash
# Configure email notifications for sudo usage

# Install inotify-tools for file watching
sudo dnf install inotify-tools -y

# Install msmtp for email sending
sudo dnf install msmtp -y

# Configure msmtp
cat <<EOT > ~/.msmtprc
account default
host smtp.gmail.com
port 587
auth on
user <email>
password <password>
from <email>
tls on
EOT
chmod 600 ~/.msmtprc

# Create sudo watcher script
cat <<EOT > /usr/local/bin/sudo_watcher.sh
#!/bin/bash
ADMIN_EMAIL="admin@example.com"

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
