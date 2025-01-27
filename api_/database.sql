CREATE TABLE gk360_municipalities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50),
    name VARCHAR(255),
    description TEXT,
    municipality_type VARCHAR(100),
    postal_code VARCHAR(20),
    identifier VARCHAR(50),
    coat_of_arms VARCHAR(255),
    homepage VARCHAR(255),
    longitude FLOAT,
    latitude FLOAT
);

CREATE TABLE gk360_municipality_contact (
    id INT AUTO_INCREMENT PRIMARY KEY,
    municipality_id INT,
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    opening_hours TEXT,
    FOREIGN KEY (municipality_id) REFERENCES gk360_municipalities(id)
);

CREATE TABLE gk360_municipality_statistics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    municipality_id INT,
    mayor VARCHAR(255),
    population INT,
    area FLOAT,
    district VARCHAR(255),
    federal_state VARCHAR(255),
    FOREIGN KEY (municipality_id) REFERENCES gk360_municipalities(id)
);

CREATE TABLE gk360_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    municipality_id INT NOT NULL,
    thumb_url TEXT NOT NULL,
    full_url TEXT NOT NULL,
    attribution TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (municipality_id) REFERENCES gk360_villages(id) ON DELETE CASCADE
);

CREATE TABLE gk360_counties (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    federal_state VARCHAR(255) NOT NULL,
    description TEXT
);

CREATE TABLE gk360_federal_states (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    abbreviation VARCHAR(10), -- Optional: Abkürzung (z. B. "NÖ" für Niederösterreich)
    description TEXT
);

-- There are only 9 federal states in Austria so insert them manually
INSERT INTO gk360_federal_states (name, abbreviation, description) VALUES
('Burgenland', 'B', 'Bundesland im Osten Österreichs mit Weinbaugebieten und dem Neusiedler See.'),
('Kärnten', 'K', 'Bundesland im Süden Österreichs, bekannt für seine Seen und Berge.'),
('Niederösterreich', 'NÖ', 'Flächenmäßig größtes Bundesland Österreichs, umschließt Wien.'),
('Oberösterreich', 'OÖ', 'Industrie- und Wirtschaftsregion im Norden Österreichs.'),
('Salzburg', 'S', 'Bekannt für die Stadt Salzburg und die Alpenlandschaft.'),
('Steiermark', 'ST', 'Waldreiches Bundesland im Südosten Österreichs.'),
('Tirol', 'T', 'Alpenregion im Westen Österreichs, bekannt für Wintersport.'),
('Vorarlberg', 'V', 'Kleinstes Bundesland im Westen Österreichs, an der Grenze zur Schweiz.'),
('Wien', 'W', 'Hauptstadt und eigenes Bundesland mit kultureller und politischer Bedeutung.');
