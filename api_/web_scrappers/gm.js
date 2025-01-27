const axios = require("axios");

// Setze deinen API-Schlüssel hier
const API_KEY = "**currently not in use**";

// Funktion zur Umwandlung der Zeit ins 24-Stunden-Format
const convertTo24HourFormat = (time) => {
  const [timePart, modifier] = time.split(' '); // Split by narrow space
  let [hours, minutes] = timePart.split(':');

  if (modifier === 'PM' && hours !== '12') {
    hours = parseInt(hours, 10) + 12;
  }

  if (modifier === 'AM' && hours === '12') {
    hours = '00';
  }

  return `${hours}:${minutes}`;
};

// Funktion zur Formatierung der Öffnungszeiten ins EU-Format
const formatOpeningHoursEU = (openingHours) => {
  const daysOfWeek = {
    "Monday": "Montag",
    "Tuesday": "Dienstag",
    "Wednesday": "Mittwoch",
    "Thursday": "Donnerstag",
    "Friday": "Freitag",
    "Saturday": "Samstag",
    "Sunday": "Sonntag"
  };

  return openingHours.map(dayInfo => {
    const [day, hours] = dayInfo.split(': ');
    const formattedHours = hours.split(', ').map(timeRange => {
      return timeRange.split(' – ').map(time => convertTo24HourFormat(time)).join(' - ');
    }).join(', ');

    return `${daysOfWeek[day]}: ${formattedHours}`;
  });
};

// Schritt 1: Place ID suchen
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

// Schritt 2: Öffnungszeiten abrufen
const getOpeningHours = async (placeId) => {
  const urlPlaceDetails = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${placeId}&fields=opening_hours&key=${API_KEY}`;

  try {
    const responsePlaceDetails = await axios.get(urlPlaceDetails);
    const dataPlaceDetails = responsePlaceDetails.data;

    if (responsePlaceDetails.status === 200 && dataPlaceDetails.result) {
      if (dataPlaceDetails.result.opening_hours) {
        const openingHours = dataPlaceDetails.result.opening_hours.weekday_text;
        const formattedHours = formatOpeningHoursEU(openingHours);
        console.log("Öffnungszeiten:");
        formattedHours.forEach(day => console.log(day));
      } else {
        console.log("Keine Öffnungszeiten gefunden.");
      }
    } else {
      console.error(
        "Fehler bei der Anfrage für Öffnungszeiten:",
        dataPlaceDetails.error_message || "Unbekannter Fehler"
      );
    }
  } catch (error) {
    console.error("Fehler bei der Anfrage für Öffnungszeiten:", error.message);
  }
};

// Hauptfunktion
const get_opening_hours = async (suchbegriff, standort) => {
  const placeId = await findPlaceId(suchbegriff, standort);
  if (placeId) {
    await getOpeningHours(placeId);
  }
};

exports.get_opening_hours = get_opening_hours;
