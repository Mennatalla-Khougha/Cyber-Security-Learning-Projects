### Check firewall status
```
sudo ufw status verbose
```

### Add firewall rules 
Deny all incoming & allow all outgoing
```
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

### Allow SSH connection
```
sudo ufw allow OpenSSH
```

### Enable firewall
```
sudo ufw enable
```

### Check firewall status & rules
```
sudo ufw status verbose
```