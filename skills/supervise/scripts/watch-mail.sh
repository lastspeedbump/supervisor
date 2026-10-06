#!/usr/bin/env bash
# Watch a supervise mailbox and print one line per message addressed to <name>.
# Intended to run under a background monitor (Claude Code: Monitor), which turns
# each printed line into a notification that wakes the session.
#
# Usage: watch-mail.sh <mailbox-dir> <name> [interval-seconds]
#
# Messages already waiting when the watcher starts are reported on the first pass,
# so nothing that arrived between the last check and arming the watcher is missed.
# Exits when the mailbox directory disappears (the supervisor was finalized).

set -u
shopt -s nullglob

box="${1:?mailbox dir required}"
me="${2:?recipient name required}"
interval="${3:-5}"

snapshot() {
  local f
  for f in "$box"/*--to--"$me"--*.md; do
    printf '%s\n' "${f##*/}"
  done
}

seen=""
while true; do
  if [ ! -d "$box" ]; then
    echo "mailbox gone: $box (watcher stopping)"
    exit 0
  fi
  now="$(snapshot)"
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    case $'\n'"$seen"$'\n' in
      *$'\n'"$f"$'\n'*) ;;
      *) echo "new mail for $me: $f" ;;
    esac
  done <<< "$now"
  seen="$now"
  sleep "$interval"
done
