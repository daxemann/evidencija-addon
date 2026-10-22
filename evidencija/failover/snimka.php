<?php
// Konsistente Kopie der SQLite-Datenbank (VACUUM INTO) + meta.json
// php snimka.php <zielordner> <version> <standort>
[$_, $ziel, $verzija, $lok] = $argv + [null, null, '', ''];
$db = '/data/Podaci/evidencija.db';
if (!is_file($db) || !is_dir($ziel)) { fwrite(STDERR, "fehlt\n"); exit(1); }
$pdo = new PDO('sqlite:' . $db, null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$pdo->exec('PRAGMA busy_timeout = 15000');
$cilj = $ziel . '/evidencija.db';
$pdo->exec('VACUUM INTO ' . $pdo->quote($cilj));
$meta = [
    'verzija' => $verzija,
    'lokacija' => $lok,
    'vrijeme' => date('c'),
    'sha256' => hash_file('sha256', $cilj),
    'user_version' => (int) $pdo->query('PRAGMA user_version')->fetchColumn(),
];
file_put_contents($ziel . '/meta.json', json_encode($meta));
echo $cilj, "\n";
