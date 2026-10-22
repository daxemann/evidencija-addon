<?php
// Steuer-API für den Partner-Server. Läuft als root nur auf 127.0.0.1:5081
// und ist ausschließlich über „tailscale serve“ des Steuerknotens im Tailnet erreichbar.
const FO = '/failover/fo.sh';
const LOCK = '/run/fo/lock';

function antwort(int $kod, $daten): void
{
    http_response_code($kod);
    header('Content-Type: application/json');
    echo is_string($daten) ? $daten : json_encode($daten);
    exit;
}

function fo(string $befehl, bool $sperre = true): array
{
    $cmd = ($sperre ? 'flock -o -w 600 ' . LOCK . ' ' : '') . FO . ' ' . escapeshellarg($befehl) . ' 2>&1';
    exec($cmd, $out, $rc);
    return [$rc, implode("\n", $out)];
}

// Nur Anfragen, die über tailscale serve kommen, und nur vom Partner-Steuerknoten.
function erlaubt(): bool
{
    $ip = trim(explode(',', $_SERVER['HTTP_X_FORWARDED_FOR'] ?? '')[0]);
    if ($ip === '' || empty($_SERVER['HTTP_TAILSCALE_USER_LOGIN'])) {
        return false;
    }
    $opt = json_decode((string) @file_get_contents('/data/options.json'), true) ?: [];
    $partner = strtolower((string) ($opt['failover_partner'] ?? ''));
    if ($partner === '') {
        return false;
    }
    exec('tailscale --socket=/var/run/tailscale/ctl.sock whois --json ' . escapeshellarg($ip) . ' 2>/dev/null', $o, $rc);
    $w = json_decode(implode("\n", $o), true) ?: [];
    $ime = strtolower((string) ($w['Node']['ComputedName'] ?? $w['Node']['Hostinfo']['Hostname'] ?? ''));
    $dns = strtolower((string) ($w['Node']['Name'] ?? ''));
    return $rc === 0 && ($ime === $partner || str_starts_with($dns, $partner . '.'));
}

$put = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);
$metoda = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if (!erlaubt()) {
    antwort(403, ['greska' => 'nicht erlaubt']);
}

if ($metoda === 'GET' && $put === '/status') {
    [$rc, $out] = fo('status', false);
    antwort($rc === 0 ? 200 : 500, $out);
}

if ($metoda === 'GET' && $put === '/snimka') {
    if (trim((string) @file_get_contents('/data/failover/uloga')) !== 'aktivan') {
        antwort(409, ['greska' => 'nicht aktiv']);
    }
    // Snapshot unter Sperre erzeugen, dann streamen
    [$rc, $out] = fo('snimka');
    $f = trim((string) array_slice(explode("\n", $out), -1)[0]);
    if ($rc !== 0 || !is_file($f)) {
        antwort(500, ['greska' => 'Kopie fehlgeschlagen', 'log' => $out]);
    }
    header('Content-Type: application/gzip');
    header('Content-Length: ' . filesize($f));
    readfile($f);
    @unlink($f);
    exit;
}

$post = [
    '/predaja/priprema' => 'priprema',
    '/predaja/odustani' => 'odustani',
    '/predaja/otpusti' => 'otpusti',
    '/predaja/vrati' => 'vrati',
    '/predaja/preuzmi_od_mene' => 'preuzmi_od_mene',
    '/najava' => 'najava',
    '/azuriraj' => 'azuriraj',
];
if ($metoda === 'POST' && isset($post[$put])) {
    // preuzmi_od_mene startet selbst unter Sperre (asynchron)
    [$rc, $out] = fo($post[$put], $post[$put] !== 'preuzmi_od_mene');
    antwort($rc === 0 ? 200 : 409, ['ok' => $rc === 0, 'log' => $out]);
}

antwort(404, ['greska' => 'unbekannt']);
