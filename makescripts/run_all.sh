#!/bin/bash

# Log file for the master script
LOG_FILE="/var/log/hardening.log"
echo "Starting hardening tasks..." > "$LOG_FILE"

# Ensure all tasks are executed safely
set -e

# Task 1: Keep packages and kernel up to date
echo "Running task: Keep packages and kernel up to date..." >> "$LOG_FILE"
bash update_packages.sh >> "$LOG_FILE" 2>&1 || echo "Failed to update packages" >> "$LOG_FILE"

# Task 2: Remove write permissions of world-writable files
echo "Running task: Remove write permissions of world-writable files..." >> "$LOG_FILE"
bash remove_world_write.sh >> "$LOG_FILE" 2>&1 || echo "Failed to remove world-writable permissions" >> "$LOG_FILE"

# Task 3: Log sudo usage
echo "Running task: Configure sudo logging..." >> "$LOG_FILE"
bash configure_sudo_log.sh >> "$LOG_FILE" 2>&1 || echo "Failed to configure sudo logging" >> "$LOG_FILE"

# Task 4: Restrict file system access using setfacl
echo "Running task: Restrict file system access..." >> "$LOG_FILE"
bash restrict_filesystem.sh >> "$LOG_FILE" 2>&1 || echo "Failed to restrict file system access" >> "$LOG_FILE"

# Task 5: Validate UID of non-root users
echo "Running task: Validate UID of non-root users..." >> "$LOG_FILE"
bash validate_uid.sh >> "$LOG_FILE" 2>&1 || echo "Failed to validate UID" >> "$LOG_FILE"

# Task 6: Restrict core dumps
echo "Running task: Restrict core dumps..." >> "$LOG_FILE"
bash restrict_core_dumps.sh >> "$LOG_FILE" 2>&1 || echo "Failed to restrict core dumps" >> "$LOG_FILE"

# Task 7: Notify admin via email for sudo usage
echo "Running task: Configure sudo email notifications..." >> "$LOG_FILE"
bash configure_sudo_notify.sh >> "$LOG_FILE" 2>&1 || echo "Failed to configure sudo email notifications" >> "$LOG_FILE"

echo "Hardening tasks completed." >> "$LOG_FILE"
