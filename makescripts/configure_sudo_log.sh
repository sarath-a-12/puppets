#!/bin/bash
# Configure sudo logging
echo "Defaults logfile=/var/log/sudo.log" | sudo tee -a /etc/sudoers
