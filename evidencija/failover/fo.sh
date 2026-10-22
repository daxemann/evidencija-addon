#!/bin/bash
# Evidencija – Ausfall-Server (Failover) zwischen zwei Home-Assistant-Standorten.
# Gleiche Adresse (evidencija.<tailnet>.ts.net), zwei Server, immer nur EINER online.
#
#   fo.sh daemon            Hauptschleife (startet aus run.sh)
#   fo.sh <befehl> [...]    einzelne Aktionen (von api.php aufgerufen)
#
# Rollen:  aktivan  = betreibt die Evidencija-Adresse
#          pripravan = Standby, holt Kopien, übernimmt bei Ausfall
# Grundsatz: „wer läuft, bleibt“ – kein automatisches Zurückschalten.

set -u
OPT=/data/options.json
opt() { jq -r "$1 // empty" "$OPT" 2>/dev/null; }

FO=/data/failover
RUN=/run/fo
WARTUNG=/run/evidencija/wartung
CTLSOCK=/var/run/tailscale/ctl.sock
EVSOCK=/var/run/tailscale/tailscaled.sock
PROXY=http://127.0.0.1:1055
LOCK=$RUN/lock

GRACE=300          # Sekunden ohne Partner + ohne Adresse, bis übernommen wird
GRACE_HART=900     # wenn Tailscale den Knoten noch als „online“ meldet
GRACE_GEPLANT=1800 # nach angekündigtem Neustart des Partners
SYNC_STUNDEN="03 11 19"

LOK=$(opt '.failover_lokacija' | tr '[:lower:]' '[:upper:]')
PARTNER=$(opt '.failover_partner')
NOTIFY=$(opt '.failover_obavijest')
CTL_HOST="evidencija-ctl-$(echo "$LOK" | tr '[:upper:]' '[:lower:]')"
EV_HOST=$(opt '.tailscale_hostname'); [ -z "$EV_HOST" ] && EV_HOST=evidencija

mkdir -p "$FO" "$RUN" /run/evidencija /var/run/tailscale

log() { if [ -w /proc/1/fd/1 ]; then echo "[failover] $*" >> /proc/1/fd/1; else echo "[failover] $*" >&2; fi; }
jetzt() { date +%s; }
uloga() { cat "$FO/uloga" 2>/dev/null || echo ""; }
postavi_ulogu() {
  local alt; alt=$(uloga)
  echo "$1" > "$FO/uloga"
  if [ "$1" = aktivan ] && [ "$alt" != aktivan ]; then jetzt > "$FO/aktivan_od"; fi
}
razvoj_lokal() { [ -f "$FO/razvoj" ]; }

verzija() {
  if [ ! -s "$RUN/verzija" ]; then
    curl -sf -H "Authorization: Bearer ${SUPERVISOR_TOKEN:-}" http://supervisor/addons/self/info 2>/dev/null \
      | jq -r '.data.version // empty' > "$RUN/verzija.tmp" && mv "$RUN/verzija.tmp" "$RUN/verzija"
  fi
  cat "$RUN/verzija" 2>/dev/null
}
slug() {
  curl -sf -H "Authorization: Bearer ${SUPERVISOR_TOKEN:-}" http://supervisor/addons/self/info 2>/dev/null | jq -r '.data.slug // empty'
}

# ---------------------------------------------------------------- Tailscale: Steuerknoten (immer an)
ctl() { tailscale --socket="$CTLSOCK" "$@"; }
ctl_laeuft() { [ "$(ctl status --json 2>/dev/null | jq -r '.BackendState')" = Running ]; }

ctl_start() {
  mkdir -p /data/tailscale-ctl
  if ! pgrep -f "socket=$CTLSOCK" >/dev/null; then
    log "Steuerknoten $CTL_HOST startet"
    tailscaled --tun=userspace-networking --statedir=/data/tailscale-ctl --socket="$CTLSOCK" --port=0 \
      --outbound-http-proxy-listen=127.0.0.1:1055 >/tmp/tailscaled-ctl.log 2>&1 &
    sleep 3
    ( ctl up --hostname="$CTL_HOST" --accept-dns=false 2>&1 | sed -u 's/^/[failover] Steuerknoten: /' ) &
  fi
}
ctl_serve() {
  # Steuer-API nur im Tailnet (kein Funnel)
  ctl serve status 2>/dev/null | grep -q 5081 || ctl serve --bg --http=80 http://127.0.0.1:5081 >/dev/null 2>&1
}
dns_suffix() { ctl status --json 2>/dev/null | jq -r '.MagicDNSSuffix // empty'; }

