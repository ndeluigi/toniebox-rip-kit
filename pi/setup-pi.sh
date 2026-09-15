#!/bin/bash
# Prepare a Raspberry Pi (tested on a Pi 4 with Raspberry Pi OS Bookworm) to act as the
# UART adapter for a CC3200 Toniebox:
#
#   1. free the PL011 UART:  enable_uart=1 + dtoverlay=disable-bt
#      (without disable-bt the good UART belongs to the Bluetooth chip and /dev/ttyAMA0 is the
#       mini-UART, whose break generation is unreliable)
#   2. take the serial console off those pins, or Linux will talk over your session
#   3. install cc3200tool into ~/cc3200
#
# Run it once, then REBOOT. Needs sudo for the boot config only.
set -e

CONFIG=/boot/firmware/config.txt
CMDLINE=/boot/firmware/cmdline.txt
[ -f "$CONFIG" ] || CONFIG=/boot/config.txt          # pre-Bookworm layout
[ -f "$CMDLINE" ] || CMDLINE=/boot/cmdline.txt

echo "== boot config: $CONFIG"
sudo cp -n "$CONFIG" "$CONFIG.bak-riptkit" || true
grep -q '^enable_uart=1' "$CONFIG" || echo 'enable_uart=1' | sudo tee -a "$CONFIG" >/dev/null
grep -q '^dtoverlay=disable-bt' "$CONFIG" || echo 'dtoverlay=disable-bt' | sudo tee -a "$CONFIG" >/dev/null

echo "== serial console off: $CMDLINE"
sudo cp -n "$CMDLINE" "$CMDLINE.bak-riptkit" || true
sudo sed -i 's/console=serial0,[0-9]*[[:space:]]*//; s/console=ttyAMA0,[0-9]*[[:space:]]*//' "$CMDLINE"

echo "== disable the getty on the serial port"
sudo systemctl disable --now serial-getty@ttyAMA0.service 2>/dev/null || true
sudo systemctl disable --now hciuart.service 2>/dev/null || true

echo "== cc3200tool in ~/cc3200"
sudo apt-get update -qq
sudo apt-get install -y -qq python3-venv python3-pip git >/dev/null
python3 -m venv ~/cc3200
~/cc3200/bin/pip -q install --upgrade pip
~/cc3200/bin/pip -q install git+https://github.com/toniebox-reverse-engineering/cc3200tool.git
~/cc3200/bin/cc3200tool --help >/dev/null && echo "   cc3200tool ok"

echo "== your user must be in the 'dialout' group for /dev/ttyAMA0"
sudo usermod -aG dialout "$USER"

mkdir -p ~/rip
install -m 755 "$(dirname "$0")/link.sh" ~/rip/link.sh 2>/dev/null || true

cat <<'EOF'

Done. REBOOT now, then check:

    ls -l /dev/ttyAMA0          # exists, group dialout
    grep -c console=serial /boot/firmware/cmdline.txt   # must print 0

Then wire the box (see docs/GUIDE.md) and test the link with:

    ~/rip/link.sh list_filesystem
EOF
