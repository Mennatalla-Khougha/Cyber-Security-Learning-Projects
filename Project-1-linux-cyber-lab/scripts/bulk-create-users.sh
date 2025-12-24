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

