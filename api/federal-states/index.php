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

// Funktion, um alle Bundesländer abzurufen
function getAllFederalStates()
{
    global $pdo;

    $stmt = $pdo->prepare("SELECT * FROM gk360_federal_states");
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

// Funktion, um die Bezirke eines bestimmten Bundeslands abzurufen
function getCountiesByFederalState($federalState)
{
    global $pdo;

    // Überprüfen, ob die Eingabe eine ID oder ein Name ist
    if (is_numeric($federalState)) {
        $stmt = $pdo->prepare("
            SELECT c.* 
            FROM gk360_counties c
            JOIN gk360_federal_states fs ON fs.name = c.federal_state
            WHERE fs.id = :federal_state_id
        ");
        $stmt->bindParam(':federal_state_id', $federalState, PDO::PARAM_INT);
    } else {
        $stmt = $pdo->prepare("
            SELECT c.* 
            FROM gk360_counties c
            JOIN gk360_federal_states fs ON fs.name = c.federal_state
            WHERE fs.name = :federal_state_name
        ");
        $stmt->bindParam(':federal_state_name', $federalState, PDO::PARAM_STR);
    }

    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

// API-Endpunkte
if (isset($_GET['action'])) {
    $action = $_GET['action'];

    // Abrufen aller Bundesländer
    if ($action === 'all') {
        $federalStates = getAllFederalStates();
        echo json_encode(["federal_states" => $federalStates], JSON_PRETTY_PRINT);
    
        // Abrufen der Bezirke eines bestimmten Bundeslands
    } elseif ($action === 'counties' && isset($_GET['federal_state'])) {
        $federal_state = $_GET['federal_state']; // ID oder Name des Bundeslandes
        $counties = getCountiesByFederalState($federal_state);
    
        if ($counties) {
            foreach ($counties as &$county) {
                unset($county['description']);
            }
            echo json_encode(["counties" => $counties], JSON_PRETTY_PRINT);
        } else {
            echo json_encode(["error" => "No counties found for the given federal state"], JSON_PRETTY_PRINT);
        }
    } else {
        echo json_encode(["error" => "Invalid action or parameters"], JSON_PRETTY_PRINT);
    }
} else {
    echo json_encode(["error" => "No action specified"], JSON_PRETTY_PRINT);
}

?>