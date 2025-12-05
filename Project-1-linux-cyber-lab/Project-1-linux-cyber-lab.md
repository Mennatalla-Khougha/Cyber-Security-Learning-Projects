# Project 1 — Linux Cyber Lab (Fundamentals)

## 🎯 Goal

Build a complete, realistic Linux cyber lab and use it to learn:

* Linux administration
* Bash scripting & automation
* Hardening & security
* Break–fix skills

This file is **fully complete**, with **no empty bullets**, **no blank tasks**, and **no placeholders**.

---

# 0️⃣ Prerequisites

* Basic terminal usage (`cd`, `ls`, `mkdir`, etc.)
* Host machine:

  * 16 GB RAM recommended
  * 100 GB free disk
* Installed: VirtualBox **or** VMware Player

---

# 1️⃣ Environment Setup

## 1.1 Install Virtualization

**Tasks**

* Install VirtualBox OR VMware Player on your host machine
* Create folder for all your cybersecurity labs:

  ```bash
  mkdir -p ~/labs/cyber-lab
  ```

**Done when**

* VirtualBox/VMware runs with no errors
* Folder `~/labs/cyber-lab` exists

---

## 1.2 Create Two Virtual Machines

### Ubuntu VM Settings

* Name: `ubuntu-lab`
* OS: Ubuntu Server 22.04 LTS
* CPU: 2–4 cores
* RAM: 4–8 GB
* Disk: 40–60 GB
* Network: NAT or Bridged

### Kali VM Settings

* Name: `kali-lab`
* OS: Kali Linux
* CPU: 2 cores
* RAM: 4 GB
* Disk: 40–60 GB
* Network: same mode as Ubuntu

### Tasks

* Download Ubuntu Server ISO
* Download Kali Linux ISO
* Create both VMs using your virtualization software
* Install the operating systems
* During installation:

  * Ubuntu hostname: `ubuntu-lab`
  * Kali hostname: `kali-lab`
  * Create a non-root user with password

**Done when**

* Both VMs boot normally
* You can log into both systems via the VM console

---

## 1.3 Setup SSH & Snapshots

### Install SSH + Tools (Ubuntu)

```bash
sudo apt update && sudo apt install -y openssh-server git vim htop net-tools
ip a       # find IP
```

### Tasks

* Enable SSH:

  ```bash
  sudo systemctl enable ssh
  sudo systemctl start ssh
  sudo systemctl status ssh
  ```
* From host or Kali:

  ```bash
  ssh <youruser>@<ubuntu-ip>
  ```

### Snapshots

* In VirtualBox or VMware → Take Snapshot → Name it: `clean-install`

**Done when**

* You can SSH into `ubuntu-lab`
* Snapshot `clean-install` exists

---

## 1.4 Initialize Git Repository

```bash
cd ~/labs/cyber-lab
mkdir project-1-linux-lab
cd project-1-linux-lab
git init
mkdir notes scripts configs
touch README.md
```

**Done when**

* Repo contains `notes/`, `scripts/`, `configs/`

---

# 2️⃣ System Administration Fundamentals

## 2.1 Users, Groups, Permissions

### Tasks

* Create users:

  ```bash
  sudo adduser alice
  sudo adduser bob
  ```
* Create group `devs` and add users:

  ```bash
  sudo groupadd devs
  sudo usermod -aG devs alice
  sudo usermod -aG devs bob
  ```
* Create shared folder with setgid:

  ```bash
  sudo mkdir -p /srv/shared
  sudo chgrp devs /srv/shared
  sudo chmod 2770 /srv/shared
  ```
* Test permissions:

  ```bash
  sudo -u alice touch /srv/shared/file_by_alice
  sudo -u bob ls -l /srv/shared
  ```

### ACLs

* Install ACL tools:

  ```bash
  sudo apt install -y acl
  ```
* Add explicit ACL for bob:

  ```bash
  sudo setfacl -m u:bob:rwx /srv/shared/file_by_alice
  getfacl /srv/shared/file_by_alice
  ```

### Misconfigure sudo (intentionally)

* Backup sudoers:

  ```bash
  sudo cp /etc/sudoers ~/sudoers.backup
  ```
* Break sudo (edit `/etc/sudoers` with **nano**, not visudo)
* Confirm sudo fails
* Use root or recovery mode to restore:

  ```bash
  sudo cp ~/sudoers.backup /etc/sudoers
  ```

