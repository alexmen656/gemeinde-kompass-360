<?php

// Konfiguration einbinden
require_once 'config.php';

// Verbindung zur Datenbank herstellen
try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME, DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Datenbankverbindung fehlgeschlagen: " . $e->getMessage());
}

// Prüfen, ob Daten per POST gesendet wurden
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // POST-Daten abrufen und in ein Array umwandeln
    $data = json_decode(file_get_contents('php://input'), true);

    if ($data) {
        try {
            // Gemeindeprüfung: Existiert die Gemeinde bereits in der Tabelle?
            $stmt_check = $pdo->prepare("
                SELECT id FROM gk360_municipalities 
                WHERE code = :code OR name = :name
            ");
            $stmt_check->execute([
                ':code' => $data['code'],
                ':name' => $data['name']
            ]);

            if ($stmt_check->rowCount() > 0) {
                // Wenn die Gemeinde bereits existiert, Rückmeldung geben
                echo json_encode(['status' => 'error', 'message' => 'Die Gemeinde existiert bereits in der Datenbank.']);
                exit;
            }

            // Transaktion starten
            $pdo->beginTransaction();

            // Schritt 1: Bezirk prüfen und ggf. hinzufügen
            $stmt_county_check = $pdo->prepare("
                SELECT id FROM gk360_counties 
                WHERE name = :name
            ");
            $stmt_county_check->execute([
                ':name' => $data['bezirk']
            ]);

            if ($stmt_county_check->rowCount() === 0) {
                // Bezirk hinzufügen, falls nicht vorhanden
                $stmt_county_insert = $pdo->prepare("
                    INSERT INTO gk360_counties (name, federal_state, description)
                    VALUES (:name, :federal_state, :description)
                ");
                $stmt_county_insert->execute([
                    ':name' => $data['bezirk'],
                    ':federal_state' => $data['bundesland'],
                    ':description' => null
                ]);

                // ID des neu erstellten Bezirks abrufen
                $county_id = $pdo->lastInsertId();
            } else {
                // ID des existierenden Bezirks abrufen
                $county_id = $stmt_county_check->fetchColumn();
            }

            // Schritt 2: Daten in `gk360_municipalities` einfügen
            $stmt = $pdo->prepare("
                INSERT INTO gk360_municipalities 
                (code, name, description, municipality_type, postal_code, identifier, coat_of_arms, homepage, longitude, latitude)
                VALUES (:code, :name, :description, :municipality_type, :postal_code, :identifier, :coat_of_arms, :homepage, :longitude, :latitude)
            ");
            $stmt->execute([
                ':code' => $data['code'],
                ':name' => $data['name'],
                ':description' => $data['description'] ?? null,
                ':municipality_type' => $data['municipality_type'] ?? null,
                ':postal_code' => $data['plz'],
                ':identifier' => $data['kennziffer'],
                ':coat_of_arms' => $data['wappen'],
                ':homepage' => $data['homepage'] ?? null,
                ':longitude' => $data['location']['longitude'],
                ':latitude' => $data['location']['latitude']
            ]);

            // ID der eingefügten Gemeinde abrufen
            $municipality_id = $pdo->lastInsertId();

            // Schritt 3: Daten in `gk360_municipality_contact` einfügen
            $stmt_contact = $pdo->prepare("
                INSERT INTO gk360_municipality_contact 
                (municipality_id, email, phone, address, opening_hours)
                VALUES (:municipality_id, :email, :phone, :address, :opening_hours)
            ");
            $stmt_contact->execute([
                ':municipality_id' => $municipality_id,
                ':email' => $data['email'] ?? 'unknown',
                ':phone' => $data['tel'],
                ':address' => $data['adress'],
                ':opening_hours' => null
            ]);

            // Schritt 4: Daten in `gk360_municipality_statistics` einfügen
            $stmt_statistics = $pdo->prepare("
                INSERT INTO gk360_municipality_statistics 
                (municipality_id, mayor, population, area, district, federal_state)
                VALUES (:municipality_id, :mayor, :population, :area, :district, :federal_state)
            ");
            $stmt_statistics->execute([
                ':municipality_id' => $municipality_id,
                ':mayor' => $data['burgermeister'],
                ':population' => $data['population'] ?? null,
                ':area' => $data['flaeche'],
                ':district' => $data['bezirk'],
                ':federal_state' => $data['bundesland']
            ]);

            // Schritt 5: Bilder in `gk360_images` einfügen
            if (!empty($data['bilder'])) {
                $stmt_images = $pdo->prepare("
                    INSERT INTO gk360_images 
                    (municipality_id, thumb_url, full_url, attribution)
                    VALUES (:municipality_id, :thumb_url, :full_url, :attribution)
                ");

                foreach ($data['bilder'] as $image) {
                    $stmt_images->execute([
                        ':municipality_id' => $municipality_id,
                        ':thumb_url' => $image['thumb'],
                        ':full_url' => $image['url'],
                        ':attribution' => $image['attribution']
                    ]);
                }
            }

            // Transaktion abschließen
            $pdo->commit();
            echo json_encode(['status' => 'success', 'message' => 'Gemeindedaten erfolgreich eingefügt.']);
        } catch (Exception $e) {
            // Fehlerbehandlung und Rollback
            $pdo->rollBack();
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
        }
    } else {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Ungültige oder keine Daten erhalten.']);
    }
} else {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Nur POST-Anfragen sind erlaubt.']);
}
