#!/bin/bash
# Evidencija – pokretanje unutar Home Assistant add-ona
OPT=/data/options.json
opt() { jq -r "$1 // empty" "$OPT" 2>/dev/null; }

mkdir -p /data/Podaci /data/tailscale /var/run/tailscale
TS=$(opt '.tailscale'); HOSTNAME_TS=$(opt '.tailscale_hostname'); KEY=$(opt '.tailscale_authkey')
[ -z "$HOSTNAME_TS" ] && HOSTNAME_TS=evidencija

APP_PID=""
TS_PID=""
zaustavi() {
  echo "[evidencija] zaustavljanje…"
  [ -n "$APP_PID" ] && kill -TERM "$APP_PID" 2>/dev/null && wait "$APP_PID" 2>/dev/null
  [ -n "$TS_PID" ] && kill -TERM "$TS_PID" 2>/dev/null
  exit 0
}
trap zaustavi TERM INT

if [ "$TS" = "true" ]; then
  echo "[tailscale] pokretanje (hostname: $HOSTNAME_TS)"
  tailscaled --tun=userspace-networking --statedir=/data/tailscale \
             --socket=/var/run/tailscale/tailscaled.sock --port=0 >/tmp/tailscaled.log 2>&1 &
  TS_PID=$!
  sleep 3
  (
    if [ -n "$KEY" ]; then
      tailscale up --hostname="$HOSTNAME_TS" --accept-dns=false --auth-key="$KEY" 2>&1
    else
      tailscale up --hostname="$HOSTNAME_TS" --accept-dns=false 2>&1
    fi | sed -u 's/^/[tailscale] /'
  ) &
  (
    for i in $(seq 1 1440); do
      st=$(tailscale status --json 2>/dev/null | jq -r '.BackendState')
      if [ "$st" = "Running" ]; then
        tailscale funnel --bg 5080 2>&1 | sed -u 's/^/[tailscale] /'
        ime=$(tailscale status --json | jq -r '.Self.DNSName' | sed 's/\.$//')
        adresa="https://$ime/"
        echo "[tailscale] =============================================="
        echo "[tailscale] Javna adresa aplikacije: $adresa"
        echo "[tailscale] =============================================="
        if [ "$(cat /data/javna_adresa 2>/dev/null)" != "$adresa" ]; then
          echo "$adresa" > /data/javna_adresa
          # aplikacija se ponovno pokreće da preuzme javnu adresu
          [ -f /tmp/app.pid ] && kill -TERM "$(cat /tmp/app.pid)" 2>/dev/null
        fi
        break
      fi
      [ "$i" = "1" ] && echo "[tailscale] čekam prijavu – otvorite gornju poveznicu (login.tailscale.com) i prijavite se"
      sleep 5
    done
  ) &
else
  echo "[tailscale] isključeno – aplikacija je dostupna samo u lokalnoj mreži (port 5080)"
fi

cd /app
while true; do
  if [ -f /data/javna_adresa ]; then export JavnaAdresa="$(cat /data/javna_adresa)"; fi
  echo "[evidencija] pokretanje aplikacije"
  dotnet LuFazan.Evidencija.dll &
  APP_PID=$!
  echo "$APP_PID" > /tmp/app.pid
  wait "$APP_PID"
  echo "[evidencija] aplikacija završila (kod $?) – ponovno pokretanje za 2 s"
  sleep 2
done
