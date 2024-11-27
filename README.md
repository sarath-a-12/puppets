# How to harden Oracle Linux OS

## Overview

1. [Use BIOS Password](#bios-passwd)
2. [Keep all packages and kernel up to date](#update)
3. [Remove write permissions of world-writable files](#world)
4. [Log Sudo](#sudo)
5. [Restrict sudo privileges](#restrict)
6. [Use setfacl to restrict access to portions of the file system](#setfacl)
7. [Validate UID of non-root users](#validate)
8. [Restrict Core Dump](#coredump)
9. [Notify SystemAdmin via mail whenever `sudo` is used by someone](#mail)
10. [Password Policies](#passwd_check)

## Detailed Instructions

### Encrypt partitions

NOTE: Do it later

<a name="bios-passwd"/>

### Use BIOS Password + Disable USB Booting

NOTE: Device specific. Will do later.

- Boot your system and enter BIOS setup
- Locate password settings
- Look for options like `Set Supervisor Password` or `Set user password`
- Set password

<a name="update"/>

### Keep all packages and kernel up to date

- Open the Crontab file

```bash
crontab -e
```

- Add the Cron Job

```bash
0 0 * * * /usr/bin/dnf update -y >> /var/log/dnf_update.log 2>&1

```

- Verify Cron jobs

```bash
crontab -l
```

<a name = "world" />

### Remove write permissions of world-writable files

- Execute this command to remove write permissions of world writable files:

```bash
find / -type f -writable -exec chmod o-w {} \;
```

<a name = "sudo" />

### Log Sudo

- Open sudoers file

```bash
visudo
```

- Add this line to `Defaults` section

```bash
Defaults logfile=/var/log/sudo.log
```

Now, all the commands will be logged in the file `/var/log/sudo.log`

<a name = "restrict"/>

### Restrict sudo privileges

- By default sudo is restricted to users

<a name="setfacl"/>

### Use `setfacl` to restrict access to portions of the file system

- <put the file>

```bash
    while read -r file; do
        sudo setfacl -m o::0 "$file"
    done < restricted_directories.txt
```

<a name="validate"/>

### Validate UID of non-root users

- Install and enable `auditd`

```bash
sudo dnf install auditd -y
sudo systemctl start auditd
sudo systemctl enable auditd
```

- Set up a watch on /etc/passwd

  1. Run the following command

  ```bash
  sudo auditctl -w /etc/passwd -p wa -k detect_uid0
  ```

  2. Open `/etc/audit/rules.d/audit.rules` and add the following line

  ```bash
  echo "-w /etc/passwd -p wa -k detect_uid0" | sudo tee -a /etc/audit/rules.d/audit.rules
  ```

  3. Open a file named `usr/local/bin/check_uid0.sh` and save the following there:

  ```sh
  #!/bin/bash
  #!/bin/bash
  if awk -F: '$3 == 0 {print $1}' /etc/passwd | grep -v "^root$"; then
      echo "Warning: Non-root user with UID 0 detected!"
      #| mail -s "UID 0 Alert" admin@example.com
      # modify the mail
  fi
  ```

<a name="coredump">

### Restrict Core Dump

- To disable core dump for all users, open `/etc/security/limits.conf` and add this line:
  ```bash
  *               hard    core            0
  ```

<a name="mail">

### Notify SystemAdmin via mail whenever `sudo` is used by someone

#### Setup `msmtp` to send emails from terminal

- Paste this to `~/.msmtprc`
  ```bash
  account default
  host smtp.gmail.com
  port 587
  auth on
  user <email-from-alert-is-sending>
  password <password>
  from <email-from-alert-is-sending>
  tls on
  ```
  > NOTE: If you are using Gmail's SMTP server, you need to set up an App Password in your gmail settings, get the key, and add it in place of the password.

#### Setup systemd service to notify system admin whenever someone uses sudo

> NOTE: You need to setup sudo logging as a prerequisite

- Open `/usr/local/bin/sudo_watcher.sh` and add the following:

  ```bash
  #!/bin/bash

  ADMIN_EMAIL = "admin@example.com"


  inotifywait -m -e modify var/log/sudo.log |
  while read path action; do
      MESSAGE = $(tail -n 2 /var/log/sudo.log)
      echo -e "Subject: Sudo Alert\n\n$MESSAGE" | msmtp "$ADMIN_EMAIL"
  ```

  > NOTE: please change `admin@exmaple.com` to the mail you want to notify sudo logging

- Run this command:

  ```bash
  chmod +x /usr/local/bin/sudo_watcher.sh
  ```

- Create a systemd service: Open `/var/systemd/system/mail_sudo.service` and add the following:

  ```
  [Unit]
  Description=Watch for changes to sudo log file

  [Service]
  ExecStart=/bin/bash /usr/local/bin/sudo_watcher.sh
  StartLimitIntervalSec=30
  StartLimitBurst=5

  [Install]
  WantedBy=multi-user.target
  ```

- Setup and start the service: Run the following commands

  ```bash
  systemctl daemon-reload
  systemctl start mail_sudo.service
  systemctl enable mail_sudo.service
  ```

- Check whether the service is running:
  ```bash
  systemctl status mail_sudo.service
  ```
- Now, try doing sudo commands like `sudo ls` and check whether admin-mail is notified

- To stop the service:
  ```bash
  systemctl daemon-reload
  systemctl stop mail_sudo.service
  ```

<a name="passwd_check">

### Enforcing password conditions

- Open `/etc/pam.d/system-auth`

Add the lines

```bash
password required pam_pwhistory.so remember=5

password requisite pam_pwquality.so retry=3 minlen=12 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1
```

> NOTE: The first line ensures that none of the previous 5 passwords can be used. The second one enforces that the password should have atleast 12 characters, minimum 1 uppercase, lowercase, digit and non-alphanumeric chatacter. It also sets the maximum number of retries to 3.

- Open `/etc/login.defs`

Add the line

```bash
PASS_MAX_DAYS 90
```

This ensures that the password has to be changed every 90 days.
