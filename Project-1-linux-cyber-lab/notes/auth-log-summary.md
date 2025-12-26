# SSH Authentication Log Analysis Script (Explained)

This document explains a Bash script that analyzes SSH authentication logs to:

* List **successful SSH logins by user**
* List **failed SSH login attempts by IP address**
* Rank results by frequency

---

## The Script

```bash
#!/usr/bin/env bash
set -euo pipefail

LOG="/var/log/auth.log"

echo "Successful SSH logins by user:"
sudo grep -E "Accepted password|Accepted publickey" "$LOG" \
  | awk '{print $9}' \
  | sort | uniq -c | sort -nr

echo
echo "Failed SSH attempts by IP:"
sudo grep "Failed password" "$LOG" \
  | awk '{print $11}' \
  | sort | uniq -c | sort -nr
```

---

## 1. Shebang & Shell Selection

```bash
#!/usr/bin/env bash
```

**Explanation:**

* Instructs the system to run the script using **Bash**.
* Uses `/usr/bin/env` for portability across systems.

---

## 2. Enable Safe Bash Mode

```bash
set -euo pipefail
```

**Explanation:**
This enables **strict error handling**:

| Option     | Meaning                               |
| ---------- | ------------------------------------- |
| `-e`       | Exit immediately if any command fails |
| `-u`       | Treat unset variables as errors       |
| `pipefail` | Pipeline fails if any command fails   |

**Why this matters:**
Prevents silent failures and ensures accurate log analysis.

---

## 3. Authentication Log File

```bash
LOG="/var/log/auth.log"
```

**Explanation:**

* Defines the SSH authentication log file.
* Common on **Debian / Ubuntu** systems.
* Contains records of:

  * Successful logins
  * Failed login attempts
  * Authentication methods used

> On RHEL/CentOS systems, this is usually `/var/log/secure`.

---

## 4. Successful SSH Logins (Grouped by User)

```bash
echo "Successful SSH logins by user:"
```

**Explanation:**

* Prints a heading for readability.

---

```bash
sudo grep -E "Accepted password|Accepted publickey" "$LOG" \
```

**Explanation:**

* Uses `grep` with **extended regex (`-E`)**.
* Filters log entries that indicate **successful SSH authentication**.
* Matches:

  * Password-based login
  * Public-key-based login
* `sudo` is required because auth logs are root-owned.

---

```bash
| awk '{print $9}' \
```

**Explanation:**

* Extracts the **username** field from each log line.
* In standard SSH logs, field 9 contains the username.

Example:

```text
Accepted publickey for alice from 192.168.1.10 port 22 ssh2
```

→ `$9 = alice`

---

```bash
| sort | uniq -c | sort -nr
```

**Explanation:**

* `sort` → Sort usernames
* `uniq -c` → Count occurrences
* `sort -nr` → Sort by count (highest first)

**Result:**
A ranked list of users by number of successful SSH logins.

---

## 5. Failed SSH Login Attempts (Grouped by IP)

```bash
echo
echo "Failed SSH attempts by IP:"
```

**Explanation:**

* Prints a blank line for separation.
* Prints a heading for failed login attempts.

---

```bash
sudo grep "Failed password" "$LOG" \
```

**Explanation:**

* Matches failed SSH password attempts.
* Common in:

  * Brute-force attacks
  * Incorrect password entries

---

```bash
| awk '{print $11}' \
```

**Explanation:**

* Extracts the **source IP address** from each failed attempt.
* In standard logs, field 11 contains the attacking IP.

Example:

```text
Failed password for invalid user root from 203.0.113.45 port 5555 ssh2
```

→ `$11 = 203.0.113.45`

---

```bash
| sort | uniq -c | sort -nr
```

**Explanation:**

* Sort IP addresses
* Count occurrences
* Rank by number of failed attempts

**Result:**
A list of IP addresses ordered by attack frequency.

---

## Output Example

```text
Successful SSH logins by user:
  12 alice
   6 bob
   2 admin

Failed SSH attempts by IP:
  94 203.0.113.45
  57 198.51.100.10
   9 192.0.2.7
```

---

## What This Script Is Used For

✔ Detect brute-force SSH attacks
✔ Identify frequently used accounts
✔ Security auditing
✔ Incident investigation
✔ Server hardening and monitoring

---

## Important Notes

* Field numbers (`$9`, `$11`) depend on log format.
* Log file path may differ across Linux distributions.
* Script is **read-only** and safe to run.
* Requires sudo privileges to read log files.

---

## Summary

| Section             | Purpose                    |
| ------------------- | -------------------------- |
| `grep Accepted`     | Find successful SSH logins |
| `awk '{print $9}'`  | Extract usernames          |
| `grep Failed`       | Find failed login attempts |
| `awk '{print $11}'` | Extract IP addresses       |
| `sort / uniq`       | Count and rank results     |

---