# Ist der Evidencija-Knoten gerade irgendwo online? (Sicht des Steuerknotens)
ev_online_irgendwo() {
  ctl status --json 2>/dev/null | jq -e --arg h "$EV_HOST." \
    '[.Peer[]? | select((.DNSName // "") | startswith($h)) | select(.Online == true)] | length > 0' >/dev/null
}

# ---------------------------------------------------------------- Tailscale: Evidencija-Knoten (nur aktiv)
ev() { tailscale --socket="$EVSOCK" "$@"; }
ev_laeuft_lokal() { pgrep -f "socket=$EVSOCK" >/dev/null; }

ev_start() {
  mkdir -p /data/tailscale
  if ! ev_laeuft_lokal; then
    log "Evidencija-Adresse ($EV_HOST) wird hier gestartet"
    tailscaled --tun=userspace-networking --statedir=/data/tailscale --socket="$EVSOCK" --port=0 >/tmp/tailscaled.log 2>&1 &
    sleep 3
  fi
  ev up --hostname="$EV_HOST" --accept-dns=false >/dev/null 2>&1 &
  for _ in $(seq 1 60); do
    if [ "$(ev status --json 2>/dev/null | jq -r '.BackendState')" = Running ]; then
      ev funnel --bg 5080 >/dev/null 2>&1
      local ime adresa
      ime=$(ev status --json | jq -r '.Self.DNSName' | sed 's/\.$//')
      adresa="https://$ime/"
      [ "$(cat /data/javna_adresa 2>/dev/null)" != "$adresa" ] && echo "$adresa" > /data/javna_adresa
      echo "$adresa" > "$FO/adresa"
      log "Evidencija online: $adresa"
      return 0
    fi
    sleep 2
  done
  log "WARNUNG: Evidencija-Knoten kam nicht hoch (Anmeldung nötig? siehe /tmp/tailscaled.log)"
  return 1
}

ev_stop() {
  if ev_laeuft_lokal; then
    log "Evidencija-Adresse wird hier abgeschaltet"
    ev funnel --https=443 off >/dev/null 2>&1
    ev down >/dev/null 2>&1
    pkill -TERM -f "socket=$EVSOCK"; sleep 2; pkill -KILL -f "socket=$EVSOCK" 2>/dev/null
  fi
  return 0
}

# ---------------------------------------------------------------- Partner
partner_url() { local s; s=$(dns_suffix); [ -n "$PARTNER" ] && [ -n "$s" ] && echo "http://$PARTNER.$s"; }
pc() { # pc GET|POST /pfad [timeout] [zusätzliche curl-Optionen…]
  local m=$1 p=$2 t=${3:-15}; shift 3 2>/dev/null || shift $#
  local u; u=$(partner_url) || return 1; [ -z "$u" ] && return 1
  curl -sf --max-time "$t" --proxy "$PROXY" -X "$m" "$@" "$u$p"
}
partner_status() { pc GET /status 10 > "$RUN/partner.json.tmp" && mv "$RUN/partner.json.tmp" "$RUN/partner.json" && jetzt > "$RUN/partner_ok"; }
pj() { jq -r "$1 // empty" "$RUN/partner.json" 2>/dev/null; }
partner_frisch() { [ $(( $(jetzt) - $(cat "$RUN/partner_ok" 2>/dev/null || echo 0) )) -lt 120 ]; }

adresse_erreichbar() {
  local a; a=$(cat "$FO/adresa" 2>/dev/null); [ -z "$a" ] && a=$(cat /data/javna_adresa 2>/dev/null)
  [ -z "$a" ] && return 1
  local kod; kod=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "$a")
  [ "$kod" != 000 ] && [ "$kod" -lt 500 ] 2>/dev/null
}

razvoj_aktiv() { razvoj_lokal || { partner_frisch && [ "$(pj .razvoj)" = true ]; }; }

