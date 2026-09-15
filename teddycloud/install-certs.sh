#!/bin/bash
# Install the certificates dumped from the box into teddycloud and restart it.
#
#   ./install-certs.sh <dir with ca.der client.der private.der> <box-id>
#
# <box-id>: the box's MAC without separators, lower case (e.g. b4107baabbcc).
# Recent teddycloud versions read certs/client/<box-id>/; older ones certs/client/ - both are filled.
#
# env: TEDDYCLOUD_DIR (default ~/teddycloud, the directory mounted as /teddycloud/certs's parent)
#      TEDDYCLOUD_CONTAINER (default teddycloud)
set -e
SRC="${1:?directory with ca.der client.der private.der}"
BOXID="$(echo "${2:?box id (MAC without separators)}" | tr 'A-Z' 'a-z' | tr -d ':-')"
TC="${TEDDYCLOUD_DIR:-$HOME/teddycloud}"
CONTAINER="${TEDDYCLOUD_CONTAINER:-teddycloud}"

for f in ca.der client.der private.der; do
  [ -s "$SRC/$f" ] || { echo "missing $SRC/$f"; exit 1; }
done

# The certs dir is usually root-owned (created by the container) -> copy through the container.
for d in "/teddycloud/certs/client" "/teddycloud/certs/client/$BOXID"; do
  docker exec "$CONTAINER" mkdir -p "$d"
  for f in ca.der client.der private.der; do
    docker cp "$SRC/$f" "$CONTAINER:$d/$f"
  done
  echo "installed into $d"
done

docker restart "$CONTAINER" >/dev/null
echo "teddycloud restarted. Check its log for the client certificate being loaded:"
echo "  docker logs --tail 50 $CONTAINER | grep -i cert"
