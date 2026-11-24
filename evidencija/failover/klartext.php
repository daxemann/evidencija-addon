<?php
// Prüft, ob eine Datenbank verschlüsselt ist (App-Schalter „Šifriranje“) – liest nur diesen Schalter, gibt nichts aus.
// php klartext.php <evidencija.db> [zivo|datoteke]
//   zivo     = zusätzlich prüfen, ob die Datenbank heil ist (laufende Datenbank)
//   datoteke = statt der Datenfelder den Schalter für Ausweis-Fotos und Unterschriften prüfen (App ab 1.83.0)
// Rückgabe: 0 = verschlüsselt · 10 = nicht (vollständig) verschlüsselt · 2 = nicht lesbar / unklar
$db = $argv[1] ?? '';
if (!is_file($db)) { exit(2); }
try {
    $pdo = new PDO('sqlite:' . $db, null, null, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::SQLITE_ATTR_OPEN_FLAGS => PDO::SQLITE_OPEN_READONLY,
    ]);
    $pdo->exec('PRAGMA busy_timeout = 15000');
    if (($argv[2] ?? '') === 'zivo' && $pdo->query('PRAGMA quick_check')->fetchColumn() !== 'ok') { exit(2); }
    $pdo->query('SELECT COUNT(*) FROM Clanovi')->fetchColumn(); // wirklich eine Evidencija-Datenbank?
    $kljuc = ($argv[2] ?? '') === 'datoteke' ? 'Sifriranje.Datoteke' : 'Sifriranje.Stanje';
    $stanje = $pdo->query("SELECT Vrijednost FROM Postavke WHERE Kljuc='$kljuc'")->fetchColumn();
    exit($stanje === 'ukljuceno' ? 0 : 10);
} catch (Throwable $e) {
    exit(2);
}
