# Evidencija – lovačka udruga

Evidencija članova, radnih akcija (bodovi), članarine, oglasnik (kupujem/prodajem) i pristup za članove s mobitela.

## Prvo pokretanje
1. **Start** → u kartici **Log** pričekajte poruku `[tailscale] … login.tailscale.com/a/…` i otvorite tu poveznicu (prijava u Tailscale račun).
2. Nakon prijave u Logu piše **Javna adresa aplikacije: https://evidencija.….ts.net/** – to je adresa za članove.
3. Otvorite adresu → **Postavljanje**:
   - nova udruga: naziv, sekcije, glavni administrator, ili
   - **Vrati iz kompletne kopije (ZIP)** – preseljenje s računala (Sustav → Sigurnosne kopije → Preuzmi kompletnu kopiju).

U lokalnoj mreži aplikacija je dostupna i na `http://<IP-Home-Assistanta>:5080`.

## Podaci i sigurnosne kopije
Svi podaci (baza, fotografije, ključevi) su u podacima add-ona i automatski ulaze u **Home Assistant backup**.
Aplikacija dodatno radi dnevnu kopiju baze (zadnjih 30).

## Opcije
| Opcija | Značenje |
|---|---|
| tailscale | Javna HTTPS adresa preko Tailscale Funnel (vlastiti uređaj „evidencija“ u vašem tailnetu) |
| tailscale_hostname | prvi dio adrese |
| tailscale_authkey | umjesto prijave poveznicom (nije obavezno) |

Aplikacija je PHP verzija programa [lovacka-evidencija](https://github.com/daxemann/lovacka-evidencija) (Apache + PHP 8.3).
