# DNS redirect

The box finds its cloud by name. Two names must resolve to **teddycloud's box-facing IP** (the
address where teddycloud answers on port 443):

```
prod.de.tbs.toys
rtnl.bxcl.de
```

Add them **after** flashing the CA (GUIDE step 10), never before the tonies-app setup is done.

## Pi-hole (v6)

Web UI: *Local DNS → DNS Records*, add both names with teddycloud's IP.

CLI — careful, this **replaces the whole list**, so read it first and include the existing entries:

```bash
docker exec pihole pihole-FTL --config dns.hosts          # show current list
docker exec pihole pihole-FTL --config dns.hosts '[ "…existing entries…", "192.168.0.250 prod.de.tbs.toys", "192.168.0.250 rtnl.bxcl.de" ]'
docker exec pihole sh -c 'kill -HUP $(pidof pihole-FTL)'  # flush the cache
```

Also **allowlist** both names: `rtnl.bxcl.de` is on the StevenBlack list and would otherwise
resolve to `0.0.0.0`.

If your network hands out **two DNS servers**, add the records to both — the box uses whichever
answers.

## dnsmasq / OpenWrt / many routers

```
address=/prod.de.tbs.toys/192.168.0.250
address=/rtnl.bxcl.de/192.168.0.250
```

## AdGuard Home

*Filters → DNS rewrites*, one rewrite per name.

## Check

From any LAN device (not the teddycloud host itself if teddycloud uses a macvlan IP):

```bash
nslookup prod.de.tbs.toys
nslookup rtnl.bxcl.de
```

Both must return teddycloud's IP. Then power-cycle the box fully; it caches answers.

## teddycloud itself must NOT use this redirect

teddycloud forwards your box's requests to the real Boxine cloud. If its container resolves
through the same DNS, it reaches itself and every download fails. Give the container its own
resolver:

```bash
docker run … --dns 1.1.1.1 --dns 8.8.8.8 … ghcr.io/toniebox-reverse-engineering/teddycloud:latest
```
