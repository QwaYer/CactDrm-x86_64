#!/usr/bin/env bash
# Sync the libdrm port with upstream — see sync.conf.
# The engine lives in the workspace's .cactsync/ directory.
#
#   ./sync.sh                        report drift (read-only; add --no-fetch)
#   ./sync.sh --to libdrm-2.4.135    rebase the Cact commits onto a newer tag
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if [ -z "${CACT_SYNC_HOME:-}" ]; then
  probe=$here
  while [ "$probe" != "/" ]; do
    if [ -x "$probe/.cactsync/cactsync.sh" ]; then
      CACT_SYNC_HOME=$probe/.cactsync
      break
    fi
    probe=$(dirname "$probe")
  done
fi

if [ -z "${CACT_SYNC_HOME:-}" ]; then
  echo "sync.sh: cannot locate the cactsync engine" >&2
  echo "         set CACT_SYNC_HOME to the directory holding cactsync.sh" >&2
  exit 1
fi

exec "$CACT_SYNC_HOME/cactsync.sh" --conf "$here/sync.conf" "$@"
