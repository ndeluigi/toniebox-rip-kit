#!/bin/bash
# FULL BACKUP — run this before writing anything to the box, no exceptions.
#
# Produces, in ~/rip (or $WORKDIR):
#   backup/      every file cc3200tool can pull off the filesystem
#   backup.bin   the raw 4 MB serial-flash image
#
# Copy both somewhere else afterwards. They are the only way back if a write goes wrong.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
WORKDIR="${WORKDIR:-$HOME/rip}"
mkdir -p "$WORKDIR/backup"
cd "$WORKDIR"

echo "== filesystem backup -> $WORKDIR/backup/"
# NOTE: run this on its own. Chaining it with other subcommands aborts the rest of the chain
# as soon as one expected file is missing (e.g. pref.net on some boxes).
"$HERE/link.sh" read_all_files backup/ || echo "   (warnings about individual missing files are normal)"

echo "== raw flash image -> $WORKDIR/backup.bin"
"$HERE/link.sh" read_flash backup.bin

ls -la "$WORKDIR/backup.bin"
echo
echo "Expect roughly 4 MB. Keep backup/ and backup.bin forever."
sha256sum "$WORKDIR/backup.bin" | tee "$WORKDIR/backup.bin.sha256"
