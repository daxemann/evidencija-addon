<?php
// Prüft eine kopierte Datenbank: integrity_check + Prüfsumme aus meta.json
$db = $argv[1] ?? '';
$meta = json_decode((string) @file_get_contents(dirname($db) . '/meta.json'), true) ?: [];
if (!is_file($db)) { exit(1); }
if (!empty($meta['sha256']) && hash_file('sha256', $db) !== $meta['sha256']) { fwrite(STDERR, "Prüfsumme\n"); exit(1); }
try {
    $pdo = new PDO('sqlite:' . $db, null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    $r = $pdo->query('PRAGMA integrity_check')->fetchColumn();
    exit($r === 'ok' ? 0 : 1);
} catch (Throwable $e) {
    fwrite(STDERR, $e->getMessage() . "\n");
    exit(1);
}
