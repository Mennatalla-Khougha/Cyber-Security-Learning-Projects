## Heartbeat Service

### Heartbeat script

A simple script that writes a timestamped “heartbeat” message to a log file every 10 seconds.

- file path /usr/local/bin/heartbeat.sh
- file contents
```
#!/usr/bin/env bash
while true; do
  echo "$(date) - heartbeat" >> /var/log/heartbeat.log
  sleep 10
done
```
- make the file executable 
```
sudo chmod +x /usr/local/bin/heartbeat.sh
```


### Heartbeat systemed service

Runs the heartbeat script as a systemd-managed service that auto-restarts and can start on boot.

- service file path /etc/systemd/system/heartbeat.service
- service file contents
```
[Unit]
Description=Simple Heartbeat Service

[Service]
ExecStart=/usr/local/bin/heartbeat.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

- restart systemed
```
sudo systemctl daemon-reload
```

- enable & start heartbeat service
```
sudo systemctl enable heartbeat
sudo systemctl start heartbeat
sudo systemctl status heartbeat
```
