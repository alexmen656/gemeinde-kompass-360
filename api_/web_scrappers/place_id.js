const axios = require('axios');
const fs = require('fs').promises;

const API_KEY = "**currently not in use**";

const findPlaceId = async (suchbegriff, standort) => {
    console.log(suchbegriff, standort);

  const radius = 50; // Radius in Metern
  const urlPlaceSearch = `https://maps.googleapis.com/maps/api/place/textsearch/json?query=${suchbegriff}&location=${standort}&radius=${radius}&key=${API_KEY}`;

  try {
    const responsePlaceSearch = await axios.get(urlPlaceSearch);
    const dataPlaceSearch = responsePlaceSearch.data;

    if (
      responsePlaceSearch.status === 200 &&
      dataPlaceSearch.results &&
      dataPlaceSearch.results.length > 0
    ) {
      const placeId = dataPlaceSearch.results[0].place_id;
      console.log(`Gefundene Place ID: ${placeId}`);
      
      // Load existing place IDs from JSON file
      let placeIds = [];
      try {
        const data = await fs.readFile('place_ids.json', 'utf8');
        placeIds = JSON.parse(data);
      } catch (error) {
        if (error.code !== 'ENOENT') { // Ignore error if file does not exist
          throw error;
        }
      }

      // Add new place ID
      placeIds.push({ suchbegriff, standort, placeId });

      // Save updated place IDs back to JSON file
      await fs.writeFile('place_ids.json', JSON.stringify(placeIds, null, 2));
      
      return placeId;
    } else {
      console.error(
        "Fehler bei der Anfrage für Place ID oder keine Ergebnisse gefunden:",
        dataPlaceSearch.error_message || "Unbekannter Fehler"
      );
      return null;
    }
  } catch (error) {
    console.error("Fehler bei der Anfrage für Place ID:", error.message);
    return null;
  }
};

module.exports = { findPlaceId };
