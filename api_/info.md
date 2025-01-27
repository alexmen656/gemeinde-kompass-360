Gemeinden (Municipalities)
Abrufen einer bestimmten Gemeinde anhand des Codes:
Endpoint: ?code={municipality_code}
Beschreibung: Liefert alle Daten zu einer Gemeinde, inkl. Kontaktinformationen, Statistiken und Bildern.
Bilder (Images)
Abrufen der Bilder einer bestimmten Gemeinde:
Endpoint: ?action=images&municipality={municipality_id}
Beschreibung: Gibt alle Bilder (Thumbnail, Full-Size, Attribution) zurück, die einer bestimmten Gemeinde zugeordnet sind.
Bezirke (Counties)
Abrufen aller Bezirke:

Endpoint: ?action=all
Beschreibung: Gibt alle Bezirke aus der Tabelle gk360_counties zurück.
Abrufen der Gemeinden eines bestimmten Bezirks:

Endpoint: ?action=municipalities&county={county_id_or_name}
Beschreibung: Gibt alle Gemeinden zurück, die zu einem bestimmten Bezirk gehören (per ID oder Name).
Bundesländer (Federal States)
Abrufen aller Bundesländer:

Endpoint: ?action=all
Beschreibung: Gibt alle Bundesländer aus der Tabelle gk360_federal_states zurück.
Abrufen der Bezirke eines bestimmten Bundeslands:

Endpoint: ?action=counties&federal_state={federal_state_id_or_name}
Beschreibung: Gibt alle Bezirke zurück, die einem bestimmten Bundesland zugeordnet sind (per ID oder Name).
Beispiel-Aufrufe:
Gemeinde: ?code=12345
Bilder einer Gemeinde: ?action=images&municipality=5
Alle Bezirke: ?action=all
Bezirke eines Bundeslands: ?action=counties&federal_state=1
Gemeinden eines Bezirks: ?action=municipalities&county=101
