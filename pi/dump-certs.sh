#!/bin/bash
# Pull the box's client certificate off it. These three files are what lets teddycloud talk to
# Boxine *as your box* (cloud passthrough), so your own content downloads keep working.
#
# They are secret: the private key is in there. Never publish them, never commit them.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
WORKDIR="${WORKDIR:-$HOME/rip}"
mkdir -p "$WORKDIR/cert"
cd "$WORKDIR"

"$HERE/link.sh" \
  read_file /cert/ca.der      cert/ca.der \
  read_file /cert/client.der  cert/client.der \
  read_file /cert/private.der cert/private.der

ls -la "$WORKDIR/cert/"
cat <<'EOF'

cert/ca.der       the CA the box trusts today (Boxine's) - keep it, it is your way back
cert/client.der   the box's client certificate
cert/private.der  its private key  <-- secret

Next: copy client.der, private.der and ca.der into teddycloud
      (teddycloud/install-certs.sh does it), then flash-ca.sh.

If your box has no /cert/ca.der, list what it does have with:
    ./link.sh list_filesystem
Some boxes use /cert/c2.der for a second CA instead.
EOF
