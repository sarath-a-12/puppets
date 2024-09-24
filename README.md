## Config part 2

1. ssh
* make changes to `/etc/ssh/sshd_config`
* add line `DenyUsers <tab> <username>` or `AllowUsers <username>`
2. su
* add the following line to `/etc/pam.d/su`:
```
 auth 		required	pam_wheel.so group=custom_group ⁠
```
* create the custom group and add users to that group :
```bash
sudo groupadd custom_group
sudo usermod -aG custom_group username
```

3. auditctl
* specify log rotate, duration, size in `/etc/audit/auditd.conf`
* specify rules in `/etc/audit/rules.d/audit.rules`
* For logging all commands executed, 
```
sudo auditctl -a always,exit -F arch=b64 -S execve -k command-execution
```
Commands will be stored in the file `/var/log/auditctl_log`
