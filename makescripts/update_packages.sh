#!/bin/bash
# Update all packages and log the results
crontab -l > mycron
echo "0 0 * * * /usr/bin/dnf update -y >> /var/log/dnf_update.log 2>&1" >> mycron
crontab mycron
rm mycron
