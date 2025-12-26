# Bash Script: `/home` Backup with Retention Policy

* Creates a compressed backup of `/home`
* Stores it in `/backups`
* Keeps only the **last 7 backups**
* Deletes older backups automatically
* Uses strict error handling for safety

---

## 1. Shebang & Interpreter

```bash
#!/usr/bin/env bash
```

**Explanation:**

* Tells the operating system to execute the script using **Bash**.
* Uses `/usr/bin/env` to locate Bash in the user’s environment, improving portability.

---

## 2. Enable Strict Mode

```bash
set -euo pipefail
```

**Explanation:**
This enables Bash **strict error handling**:

| Option     | Meaning                                |
| ---------- | -------------------------------------- |
| `-e`       | Exit immediately if any command fails  |
| `-u`       | Treat unset variables as errors        |
| `pipefail` | Fail the pipeline if any command fails |

**Why this matters:**
Prevents silent failures and ensures the script stops on unexpected issues.

---

## 3. Define and Create Backup Directory

```bash
BACKUP_DIR="/backups"
```

**Explanation:**

* Defines the directory where backups will be stored.

```bash
sudo mkdir -p "$BACKUP_DIR"
```

**Explanation:**

* Creates the backup directory if it does not exist.
* `-p` avoids errors if the directory already exists.
* `sudo` is required because `/backups` is typically root-owned.

---

## 4. Generate Backup Filename Using Date

```bash
DATE=$(date +%Y%m%d)
```

**Explanation:**

* Gets the current date in `YYYYMMDD` format.
* Used to create uniquely named daily backups.

```bash
TARGET="$BACKUP_DIR/home-$DATE.tar.gz"
```

**Explanation:**

* Builds the full path for the backup file.
* Example output:

  ```
  /backups/home-20251224.tar.gz
  ```

---

## 5. Create the Backup Archive

```bash
sudo tar -czf "$TARGET" /home
```

**Explanation:**

| Option | Description         |
| ------ | ------------------- |
| `-c`   | Create archive      |
| `-z`   | Compress using gzip |
| `-f`   | Specify output file |

* Archives the entire `/home` directory.
* Requires `sudo` to read all user directories.

---

## 6. Move into Backup Directory Safely

```bash
cd "$BACKUP_DIR" || exit 1
```

**Explanation:**

* Changes the working directory to `/backups`.
* If the directory change fails, the script exits immediately.

---

## 7. Retention Policy: Keep Only the Last 7 Backups

```bash
ls -1t home-*.tar.gz
```

**Explanation:**

* Lists backup files:

  * `-1` → One file per line
  * `-t` → Sorted by modification time (newest first)

---

```bash
tail -n +8
```

**Explanation:**

* Skips the first **7 files**.
* Outputs only older backups (starting from the 8th file).

---

```bash
xargs -r sudo rm --
```

**Explanation:**

| Component | Purpose                                     |
| --------- | ------------------------------------------- |
| `xargs`   | Pass filenames to another command           |
| `-r`      | Do nothing if input is empty                |
| `sudo rm` | Delete files with root permissions          |
| `--`      | Prevents filenames being treated as options |

**Effect:**
Deletes all backups older than the most recent 7.

---

## Summary

✔ Creates a daily compressed backup of `/home`
✔ Stores backups in `/backups`
✔ Keeps only the latest 7 backups
✔ Automatically removes old backups
✔ Uses safe Bash practices

---

## Example Backup Directory

```text
/backups/
├── home-20251224.tar.gz
├── home-20251223.tar.gz
├── home-20251222.tar.gz
├── home-20251221.tar.gz
├── home-20251220.tar.gz
├── home-20251219.tar.gz
├── home-20251218.tar.gz
```

Older backups are removed automatically.

---
