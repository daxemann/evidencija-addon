# Evidencija – lovačka udruga

Evidencija članova, radnih akcija (bodovi), kalendar termina (po sekcijama), članarina u ratama s diskretnim podsjetnikom, imenik (član sam odlučuje što dijeli),
poruke među članovima, oglasnik (kupujem/prodajem) i pristup za članove s mobitela – i kao ikona na početnom zaslonu (Android, iPhone).

## Prvo pokretanje
1. **Start** → u kartici **Log** pričekajte poruku `[tailscale] … login.tailscale.com/a/…` i otvorite tu poveznicu (prijava u Tailscale račun).
2. Nakon prijave u Logu piše **Javna adresa aplikacije: https://evidencija.….ts.net/** – to je adresa za članove.
3. Otvorite adresu → **Postavljanje**:
   - nova udruga: naziv, sekcije, glavni administrator, ili
   - **Vrati iz kompletne kopije (ZIP)** – preseljenje s računala (Sustav → Sigurnosne kopije → Preuzmi kompletnu kopiju).

U lokalnoj mreži aplikacija je dostupna i na `http://<IP-Home-Assistanta>:5080`.

## Podaci i sigurnosne kopije
Svi podaci (baza, fotografije, ključevi) su u podacima add-ona i automatski ulaze u **Home Assistant backup**.
Aplikacija dodatno radi dnevnu kopiju baze (zadnjih 30). Pri nadogradnji se baza sama proširuje novim tablicama – postojeći podaci ostaju.

## Opcije
| Opcija | Značenje |
|---|---|
| tailscale | Javna HTTPS adresa preko Tailscale Funnel (vlastiti uređaj „evidencija“ u vašem tailnetu) |
| tailscale_hostname | prvi dio adrese |
| tailscale_authkey | umjesto prijave poveznicom (nije obavezno) |

Aplikacija je PHP verzija programa [lovacka-evidencija](https://github.com/daxemann/lovacka-evidencija) (Apache + PHP 8.3).

## Ausfall-Server (Failover) – optional

Zwei Home-Assistant-Server (z. B. HR und DE) teilen sich **dieselbe Adresse**. Immer nur einer ist online.
Der andere ist Standby, holt 3× täglich (03, 11, 19 Uhr) eine Kopie und übernimmt, wenn der aktive
länger als 5 Minuten weg ist. Kommt der ausgefallene zurück, wird er Standby („wer läuft, bleibt“).

| Option | HR | DE |
|---|---|---|
| failover | true | true |
| failover_lokacija | HR | DE |
| failover_partner | evidencija-ctl-de | evidencija-ctl-hr |
| failover_pocetna_uloga | aktivan | pripravan |

Jeder Server bekommt zusätzlich einen Tailscale-**Steuerknoten** (`evidencija-ctl-…`); beim ersten Start
erscheint im Log ein Anmeldelink. In der Tailscale-Konsole bei allen Knoten „Disable key expiry“ setzen.

Dashboard-Helfer (optional, im HA des Admins): `input_boolean.evidencija_entwicklung`,
`input_button.evidencija_wechseln`, `input_button.evidencija_sync_jetzt`, `input_button.evidencija_aktualisieren`.
Sensoren: `sensor.evidencija_aktiver_server`, `sensor.evidencija_failover_status`,
`sensor.evidencija_letzter_sync`, `binary_sensor.evidencija_partner_erreichbar`,
`binary_sensor.evidencija_seite_erreichbar`, `sensor.evidencija_letzter_ausfall` (nur Info).

Ohne `failover: true` ändert sich am Verhalten nichts.
