# How to harden Oracle Linux OS

## Overview
1. [Use BIOS Password](#bios-passwd)
2. [Keep all packages and kernel up to date](#update)
3. [Remove write permissions of world-writable files](#world)
4. [Log Sudo](#sudo)
5. [Restrict sudo privileges](#restrict)
6. [Use setfacl to restrict access to portions of the file system](#setfacl)
7. [Validate UID of non-root users](#validate)


## Detailed Instructions

### Encrypt partitions
NOTE: Do it later


<a name="bios-passwd"/>

### Use BIOS Password + Disable USB Booting

NOTE: Device specific. Will do later. 

* Boot your system and enter BIOS setup
* Locate password settings
* Look for options like `Set Supervisor Password` or `Set user password`
* Set password


<a name="update"/>

### Keep all packages and kernel up to date

* Open the Crontab file
```bash
crontab -e
```

* Add the Cron Job
```bash
0 0 * * * /usr/bin/dnf update -y >> /var/log/dnf_update.log 2>&1

```

* Verify Cron jobs
```bash
crontab -l
```


<a name = "world" />

### Remove write permissions of world-writable files

* Execute this command to remove write permissions of world writable files: 
```bash
find / -type f -writable -exec chmod o-w {} \;
```

<a name = "sudo" />

### Log Sudo

* Open sudoers file
```bash
visudo
```
* Add this line to `Defaults` section
```bash
Defaults logfile=/var/log/sudo
```

Now, all the commands will be logged in the file `/var/log/sudo.log`

<a name = "restrict"/>

### Restrict sudo privileges 

* By default sudo is restricted to users

<a name="setfacl"/>

### Use `setfacl` to restrict access to portions of the file system

* <put the file>
```bash
cat dir.txt | sudo setfacl -m o::0 {} +
```

<a name="validate"/>

### Validate UID of non-root users

* Install and enable `auditd`
```bash
sudo dnf install auditd -y
sudo systemctl start auditd
sudo systemctl enable auditd
```

* Set up a watch on /etc/passwd

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
