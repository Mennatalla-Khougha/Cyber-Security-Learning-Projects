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
**Done when**

* Root cannot log in via SSH.

* Password login is disabled.

* You can still log in over SSH using key-based auth on port 2222.

---

## 4.2 System Hardening Basics
### Tasks
- List enabled services:
  ```bash
  systemctl list-unit-files --type=service | grep enabled
  ```
- Identify unnecessary services (examples: `cups`, `avahi-daemon`)
- Disable an unwanted service:
  ```bash
  sudo systemctl disable --now cups
  ```
- Configure stronger password policy:
  - Edit `/etc/login.defs` → increase `PASS_MIN_LEN` to 10 or more
  - Edit `/etc/pam.d/common-password` → enforce password history & complexity
- Document every change in `notes/system-hardening.md`

**Done when**
- Only essential services remain enabled
- Password policy is stricter than default
- All changes are documented

---

## 4.3 Firewall Hardening
### Tasks
- Ensure firewall defaults:
  ```bash
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  ```
- Allow required services only:
  ```bash
  sudo ufw allow 2222/tcp   # SSH on hardened port
  ```
- Delete unneeded rules:
  ```bash
  sudo ufw status numbered
  sudo ufw delete <rule-number>
  ```
- Export final ruleset:
  ```bash
  sudo ufw status verbose > configs/ufw-rules.txt
  ```

**Done when**
- Firewall contains ONLY the rules you can justify
- SSH (port 2222) works properly

---

## 4.4 Security Scanning with Lynis
### Tasks
- Install Lynis and run initial audit:
  ```bash
  sudo apt install -y lynis
  sudo lynis audit system | tee ~/lynis-initial.txt
  ```
- Choose 5–10 warnings to fix (SSH settings, password policy, logging, firewall)
- Apply the fixes
- Run second audit:
  ```bash
  sudo lynis audit system | tee ~/lynis-after.txt
  ```
- Compare scores and results
- Document findings in `notes/lynis-hardening.md`

**Done when**
- Initial and final Lynis logs exist
- At least several warnings are successfully fixed

---

# 5️⃣ Break–Fix Challenges
You will now *intentionally break your system* and learn how to recover.
Always take a snapshot before each challenge.

---

## Challenge 1 — Break SSH
### Tasks
- Break SSH by adding an invalid directive to `/etc/ssh/sshd_config`
- Attempt SSH from host → it should fail
- Log in locally using VM console
- Fix configuration and restart SSH:
  ```bash
  sudo systemctl restart ssh
  ```
- Confirm remote SSH works again

---

## Challenge 2 — Break Networking
### Tasks
- Remove default route:
  ```bash
  sudo ip route del default
  ```
- Test: `ping 8.8.8.8` should fail
- Restore networking by adding correct default route or fixing netplan config
- Confirm connectivity is restored

---

## Challenge 3 — Break sudo
### Tasks
- Break `/etc/sudoers` with nano (syntax error)
- Confirm: `sudo` fails
- Boot recovery mode OR switch to root session
- Restore from backup:
  ```bash
  sudo cp ~/sudoers.backup /etc/sudoers
  ```
- Confirm sudo works again

---

## Challenge 4 — Fill Disk Completely
### Tasks
- Fill disk:
  ```bash
  dd if=/dev/zero of=~/bigfile bs=1M count=50000
  ```
- Observe system failures (cannot write logs, apps crash)
- Delete file and free space:
  ```bash
  rm ~/bigfile
  ```
- Verify recovery with:
  ```bash
  df -h
  ```

---

## Break–Fix Documentation Requirements
Add an entry in `notes/break-fix.md` for each challenge:
- What was broken
- Exact commands used
- Symptoms observed
- Root cause
- Recovery steps
- What you learned

**Done when**
- `notes/break-fix.md` contains **4 complete incident write-ups**

---

# 6️⃣ Final Documentation & Deliverables

## 6.1 Recommended Repository Structure
```
project-1-linux-lab/
├── README.md
├── notes/
│   ├── users-permissions.md
│   ├── processes-services.md
│   ├── networking-basics.md
│   ├── system-hardening.md
│   ├── lynis-hardening.md
│   └── break-fix.md
├── scripts/
│   ├── bulk-create-users.sh
│   ├── backup-home.sh
│   └── auth-log-summary.sh
└── configs/
    ├── sshd_config.hardened
    └── ufw-rules.txt
```

---

## 6.2 Final Report
Create `Linux-Cyber-Lab-Report.md` containing:
- Lab architecture diagram (VMs, network mode, host relationships)
- Step-by-step instructions to recreate lab
- Summary of all scripts
- Hardening measures + reasoning
- Before/after Lynis results
- Three or more break–fix case studies

**Done when**
- Someone with basic Linux skills could rebuild your environment using only your report

---

# ✅ Completion Criteria Checklist
You are finished when ALL items below are true:
- Ubuntu & Kali lab VMs fully set up
- SSH hardened + working on custom port
- Firewall rules correct and documented
- Custom systemd service running
- All Bash scripts working and tested
- Lynis scans improved after fixes
- Four break–fix incidents documented
- Repo and documentation are complete

---

# 🎉 Project 1 COMPLETE
You now have a proper Linux cyber-lab foundation for the rest of the cybersecurity roadmap.


