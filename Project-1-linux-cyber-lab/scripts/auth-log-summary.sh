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
