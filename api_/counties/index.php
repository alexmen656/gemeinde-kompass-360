<?php

// Konfiguration einbinden
require_once '/www/api/config.php';

// Datenbankverbindung mit PDO (Verwendung der in der config.php definierten Konfiguration)
try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME, DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    error_log("Connection failed: " . $e->getMessage(), 3, ERROR_LOG_PATH); // Fehler ins Log schreiben
    die("Connection failed: " . $e->getMessage());
}

// Funktion, um alle Bezirke aus der Tabelle 'gk360_counties' zu holen
function getAllCounties()
{
    global $pdo;

    $stmt = $pdo->prepare("SELECT * FROM gk360_counties");
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

// Funktion, um die Gemeinden eines bestimmten Bezirks anhand des Namens oder der ID aus der Statistik-Tabelle zu holen
function getMunicipalitiesByCounty($county)
{
    global $pdo;

    // Überprüfen, ob die Eingabe eine ID oder ein Name ist
    if (is_numeric($county)) {
        $stmt = $pdo->prepare("
            SELECT m.*, s.district 
            FROM gk360_municipalities m
            JOIN gk360_municipality_statistics s ON m.id = s.municipality_id
            WHERE s.district = (SELECT name FROM gk360_counties WHERE id = :county_id)
        ");
        $stmt->bindParam(':county_id', $county, PDO::PARAM_INT);
    } else {
        $stmt = $pdo->prepare("
            SELECT m.*, s.district 
            FROM gk360_municipalities m
            JOIN gk360_municipality_statistics s ON m.id = s.municipality_id
            WHERE s.district = :county_name
        ");
        $stmt->bindParam(':county_name', $county, PDO::PARAM_STR);
    }

    $stmt->execute();
    $municipalities = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Entferne die Felder 'description' und 'municipality_type'
    foreach ($municipalities as &$municipality) {
        unset($municipality['description']);
        unset($municipality['municipality_type']);
    }

    return $municipalities;
}

// API-Endpunkte
if (isset($_GET['action'])) {
    $action = $_GET['action'];

    // Abrufen aller Bezirke
    if ($action === 'all') {
        $counties = getAllCounties();
        foreach ($counties as &$county) {
            unset($county['description']);
        }
        echo json_encode(["counties" => $counties], JSON_PRETTY_PRINT);

        // Abrufen der Gemeinden eines bestimmten Bezirks
    } elseif ($action === 'municipalities' && isset($_GET['county'])) {
        $county = $_GET['county']; // ID oder Name des Bezirks
        $municipalities = getMunicipalitiesByCounty($county);

        if ($municipalities) {
            foreach ($municipalities as &$municipality) {
                unset($municipality['description']);
            }
            echo json_encode(["municipalities" => $municipalities], JSON_PRETTY_PRINT);
        } else {
            echo json_encode(["error" => "No municipalities found for the given county"], JSON_PRETTY_PRINT);
        }
    } else {
        echo json_encode(["error" => "Invalid action or parameters"], JSON_PRETTY_PRINT);
    }
} else {
    echo json_encode(["error" => "No action specified"], JSON_PRETTY_PRINT);
}

?>