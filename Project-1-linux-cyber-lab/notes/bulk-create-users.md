# Bash Script: Add Users from a File

* Reads usernames from a text file
* Creates users if they don’t already exist
* Adds them to a `devs` group

---

## 1. Shebang & Interpreter Selection

```bash
#!/usr/bin/env bash
```

**Explanation:**

* This line tells the operating system to run the script using **Bash**.
* `/usr/bin/env` searches for `bash` in the current environment.
* This makes the script more portable across systems.

---

## 2. Reading the Input File Argument

```bash
FILE="$1"
```

**Explanation:**

* `$1` represents the **first command-line argument**.
* The script expects this argument to be a file containing usernames.
* Each line in the file should contain **one username**.

**Example usage:**

```bash
./bulk-create-users.sh users.txt
```

---

## 3. Validating the Input File

```bash
if [[ ! -f "$FILE" ]]; then
  echo "Usage: $0 users.txt"
  exit 1
fi
```

**Explanation:**

* `[[ -f "$FILE" ]]` checks whether the file exists and is a regular file.
* `!` negates the test (means *file does not exist*).
* If the file is missing:

  * A usage message is printed
  * The script exits with status code `1` (error)

---

## 4. Reading the File Line by Line

```bash
while read -r user; do
```

**Explanation:**

* Reads the input file **one line at a time**.
* Each line is stored in the variable `user`.
* `-r` prevents backslash escaping and makes input safer.

---

## 5. Skipping Empty Lines

```bash
if [[ -z "$user" ]]; then
  continue
fi
```

**Explanation:**

* `-z "$user"` checks if the line is empty.
* `continue` skips processing and moves to the next line.
* Prevents errors caused by blank lines in the file.

---

## 6. Checking if the User Already Exists

```bash
if ! id "$user" &>/dev/null; then
```

**Explanation:**

* `id "$user"` checks whether the user exists on the system.
* `&>/dev/null` suppresses all output.
* `!` inverts the result.
* This condition means:

  > If the user does NOT exist…

---

## 7. Creating the User

```bash
sudo adduser --disabled-password --gecos "" "$user"
```

**Explanation:**

* `sudo` runs the command with administrator privileges.
* `adduser` creates a new user.
* `--disabled-password` prevents password-based login.
* `--gecos ""` skips interactive prompts (name, phone, etc.).
* `$user` is the username being created.

---

## 8. Adding the User to the `devs` Group

```bash
sudo usermod -aG devs "$user"
```

**Explanation:**

* Modifies the user’s group membership.
* `-a` (append) ensures existing groups are not removed.
* `-G devs` adds the user to the `devs` group.
* Works for both new and existing users.

---

## 9. Progress Output

```bash
echo "Processed: $user"
```

**Explanation:**

* Prints a message indicating that the user has been handled.
* Useful for tracking progress during execution.

---

## 10. Ending the Loop and Reading the File

```bash
done < "$FILE"
```

**Explanation:**

* Ends the `while` loop.
* `< "$FILE"` redirects the file as input to the loop.
* Ensures each line of the file is processed sequentially.

---

## Summary

**What this script does:**

* Accepts a file of usernames
* Ignores empty lines
* Creates missing users
* Adds all users to the `devs` group
* Prints progress messages

---

## Example `users.txt`

```text
alice
bob
charlie
```

---