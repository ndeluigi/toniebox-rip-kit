#!/bin/bash
# Write teddycloud's CA onto the box, so the box trusts your server instead of Boxine's.
#
#   ./flash-ca.sh teddycloud-ca.der
#
# Get that file from your teddycloud host: certs/server/ca.der
# The original CA must already be dumped (dump-certs.sh) - restore-ca.sh needs it.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
WORKDIR="${WORKDIR:-$HOME/rip}"
CA="${1:-$WORKDIR/teddycloud-ca.der}"
TARGET="${TARGET:-/cert/ca.der}"

[ -f "$CA" ] || { echo "CA file not found: $CA"; exit 1; }
[ -f "$WORKDIR/cert/ca.der" ] || { echo "refusing: the original CA is not dumped yet (run dump-certs.sh)"; exit 1; }

echo "== writing $CA -> $TARGET"
"$HERE/link.sh" write_file "$CA" "$TARGET"

echo "== reading it back to verify"
"$HERE/link.sh" read_file "$TARGET" "$WORKDIR/verify-ca.der"
if cmp -s "$CA" "$WORKDIR/verify-ca.der"; then
  echo "   OK - the box now trusts your teddycloud CA"
else
  echo "   MISMATCH - do not power-cycle yet, try the write again"
  exit 1
fi
cat <<'EOF'

Now:
  1. point prod.de.tbs.toys and rtnl.bxcl.de at teddycloud in your DNS (see dns/)
  2. remove the SOP2 wire (ribbon pin 9), otherwise the box keeps booting into the bootloader
  3. power-cycle the box - it should appear in the teddycloud UI within a minute
EOF
