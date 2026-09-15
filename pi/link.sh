#!/bin/bash
# Talk to the CC3200 ROM bootloader from a Raspberry Pi.
#
# The Pi's GPIO header has no DTR/RTS, so cc3200tool cannot do the reset itself: GPIO17 is
# pulsed here instead (RST is active low), and SOP2 is held high permanently by the wire to
# pin 1 (3V3) — so the box lands in the ROM bootloader on every reset.
#
#   ./link.sh list_filesystem
#   ./link.sh read_file /cert/ca.der cert/ca.der
#   ./link.sh write_file teddycloud-ca.der /cert/ca.der
#
# Everything after ./link.sh is passed to cc3200tool unchanged.
#
# env: RST_GPIO (default 17), SERIAL (default /dev/ttyAMA0), CC3200TOOL (default ~/cc3200/bin/cc3200tool)
set -e
RST_GPIO="${RST_GPIO:-17}"
SERIAL="${SERIAL:-/dev/ttyAMA0}"
CC3200TOOL="${CC3200TOOL:-$HOME/cc3200/bin/cc3200tool}"
WORKDIR="${WORKDIR:-$HOME/rip}"

[ -x "$CC3200TOOL" ] || { echo "cc3200tool not found at $CC3200TOOL — run setup-pi.sh"; exit 1; }
mkdir -p "$WORKDIR"
cd "$WORKDIR"

pinctrl set "$RST_GPIO" op dl      # drive RST low
sleep 0.3
pinctrl set "$RST_GPIO" ip         # release (input = hi-Z; the box's pull-up brings RST high)
sleep 1.0
exec "$CC3200TOOL" -p "$SERIAL" --reset none --sop2 none "$@"
