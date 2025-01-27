const fs = require("fs");

function extractCities(bezirk, file_name) {
  const htmlFilePath = `./html/${file_name}.html`;
  const htmlTable = fs.readFileSync(htmlFilePath, "utf-8");

  const regexCityName = /<a href="\/wiki\/[^"]+" title="[^"]+">([^<]+)<\/a>/;
  //const regexDesignation = /<td>([^<]+)<\/td>\s*<td[^>]+>[^<]+<\/td>/;
  const regexPopulation = /<td style="text-align:right">([\d,]+)\s*<\/td>/;

  const cityData = [];
  const rows = htmlTable.match(/<tr>[\s\S]*?<\/tr>/g);

  rows.forEach((row) => {
    const cityNameMatch = row.match(regexCityName);
    // const designationMatch = row.match(regexDesignation);
    const populationMatch = row.match(regexPopulation);

    if (cityNameMatch && populationMatch) {
      // && designationMatch
      const cityName = cityNameMatch[1];
      //const designation = designationMatch[1];
      const population = populationMatch[1].replace(/,/g, "");

      cityData.push({
        name: cityName,
        population: parseInt(population),
        bezirk: bezirk,
      }); //designation,
    }
  });

  const jsonData = JSON.stringify(cityData, null, 2);
  fs.writeFileSync(`./json/${file_name}.json`, jsonData, "utf8");
/* fs.appendFile(`./json/all.json`, jsonData.replace("[", "").replace("]", ""), function (err) {
    if (err) throw err;
    console.log('Saved!');
  });*/
}

const bundeslaender = [
  { name: "Burgenland", file_name: "burgenland" },
  { name: "Kärnten", file_name: "karnten" },
  { name: "Niederösterreich", file_name: "niederosterreich" },
  { name: "Oberösterreich", file_name: "oberosterreich" },
  { name: "Salzburg", file_name: "salzburg" },
  { name: "Steiermark", file_name: "steiermark" },
  { name: "Tirol", file_name: "tirol" },
  { name: "Vorarlberg", file_name: "vorarlberg" },
  { name: "Wien", file_name: "wien" },
];

bundeslaender.forEach((bundesland) => {
  extractCities(bundesland.name, bundesland.file_name);
});