# ---------------------------------------------------------------- Home Assistant
ha_state() { # ha_state entity state [attributes-json]
  local attrs=${3:-'{}'}
  curl -sf --max-time 5 -X POST -H "Authorization: Bearer ${SUPERVISOR_TOKEN:-}" -H 'Content-Type: application/json' \
    -d "$(jq -cn --arg s "$2" --argjson a "$attrs" '{state:$s, attributes:$a}')" \
    "http://supervisor/core/api/states/$1" >/dev/null 2>&1
}
ha_get() { curl -sf --max-time 5 -H "Authorization: Bearer ${SUPERVISOR_TOKEN:-}" "http://supervisor/core/api/states/$1" 2>/dev/null | jq -r '.state // empty'; }
melde() { # melde "Titel" "Text"
  log "MELDUNG: $1 – $2"
  local body; body=$(jq -cn --arg t "$1" --arg m "$2" '{title:$t, message:$m}')
  curl -sf --max-time 5 -X POST -H "Authorization: Bearer ${SUPERVISOR_TOKEN:-}" -H 'Content-Type: application/json' \
    -d "$body" http://supervisor/core/api/services/persistent_notification/create >/dev/null 2>&1
  if [ -n "$NOTIFY" ]; then
    curl -sf --max-time 5 -X POST -H "Authorization: Bearer ${SUPERVISOR_TOKEN:-}" -H 'Content-Type: application/json' \
      -d "$body" "http://supervisor/core/api/services/notify/${NOTIFY#notify.}" >/dev/null 2>&1
  fi
}

# ---------------------------------------------------------------- Kopie (Snapshot)
snimka() { # erzeugt Snapshot, gibt Pfad aus
  local t; t=$(mktemp -d "$FO/snimka.XXXX")
  touch /data/javna_adresa; mkdir -p /data/tailscale
  php /failover/snimka.php "$t" "$(verzija)" "$LOK" >/dev/null || { rm -rf "$t"; return 1; }
  tar czf "$t.tgz" -C /data --exclude='Podaci/evidencija.db' --exclude='Podaci/evidencija.db-*' \
      --exclude='Podaci/kopije' Podaci tailscale javna_adresa -C "$t" evidencija.db meta.json 2>/dev/null \
    || { rm -rf "$t" "$t.tgz"; return 1; }
  rm -rf "$t"
  echo "$t.tgz"
}

