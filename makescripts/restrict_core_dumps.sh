#!/bin/bash
# Add core dump restriction to /etc/security/limits.conf
echo "*               hard    core            0" | sudo tee -a /etc/security/limits.conf
