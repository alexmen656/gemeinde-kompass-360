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

// Funktion, um eine Gemeinde anhand des 'code' abzufragen
function getMunicipality($code)
{
    global $pdo;

    // Gemeindendaten abfragen (Prefix gk360_)
    $stmt = $pdo->prepare("SELECT * FROM gk360_municipalities WHERE code = :code");
    $stmt->bindParam(':code', $code, PDO::PARAM_STR);
    $stmt->execute();
    $municipality = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($municipality) {
        // Kontaktinformationen abfragen (Prefix gk360_)
        $stmt_contact = $pdo->prepare("SELECT * FROM gk360_municipality_contact WHERE municipality_id = :id");
        $stmt_contact->bindParam(':id', $municipality['id'], PDO::PARAM_INT);
        $stmt_contact->execute();
        $contact = $stmt_contact->fetch(PDO::FETCH_ASSOC);

        // Statistiken abfragen (Prefix gk360_)
        $stmt_statistics = $pdo->prepare("SELECT * FROM gk360_municipality_statistics WHERE municipality_id = :id");
        $stmt_statistics->bindParam(':id', $municipality['id'], PDO::PARAM_INT);
        $stmt_statistics->execute();
        $statistics = $stmt_statistics->fetch(PDO::FETCH_ASSOC);

        // Bilder abfragen (Prefix gk360_)
        $stmt_images = $pdo->prepare("SELECT thumb_url, full_url, attribution FROM gk360_images WHERE municipality_id = :id");
        $stmt_images->bindParam(':id', $municipality['id'], PDO::PARAM_INT);
        $stmt_images->execute();
        $images = $stmt_images->fetchAll(PDO::FETCH_ASSOC);

        // Zusammenfügen der Daten
        $municipality_data = [
            "code" => $municipality['code'],
            "name" => $municipality['name'],
            // "description" => $municipality['description'],
            // "municipality_type" => $municipality['municipality_type'],
            "postal_code" => $municipality['postal_code'],
            "identifier" => $municipality['identifier'],
            "coat_of_arms" => $municipality['coat_of_arms'],
            "images" => $images, // Bilder werden hier hinzugefügt
            "contact" => [
                //"email" => $contact['email'] ?? null,
                "phone" => $contact['phone'] ?? null,
                "address" => $contact['address'] ?? null,
                //"opening_hours" => $contact['opening_hours'] ?? null,
                "longitude" => $municipality['longitude'] ?? null,
                "latitude" => $municipality['latitude'] ?? null
            ],
            "statistics" => [
                "mayor" => $statistics['mayor'] ?? null,
                "population" => $statistics['population'] ?? null,
                "area" => $statistics['area'] ?? null,
                "homepage" => $municipality['homepage'] ?? null,
                "district" => $statistics['district'] ?? null,
                "federal_state" => $statistics['federal_state'] ?? null
            ]
        ];

        return $municipality_data;
    } else {
        return null;
    }
}
function getAllMunicipalities($limit = null)
{
    global $pdo;

    $sql = "SELECT * FROM gk360_municipalities ORDER BY name ASC";
    if ($limit !== null) {
        $sql .= " LIMIT :limit";
    }

    $stmt = $pdo->prepare($sql);
    if ($limit !== null) {
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
    }
    $stmt->execute();
    $municipalities = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($municipalities as &$municipality) {
        // Entferne die Felder 'description' und 'municipality_type'
        unset($municipality['description']);
        unset($municipality['municipality_type']);

        // Statistiken abfragen
        $stmt_statistics = $pdo->prepare("SELECT * FROM gk360_municipality_statistics WHERE municipality_id = :id");
        $stmt_statistics->bindParam(':id', $municipality['id'], PDO::PARAM_INT);
        $stmt_statistics->execute();
        $statistics = $stmt_statistics->fetch(PDO::FETCH_ASSOC);

        // Kontaktinformationen abfragen
        $stmt_contact = $pdo->prepare("SELECT * FROM gk360_municipality_contact WHERE municipality_id = :id");
        $stmt_contact->bindParam(':id', $municipality['id'], PDO::PARAM_INT);
        $stmt_contact->execute();
        $contact = $stmt_contact->fetch(PDO::FETCH_ASSOC);

        // Bilder abfragen
        $stmt_images = $pdo->prepare("SELECT thumb_url FROM gk360_images WHERE municipality_id = :id LIMIT 1");
        $stmt_images->bindParam(':id', $municipality['id'], PDO::PARAM_INT);
        $stmt_images->execute();
        $image = $stmt_images->fetch(PDO::FETCH_ASSOC);

        // Entferne das Feld 'opening_hours' aus den Statistiken
        unset($statistics['opening_hours']);

        // Füge die Statistiken, Kontaktinformationen und das Bild zur Gemeinde hinzu
        if ($statistics) {
            foreach ($statistics as $key => $value) {
                $municipality[$key] = $value;
            }
        }

        if ($contact) {
            foreach ($contact as $key => $value) {
                $municipality[$key] = $value;
            }
        }

        if ($image) {
            $municipality['image'] = $image['thumb_url'];
        }
    }

    return $municipalities;
}
function getMunicipalityImages($municipality)
{
    global $pdo;

    // Gemeinde-ID anhand des Namens abrufen
    $stmt = $pdo->prepare("SELECT id FROM gk360_municipalities WHERE name = :name");
    $stmt->bindParam(':name', $municipality, PDO::PARAM_STR);
    $stmt->execute();
    $municipality_data = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($municipality_data) {
        // Bilder für die Gemeinde abrufen
        $stmt_images = $pdo->prepare("SELECT thumb_url, full_url, attribution FROM gk360_images WHERE municipality_id = :id");
        $stmt_images->bindParam(':id', $municipality_data['id'], PDO::PARAM_INT);
        $stmt_images->execute();
        return $stmt_images->fetchAll(PDO::FETCH_ASSOC);
    } else {
        return null;
    }
}

// API-Endpunkt: Eine Gemeinde anhand des 'code' abfragen
if (isset($_GET['code'])) {
    $code = $_GET['code'];

    // Gemeindendaten holen
    $data = getMunicipality($code);

    if ($data) {
        echo json_encode(["municipality" => $data], JSON_PRETTY_PRINT);
    } else {
        echo json_encode(["error" => "Municipality not found"], JSON_PRETTY_PRINT);
    }
} elseif (isset($_GET['action']) && $_GET['action'] === 'images' && isset($_GET['municipality'])) {
    $municipality = $_GET['municipality'];

    // Bilder für die Gemeinde holen
    $images = getMunicipalityImages($municipality);

    if ($images) {
        echo json_encode(["images" => $images], JSON_PRETTY_PRINT);
    } else {
        echo json_encode(["error" => "No images found for the specified municipality"], JSON_PRETTY_PRINT);
    }
} else if (isset($_GET['action']) && $_GET['action'] === 'all') {
    $limit = isset($_GET['limit']) ? (int) $_GET['limit'] : null;
    echo json_encode(getAllMunicipalities($limit));
} else {
    echo json_encode(["error" => "Invalid request. Please provide a valid 'code' parameter."], JSON_PRETTY_PRINT);
}

?>