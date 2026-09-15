#!/bin/bash
# Put the original (Boxine) CA back: the box goes back to the official cloud.
# Needs cert/ca.der from dump-certs.sh. Remember to remove the DNS redirect as well.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
WORKDIR="${WORKDIR:-$HOME/rip}"
ORIG="$WORKDIR/cert/ca.der"
TARGET="${TARGET:-/cert/ca.der}"

[ -f "$ORIG" ] || { echo "original CA not found at $ORIG"; exit 1; }
"$HERE/link.sh" write_file "$ORIG" "$TARGET"
"$HERE/link.sh" read_file "$TARGET" "$WORKDIR/verify-ca.der"
cmp -s "$ORIG" "$WORKDIR/verify-ca.der" && echo "restored - also remove the DNS records" || { echo "MISMATCH"; exit 1; }
