### Create a sudoers file backup
```
sudo cp /etc/sudoers ~/sudoers.backup
```

### Boot Ubuntu into recovery mood
- Advanced options for ubuntu
- recovery mood

#### If there is a sudoers backup file 
```
cp /home/<user dir>/sudoers.backup /etc/sudoers
chmod 440 /etc/sudoers
```

```
reboot
```


#### In case there is no backup sudoers file 
- if /etc/sudoers is badly damaged replace it with a default one 
```
# /etc/sudoers
Defaults        env_reset
Defaults        mail_badpass
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

root    ALL=(ALL:ALL) ALL
%sudo   ALL=(ALL:ALL) ALL
%admin  ALL=(ALL) ALL
```

```
reboot
```