uvoz() { # uvoz datei.tgz [arhiviraj]
  local f=$1 arh=${2:-0}
  [ "$(uloga)" = aktivan ] && { log "Import abgelehnt: dieser Server ist aktiv"; return 1; }
  local n="$FO/novo"; rm -rf "$n"; mkdir -p "$n"
  tar xzf "$f" -C "$n" || { log "Import: Archiv defekt"; rm -rf "$n"; return 1; }
  local v; v=$(jq -r '.verzija' "$n/meta.json" 2>/dev/null)
  if [ "$v" != "$(verzija)" ]; then
    log "Import abgelehnt: Version Kopie $v ≠ hier $(verzija)"; rm -rf "$n"; echo "$v" > "$RUN/sync_fehler"; return 2
  fi
  php /failover/provjera.php "$n/evidencija.db" || { log "Import: Datenbank-Prüfung fehlgeschlagen"; rm -rf "$n"; return 1; }
  mv "$n/evidencija.db" "$n/Podaci/evidencija.db"
  if [ "$arh" = 1 ] && [ -d /data/Podaci ]; then
    mkdir -p "$FO/arhiva"; local ziel; ziel="$FO/arhiva/$(date +%Y%m%d-%H%M%S)"
    mv /data/Podaci "$ziel"; log "Alter Stand archiviert: $ziel"
    ls -1d "$FO"/arhiva/* 2>/dev/null | head -n -2 | xargs -r rm -rf   # nur die letzten 2
  else
    rm -rf "$FO/prethodno"; [ -d /data/Podaci ] && mv /data/Podaci "$FO/prethodno"
  fi
  mv "$n/Podaci" /data/Podaci
  # Uploads/Kopien, die nicht übertragen werden, behalten
  [ -d "$FO/prethodno/kopije" ] && [ ! -d /data/Podaci/kopije ] && cp -a "$FO/prethodno/kopije" /data/Podaci/
  rm -rf "$FO/partner_ts"; [ -d "$n/tailscale" ] && mv "$n/tailscale" "$FO/partner_ts"
  [ -f "$n/javna_adresa" ] && cp "$n/javna_adresa" "$FO/adresa"
  chown -R www-data:www-data /data/Podaci
  rm -rf "$n" "$RUN/sync_fehler"
  date -Iseconds > "$FO/zadnja_sink"
  log "Import fertig ($(du -sh /data/Podaci | cut -f1))"
}

povuci() { # povuci [arhiviraj]  – Kopie vom aktiven Partner holen und einspielen
  local f="$FO/dolazna.tgz"
  pc GET /snimka 600 -o "$f" || { log "Kopie holen fehlgeschlagen"; rm -f "$f"; return 1; }
  uvoz "$f" "${1:-0}"; local r=$?; rm -f "$f"; return $r
}

# ---------------------------------------------------------------- Rollenwechsel
preuzmi() { # Übernahme mit der zuletzt kopierten Identität
  [ -d "$FO/partner_ts" ] && { rm -rf /data/tailscale; cp -a "$FO/partner_ts" /data/tailscale; }
  [ -d /data/tailscale ] || { log "Übernahme unmöglich: keine Tailscale-Identität vorhanden"; return 1; }
  postavi_ulogu aktivan
  if ev_start; then rm -f "$WARTUNG"; return 0; fi
  return 1
}

planirana_predaja() { # dieser Server übernimmt geplant vom aktiven Partner
  log "Geplanter Wechsel: $PARTNER → $LOK"
  pc POST /predaja/priprema 30 >/dev/null || { log "Partner antwortet nicht"; return 1; }
  if ! povuci 1; then pc POST /predaja/odustani 30 >/dev/null; return 1; fi
  if ! pc POST /predaja/otpusti 60 >/dev/null; then pc POST /predaja/odustani 30 >/dev/null; return 1; fi
  for _ in $(seq 1 45); do ev_online_irgendwo || break; sleep 2; done
  if preuzmi; then
    melde "Evidencija: Wechsel fertig" "Aktiver Server ist jetzt $LOK."
    return 0
  fi
  log "Übernahme fehlgeschlagen – Partner übernimmt wieder"
  postavi_ulogu pripravan; touch "$WARTUNG"; ev_stop
  pc POST /predaja/vrati 60 >/dev/null
  melde "Evidencija: Wechsel fehlgeschlagen" "$LOK konnte nicht starten, $PARTNER ist wieder aktiv."
  return 1
}

# Befehle, die der Partner über api.php auslöst (laufen unter Sperre)
cmd_priprema() { [ "$(uloga)" = aktivan ] || return 1; touch "$WARTUNG"; log "Wechsel angefragt – Wartungsmodus"; }
cmd_odustani() { [ "$(uloga)" = aktivan ] && rm -f "$WARTUNG"; log "Wechsel abgebrochen"; }
cmd_otpusti()  { ev_stop; postavi_ulogu pripravan; touch "$WARTUNG"; log "Übergeben an $PARTNER – hier Standby"; }
cmd_vrati()    { postavi_ulogu aktivan; ev_start && rm -f "$WARTUNG"; }
cmd_preuzmi_od_mene() { # Partner bittet: übernimm du (wird asynchron ausgeführt)
  [ "$(uloga)" = pripravan ] || return 1
  razvoj_lokal && return 1
  flock -n "$LOCK" true || { log "Wechsel-Anfrage abgelehnt: gerade beschäftigt"; return 1; }
  ( flock -o -n "$LOCK" /failover/fo.sh planirana_predaja ) >/dev/null 2>&1 &
}
cmd_najava() { echo $(( $(jetzt) + GRACE_GEPLANT )) > "$RUN/najava_do"; log "Partner kündigt Neustart an"; }

azuriraj_sebe() {
  local s; s=$(slug); [ -z "$s" ] && return 1
  log "Add-on-Update wird angestoßen ($s)"
  curl -sf --max-time 60 -X POST -H "Authorization: Bearer ${SUPERVISOR_TOKEN:-}" http://supervisor/store/reload >/dev/null
  curl -sf --max-time 5 -X POST -H "Authorization: Bearer ${SUPERVISOR_TOKEN:-}" -H 'Content-Type: application/json' \
    -d '{"backup":false}' "http://supervisor/store/addons/$s/update" >/dev/null
  return 0
}

# ---------------------------------------------------------------- Anzeige in Home Assistant
objavi() {
  local u; u=$(uloga)
  local aktivni="keiner" ok=false pver="" pul="" rv=false
  partner_frisch && { ok=true; pver=$(pj .verzija); pul=$(pj .uloga); }
  if [ "$u" = aktivan ]; then aktivni=$LOK
  elif [ "$pul" = aktivan ]; then aktivni=$PARTNER_LOK
  elif adresse_erreichbar; then aktivni="unbekannt"; fi
  [ -f "$RUN/predaja" ] && aktivni="Übergabe"
  razvoj_aktiv && rv=true
  local status="OK"
  if $rv; then status="Entwicklung – keine Übernahme"
  elif ! $ok; then status="Partner nicht erreichbar"
  elif [ -n "$pver" ] && [ "$pver" != "$(verzija)" ]; then status="Versionen ungleich – Sync gestoppt"
  elif [ -f "$RUN/sync_fehler" ]; then status="Sync-Fehler"; fi
  local zs; zs=$( [ "$u" = aktivan ] && pj .zadnja_sink || cat "$FO/zadnja_sink" 2>/dev/null )
  local starije=""
  if [ -n "$pver" ] && [ "$pver" != "$(verzija)" ]; then
    if [ "$(printf '%s\n%s\n' "$pver" "$(verzija)" | sort -V | head -1)" = "$(verzija)" ]; then starije=$LOK; else starije=$PARTNER_LOK; fi
  fi
  ha_state sensor.evidencija_aktiver_server "$aktivni" "$(jq -cn \
    --arg ich "$LOK" --arg rolle "$u" --arg partner "$PARTNER_LOK" --argjson pok "$ok" --arg pr "$pul" \
    --arg vl "$(verzija)" --arg vp "$pver" --arg st "$status" --argjson rv "$rv" --arg zs "$zs" --arg alt "$starije" \
    '{friendly_name:"Evidencija aktiver Server", icon:"mdi:server-network", dieser_server:$ich, rolle_hier:$rolle,
      partner:$partner, partner_erreichbar:$pok, rolle_partner:$pr, version_hier:$vl, version_partner:$vp,
      status:$st, entwicklung:$rv, letzter_sync:$zs, aelter:$alt}')"
  ha_state sensor.evidencija_failover_status "$status" '{"friendly_name":"Evidencija Ausfall-Server","icon":"mdi:shield-sync"}'
  [ -n "$zs" ] && ha_state sensor.evidencija_letzter_sync "$zs" '{"friendly_name":"Evidencija letzter Sync","device_class":"timestamp"}'
  ha_state binary_sensor.evidencija_partner_erreichbar "$($ok && echo on || echo off)" \
    "{\"friendly_name\":\"Evidencija Partner ($PARTNER_LOK) erreichbar\",\"device_class\":\"connectivity\"}"
}

# Tasten/Schalter im Dashboard (nur dort, wo die Helfer existieren)
taste() { # taste entity -> 0 wenn neu gedrückt
  local v; v=$(ha_get "$1"); [ -z "$v" ] && return 1
  local f="$RUN/btn_$1"
  if [ ! -f "$f" ]; then echo "$v" > "$f"; return 1; fi
  [ "$(cat "$f")" = "$v" ] && return 1
  echo "$v" > "$f"; [ "$v" != unavailable ] && [ "$v" != unknown ]
}
dashboard() {
  local e; e=$(ha_get input_boolean.evidencija_entwicklung)
  if [ "$e" = on ] && ! razvoj_lokal; then jetzt > "$FO/razvoj"; log "Entwicklung EIN – keine Übernahme, kein Sync"; fi
  if [ "$e" = off ] && razvoj_lokal; then rm -f "$FO/razvoj"; log "Entwicklung AUS – Versionsvergleich"; jetzt > "$RUN/sync_jetzt"; fi
  if taste input_button.evidencija_wechseln; then
    if [ "$(uloga)" = pripravan ]; then
      ( flock -o -n "$LOCK" /failover/fo.sh planirana_predaja || log "Wechsel nicht gestartet: gerade beschäftigt" ) &
    else
      pc POST /predaja/preuzmi_od_mene 30 >/dev/null && log "Partner übernimmt jetzt" || melde "Evidencija" "Wechsel nicht möglich – Partner nicht bereit."
    fi
  fi
  taste input_button.evidencija_sync_jetzt && jetzt > "$RUN/sync_jetzt"
  if taste input_button.evidencija_aktualisieren; then
    local pv; pv=$(pj .verzija)
    if [ -z "$pv" ] || [ "$pv" = "$(verzija)" ]; then melde "Evidencija" "Beide Server haben dieselbe Version."
    elif [ "$(printf '%s\n%s\n' "$pv" "$(verzija)" | sort -V | head -1)" = "$(verzija)" ]; then azuriraj_sebe
    else pc POST /azuriraj 30 >/dev/null && log "Update beim Partner angestoßen"; fi
  fi
}

# ---------------------------------------------------------------- Hauptschleife
daemon() {
  PARTNER_LOK=$(echo "$PARTNER" | sed 's/^evidencija-ctl-//' | tr '[:lower:]' '[:upper:]')
  export PARTNER_LOK
  [ -z "$(uloga)" ] && postavi_ulogu "$(opt '.failover_pocetna_uloga' | sed 's/^$/aktivan/')"
  log "Start – Standort $LOK, Partner $PARTNER, Rolle $(uloga)"
  touch "$WARTUNG"            # sicher starten
  ctl_start

  # warten, bis der Steuerknoten läuft (max. 3 min)
  # (bei noch nie angemeldetem Steuerknoten nicht warten – Anmeldelink kommt im Log)
  for _ in $(seq 1 90); do
    ctl_laeuft && break
    [ "$(ctl status --json 2>/dev/null | jq -r '.BackendState')" = NeedsLogin ] && break
    sleep 2
  done
  if ctl_laeuft; then ctl_serve; partner_status; else log "WARNUNG: Steuerknoten nicht angemeldet – Anmeldelink im Log"; fi

  if [ "$(uloga)" = aktivan ]; then
    if ctl_laeuft && { ev_online_irgendwo || { partner_frisch && [ "$(pj .uloga)" = aktivan ]; }; }; then
      log "Partner ist inzwischen aktiv – dieser Server wird Standby"
      postavi_ulogu pripravan; touch "$FO/povratak"
      melde "Evidencija: $LOK wieder online" "$LOK läuft als Standby, $PARTNER_LOK bleibt aktiv. Daten werden vollständig übernommen."
    else
      ev_start && rm -f "$WARTUNG"
    fi
  fi

  local bez_partnera bez_adrese zadnji_sat=""
  # bez_adrese=0: beim Start sofort prüfen, ob die Adresse fehlt (z. B. nach abgebrochenem Wechsel)
  bez_partnera=$(jetzt); bez_adrese=0
  while true; do
    ctl_laeuft && ctl_serve
    if partner_status; then bez_partnera=$(jetzt); fi

    if [ "$(uloga)" = aktivan ]; then
      ev_laeuft_lokal || { log "Evidencija-Knoten weg – Neustart"; ev_start; }
      # beide aktiv? Wer später aktiv wurde, bleibt.
      if partner_frisch && [ "$(pj .uloga)" = aktivan ] && [ "$(pj .aktivan_od)" -gt "$(cat "$FO/aktivan_od" 2>/dev/null || echo 0)" ] 2>/dev/null; then
        log "Doppelt aktiv – Partner ist neuer, dieser Server geht in Standby"
        ( flock -o "$LOCK" /failover/fo.sh otpusti ); touch "$FO/povratak"
      fi
      bez_adrese=$(jetzt)
    else
      adresse_erreichbar && bez_adrese=$(jetzt)
      # --- Sync
      local sat; sat=$(date +%H)
      local faellig=0
      [ -f "$RUN/sync_jetzt" ] && faellig=1
      [ -f "$FO/povratak" ] && faellig=1
      [ ! -f "$FO/zadnja_sink" ] && faellig=1
      if echo " $SYNC_STUNDEN " | grep -q " $sat " && [ "$zadnji_sat" != "$sat" ]; then faellig=1; zadnji_sat=$sat; fi
      if [ $faellig = 1 ] && ! razvoj_aktiv && partner_frisch && [ "$(pj .uloga)" = aktivan ]; then
        if [ "$(pj .verzija)" = "$(verzija)" ]; then
          log "Sync: Kopie von $PARTNER_LOK"
          if ( flock -o "$LOCK" /failover/fo.sh povuci "$( [ -f "$FO/povratak" ] && echo 1 || echo 0)" ); then
            rm -f "$FO/povratak" "$RUN/sync_jetzt"
          else
            [ -f "$RUN/sync_fehler" ] || echo "fehler" > "$RUN/sync_fehler"
          fi
        else
          echo "$(pj .verzija)" > "$RUN/sync_fehler"; rm -f "$RUN/sync_jetzt"
        fi
      fi
      # --- beide Standby (z. B. abgebrochener Wechsel): wer zuletzt aktiv war, hat die neuesten Daten
      if ! razvoj_aktiv && partner_frisch && [ "$(pj .uloga)" = pripravan ] && [ $(( $(jetzt) - bez_adrese )) -ge 120 ] \
         && ctl_laeuft && ! ev_online_irgendwo; then
        local moj tvoj; moj=$(cat "$FO/aktivan_od" 2>/dev/null || echo 0); tvoj=$(pj .aktivan_od); tvoj=${tvoj:-0}
        if [ "$moj" -gt "$tvoj" ] || { [ "$moj" -eq "$tvoj" ] && [[ "$LOK" < "$PARTNER_LOK" ]]; }; then
          log "Beide Server im Standby – $LOK war zuletzt aktiv und übernimmt"
          if ( flock -o "$LOCK" /failover/fo.sh preuzmi ); then
            melde "Evidencija: $LOK hat übernommen" "Beide Server standen auf Standby; $LOK (zuletzt aktiv) läuft jetzt."
          fi
          bez_partnera=$(jetzt); bez_adrese=$(jetzt)
        fi
      fi
      # --- Übernahme bei Ausfall
      local t; t=$(jetzt)
      local grace=$GRACE
      [ "$(cat "$RUN/najava_do" 2>/dev/null || echo 0)" -gt "$t" ] 2>/dev/null && grace=$GRACE_GEPLANT
      if ! razvoj_aktiv && [ $((t - bez_partnera)) -ge $grace ] && [ $((t - bez_adrese)) -ge $grace ] && ctl_laeuft; then
        if ! ev_online_irgendwo || [ $((t - bez_adrese)) -ge $GRACE_HART ]; then
          log "AUSFALL: $PARTNER_LOK seit $(( (t - bez_partnera) / 60 )) min weg – Übernahme"
          if ( flock -o "$LOCK" /failover/fo.sh preuzmi ); then
            melde "Evidencija: $LOK hat übernommen" "$PARTNER_LOK ist ausgefallen. Evidencija läuft jetzt auf $LOK (Stand: $(cat "$FO/zadnja_sink" 2>/dev/null))."
          fi
          bez_partnera=$(jetzt); bez_adrese=$(jetzt)
        fi
      fi
    fi

    # Erinnerung: Entwicklung zu lange an
    if razvoj_lokal && [ $(( $(jetzt) - $(cat "$FO/razvoj") )) -gt 259200 ] && [ "$(date +%H%M)" = "1800" ]; then
      melde "Evidencija: Entwicklung noch an" "Seit über 3 Tagen ist die automatische Übernahme aus."
    fi

    dashboard
    objavi
    sleep 30
  done
}

zaustavljanje() { # beim Stoppen des Add-ons: Partner vorwarnen
  [ "$(uloga)" = aktivan ] && ctl_laeuft && pc POST /najava 5 >/dev/null 2>&1
  ev_stop
}

# ---------------------------------------------------------------- Aufruf
case "${1:-}" in
  daemon) daemon ;;
  snimka) snimka ;;
  povuci) povuci "${2:-0}" ;;
  preuzmi) preuzmi ;;
  planirana_predaja) touch "$RUN/predaja"; PARTNER_LOK=$(echo "$PARTNER" | sed 's/^evidencija-ctl-//' | tr '[:lower:]' '[:upper:]'); planirana_predaja; r=$?; rm -f "$RUN/predaja"; exit $r ;;
  priprema) cmd_priprema ;;
  odustani) cmd_odustani ;;
  otpusti) cmd_otpusti ;;
  vrati) cmd_vrati ;;
  preuzmi_od_mene) cmd_preuzmi_od_mene ;;
  najava) cmd_najava ;;
  azuriraj) azuriraj_sebe ;;
  zaustavljanje) zaustavljanje ;;
  status)
    jq -cn --arg lok "$LOK" --arg ul "$(uloga)" --arg v "$(verzija)" --arg zs "$(cat "$FO/zadnja_sink" 2>/dev/null)" \
      --arg od "$(cat "$FO/aktivan_od" 2>/dev/null || echo 0)" --argjson rv "$(razvoj_lokal && echo true || echo false)" \
      --argjson ev "$(ev_laeuft_lokal && echo true || echo false)" --arg adr "$(cat "$FO/adresa" 2>/dev/null)" \
      '{lokacija:$lok, uloga:$ul, verzija:$v, zadnja_sink:$zs, aktivan_od:($od|tonumber), razvoj:$rv, ev_radi:$ev, adresa:$adr}' ;;
  *) echo "Befehl?"; exit 1 ;;
esac
