const cheerio = require("cheerio");

function getPostleitzahl(html) {
  if (
    cheerio
      .load(html)
      .root()
      .find("body table.wikitable tbody tr:nth-child(13) td:nth-child(1) a")
      .html() == "Postleitzahl" ||
    cheerio
      .load(html)
      .root()
      .find("body table.wikitable tbody tr:nth-child(13) td:nth-child(1) a")
      .html() == "Postleitzahlen"
  ) {
    return cheerio
      .load(html)
      .root()
      .find("body table.wikitable tbody tr:nth-child(13) td:nth-child(2)")
      .html();
  } else if (
    cheerio
      .load(html)
      .root()
      .find("body table.wikitable tbody tr:nth-child(14) td:nth-child(1) a")
      .html() == "Postleitzahl" ||
    cheerio
      .load(html)
      .root()
      .find("body table.wikitable tbody tr:nth-child(14) td:nth-child(1) a")
      .html() == "Postleitzahlen"
  ) {
    return cheerio
      .load(html)
      .root()
      .find("body table.wikitable tbody tr:nth-child(14) td:nth-child(2)")
      .html();
  } else if (
    cheerio
      .load(html)
      .root()
      .find("body table.wikitable tbody tr:nth-child(15) td:nth-child(1) a")
      .html() == "Postleitzahl" ||
    cheerio
      .load(html)
      .root()
      .find("body table.wikitable tbody tr:nth-child(15) td:nth-child(1) a")
      .html() == "Postleitzahlen"
  ) {
    return cheerio
      .load(html)
      .root()
      .find("body table.wikitable tbody tr:nth-child(15) td:nth-child(2)")
      .html();
  }
};

function getAdress(html) {
  let adress = "";
  if (
    cheerio
      .load(html)
      .root()
      .find("body table.wikitable tbody tr:nth-child(17) td:nth-child(1)")
      .html()
      .includes("Adresse")
  ) {
    adress = cheerio
      .load(html)
      .root()
      .find(
        "body table.wikitable tbody tr:not(.metadata):nth-child(17) td:nth-child(2)"
      )
      .html();
  } else if (
    cheerio
      .load(html)
      .root()
      .find("body table.wikitable tbody tr:nth-child(18) td:nth-child(1)")
      .html()
      .includes("Adresse")
  ) {
    adress = cheerio
      .load(html)
      .root()
      .find(
        "body table.wikitable tbody tr:not(.metadata):nth-child(18) td:nth-child(2)"
      )
      .html();
  } else if (
    cheerio
      .load(html)
      .root()
      .find("body table.wikitable tbody tr:nth-child(19) td:nth-child(1)")
      .html()
      .includes("Adresse")
  ) {
    adress = cheerio
      .load(html)
      .root()
      .find(
        "body table.wikitable tbody tr:not(.metadata):nth-child(19) td:nth-child(2)"
      )
      .html();
  }

  if (adress.includes('<')) {
    const $ = cheerio.load(adress);

    const addressElement = $('.adr');

    if (addressElement.length > 0) {
        // Adresse im HTML-Format
        const streetAddress = addressElement.find('.street-address').text().trim();
        const postalCode = addressElement.find('.postal-code').text().trim();
        const locality = addressElement.find('.locality').text().trim();

        const fullAddress = `${streetAddress} ${postalCode} ${locality}`;//<br>
        return fullAddress;
    }
}

// Adresse im Textformat
return adress.trim().replaceAll("<br>", " ");
};

function getBezirk(html){
  return cheerio
  .load(html)
  .root()
  .find(
    "body table.wikitable tbody tr:nth-child(7) td:nth-child(2) a"
  )
  .html();
}

function getWappen(html){
  return "https:"+cheerio
  .load(html)
  .root()
  .find("body table.wikitable tbody tr:nth-child(3) td:nth-child(1) span a img")
  .attr("srcset");

}


exports.getPostleitzahl = getPostleitzahl;
exports.getAdress = getAdress;
exports.getBezirk = getBezirk;
exports.getWappen = getWappen;