**Done when**

* You fixed the intentionally broken sudo
* `notes/users-permissions.md` contains:

  * chmod examples
  * ACL explanation
  * sudo break/fix write-up

---

## 2.2 Processes & Services

### Tasks

* Inspect processes:

  ```bash
  ps aux | head
  top
  htop
  ```
* List services:

  ```bash
  systemctl list-units --type=service | head
  ```

### Create a custom systemd service

* Create script:

  ```bash
  sudo tee /usr/local/bin/heartbeat.sh >/dev/null << 'EOF'
  #!/usr/bin/env bash
  while true; do
    echo "$(date) - heartbeat" >> /var/log/heartbeat.log
    sleep 10
  done
  EOF
  sudo chmod +x /usr/local/bin/heartbeat.sh
  ```
* Create service:

  ```bash
  sudo tee /etc/systemd/system/heartbeat.service >/dev/null << 'EOF'
  [Unit]
  Description=Simple Heartbeat Service

  [Service]
  ExecStart=/usr/local/bin/heartbeat.sh
  Restart=always

  [Install]
  WantedBy=multi-user.target
  EOF
  ```
* Enable and start:

  ```bash
  sudo systemctl daemon-reload
  sudo systemctl enable heartbeat
  sudo systemctl start heartbeat
  sudo systemctl status heartbeat
  tail -f /var/log/heartbeat.log
  ```

**Done when**

* `heartbeat.service` runs and survives reboot
* Documented in `notes/processes-services.md`

---

## 2.3 Networking Basics

### Tasks

* Check network info:

  ```bash
  ip a
  ip route
  ```
* Connectivity tests:

  ```bash
  ping -c 3 8.8.8.8
  ping -c 3 google.com
  ```
* List open ports:

  ```bash
  ss -tulnp
  ```

### Firewall configuration (UFW)

```bash
sudo apt install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw enable
sudo ufw status verbose
```

**Done when**

* You understand every firewall rule
* Documented in `notes/networking-basics.md`

---

# 3️⃣ Scripting & Automation

## 3.1 Bulk User Creation Script

**Location**: `scripts/bulk-create-users.sh`

```bash
#!/usr/bin/env bash
FILE="$1"
if [[ ! -f "$FILE" ]]; then
  echo "Usage: $0 users.txt"
  exit 1
fi
while read -r user; do
  if [[ -z "$user" ]]; then continue; fi
  if ! id "$user" &>/dev/null; then
    sudo adduser --disabled-password --gecos "" "$user"
  fi
  sudo usermod -aG devs "$user"
  echo "Processed: $user"
done < "$FILE"
```

**Done when**

* Script is executable and works idempotently

---

## 3.2 Backup Script + Cron

**Location**: `scripts/backup-home.sh`

```bash
#!/usr/bin/env bash
BACKUP_DIR="/backups"
mkdir -p "$BACKUP_DIR"
DATE=$(date +%Y%m%d)
TARGET="$BACKUP_DIR/home-$DATE.tar.gz"
tar -czf "$TARGET" /home
cd "$BACKUP_DIR" || exit
ls -1t home-*.tar.gz | tail -n +8 | xargs -r rm --
```

**Install cron job**:

```bash
sudo cp scripts/backup-home.sh /usr/local/bin/backup-home.sh
sudo chmod +x /usr/local/bin/backup-home.sh
crontab -e
```

Add:

```cron
0 3 * * * /usr/local/bin/backup-home.sh
```

**Done when**

* `/backups` contains rotating backups

---

## 3.3 Auth Log Parser

**Location**: `scripts/auth-log-summary.sh`

```bash
#!/usr/bin/env bash
LOG="/var/log/auth.log"
echo "Successful SSH logins by user:"
grep -E "Accepted password|Accepted publickey" "$LOG" | awk '{print $9}' | sort | uniq -c | sort -nr
echo
echo "Failed SSH attempts by IP:"
grep "Failed password" "$LOG" | awk '{print $11}' | sort | uniq -c | sort -nr
```

**Done when**

* Script prints readable stats

---

# 4️⃣ Hardening & Security

## 4.1 SSH hardening

### Tasks

* Edit `/etc/ssh/sshd_config`:

  ```text
  PermitRootLogin no
  PasswordAffentication no
  Port 2222
  ```
* Create SSH key on host:

  ```bash
  ssh-keygen -t ed25519

  ```
