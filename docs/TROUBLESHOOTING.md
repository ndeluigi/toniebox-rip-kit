# Troubleshooting

## `Did not get ACK on break condition`

The bootloader never answered the break.

- **With a USB-UART adapter:** very likely the adapter cannot generate a break at all. Many
  FT232RL boards (newer revisions, mini-USB "2422 C" boards, all the USB-C ones tested on the
  RevvoX forum) have this problem. Test: loop TX to CTS, send a break, watch CTS — if it never goes
  low, the adapter is the problem. Use the Pi (this repo), a CP2102 board, or a DSD TECH SH-U09C5.
- **With the Pi:** check that `/dev/ttyAMA0` is the PL011 (`dtoverlay=disable-bt` in
  `config.txt`, rebooted), and that the serial console is off (`cmdline.txt` has no
  `console=serial0`).

## `Timed out while waiting for ack` / no answer at all

The box did not enter the bootloader.

- LED after reset should be **steady green, no jingle**. A jingle = SOP2 was not high → red wire
  (socket hole 9 → Pi pin 1) and plug pressure.
- Nothing happens on reset → blue wire (hole 4 → pin 11). You can watch it: `pinctrl get 17`.
- TX/RX swapped: box TX (hole 1) must go to Pi RXD (pin 10).
- The plug is not seated: the NL plug has no legs, press it flat on the pads, pin 1 on pad 1.

## `rx csum failed`

Bad ground or an underpowered box.

- green wire (hole 5 → pin 6) present and firm
- box on its battery or charger; **do not** power it from the Pi's 3V3
- shorter wires

## `read_all_files` stops early, or later commands in the same call never run

A missing expected file (e.g. `pref.net`) raises a warning that ends the whole chain.
Run `read_all_files` on its own and `read_flash` in a separate call — `backup.sh` already does.

## The box reboots into the bootloader forever after flashing

The SOP2 wire is still on. Remove the plug, power-cycle.

## Box does not show up in teddycloud after flashing

- DNS: from another LAN device, `nslookup prod.de.tbs.toys` must return teddycloud's IP.
- Power-cycle the box fully — it caches DNS answers.
- Blocklists: `rtnl.bxcl.de` is on common ad blocklists and resolves to `0.0.0.0` → allowlist it.
- teddycloud must answer on **port 443** at that IP (a macvlan IP works if the host's 443 is taken).
- Wrong CA flashed: `link.sh read_file /cert/ca.der x.der` and compare with teddycloud's
  `certs/server/ca.der`.

## Downloads fail inside teddycloud (`Access denied`, `Not connected`)

- teddycloud resolving `prod.de.tbs.toys` through your redirected DNS reaches *itself*. Give the
  container a real resolver: `--dns 1.1.1.1 --dns 8.8.8.8`.
- Client certs missing: `certs/client/` and `certs/client/<box-id>/` must both contain `ca.der`,
  `client.der`, `private.der` (restart teddycloud after copying).
- A figurine that keeps re-downloading while playing: pin it (`teddycloud/tc_pin.sh`).

## The tonies-app setup fails with "no connection to the cloud"

The DNS redirect is active while the box still has Boxine's CA. Remove the redirect, finish the
app setup, flash the CA, then add the redirect back.

## Useful references

- teddycloud wiki: <https://tonies-wiki.revvox.de/docs/tools/teddycloud/>
- CC3200 debug port: <https://tonies-wiki.revvox.de/docs/wiki/cc3200/debug-port/>
- RevvoX forum: <https://forum.revvox.de>
