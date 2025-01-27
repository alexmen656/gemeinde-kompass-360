const axios = require("axios");
const cheerio = require("cheerio");
const functions = require("./functions");
//const get_opening_hours = require("./gm");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const qs = require("qs");
const fs = require("fs/promises");
const fss = require("fs");
const { findPlaceId } = require("./place_id");

const genAI = new GoogleGenerativeAI("**currently not in use**"); //process.env.API_KEY

let bezirk = "";
let plz = "";
let adresse = "";
let email = "";

async function getData(name, einwohner) {
  console.log("Getting data for " + name + "...");
  const gemeinde = name.replaceAll(" ", "-").toLowerCase();
  try {
    const response = await axios.get(
      `https://gemeinde-osterreich.at/gemeinde-${gemeinde}.html`
    );

    if (response.status !== 200) {
      console.error(
        `Error fetching data for ${name}. Status code: ${response.status}`
      );
      return;
    }

    const $ = cheerio.load(response.data);
    const divCityHallElement = $("#div_cityhall table tbody");
    const divTerritoryElement = $("#div_territory table tbody");

    //kennziffer
    const kennziffer = $("#div_number table tbody tr:nth-child(1) td").html();

    //telefon
    const telefon2Html = divCityHallElement.find("tr:nth-child(2) td").html();
    const telefon1 = telefon2Html.split("<br>")[0].trim();
    const telefon2 = cheerio.load(telefon2Html).root().find("span.grey").text();

    //bürgermeister
    const seite = divCityHallElement.find("tr:nth-child(4) td a").text();

    //bürgermeister
    const burgerking = divCityHallElement.find("tr:nth-child(5) td").html();

    //fläche
    const areaaa = divTerritoryElement.find("tr:nth-child(1) td").html();
    const areaa = areaaa.split("<br>")[1];
    const area = parseFloat(areaa.match(/\d+,\d+/)[0].replace(",", "."));

    //bundesland
    const bundesland = $(
      "#div_admindata table tbody tr:nth-child(2) td a"
    ).html();
    //email
    /* const uri = $('script[type="text/javascript"]').text();
    const matches = uri.match(/\$\.\ajax\(\'(.*?)\'\)/);
    if (matches) {
      const url = matches[1];
      console.log("https://www.gemeinde-osterreich.at" + url);
      await axios
        .get("https://www.gemeinde-osterreich.at" + url)
        .then((res) => {
       

          email = cheerio.load(res.data).root().find("a").html();
        });
    } else {
      console.log("URL nicht gefunden.");
    }*/
    email = "unknown";

    //wikipedia
    await axios
      .get("https://de.wikipedia.org/wiki/" + name.replaceAll(" ", "_"))
      .then(async (response) => {
        if (
          cheerio
            .load(response.data)
            .root()
            .find("body table.wikitable tbody tr:nth-child(17) td:nth-child(1)")
            .html()
            ? true
            : false ||
              cheerio
                .load(response.data)
                .root()
                .find(
                  "body table.wikitable tbody tr:nth-child(18) td:nth-child(1)"
                )
                .html()
            ? true
            : false ||
              cheerio
                .load(response.data)
                .root()
                .find(
                  "body table.wikitable tbody tr:nth-child(19) td:nth-child(1)"
                )
                .html()
            ? true
            : false
        ) {
          bezirk = functions.getBezirk(response.data);
          plz = functions.getPostleitzahl(response.data);
          adresse = functions.getAdress(response.data);
          wappen = (
            "https:" + functions.getWappen(response.data).split(" 1.5x, ")[1]
          ).replace(" 2x", "");
        } else {
          await axios
            .get(
              `https://de.wikipedia.org/wiki/${name.replaceAll(
                " ",
                "_"
              )}_(${bundesland})`
            )
            .then((response) => {
              bezirk = functions.getBezirk(response.data);
              plz = functions.getPostleitzahl(response.data);
              adresse = functions.getAdress(response.data);

              wappen = (
                "https:" +
                functions.getWappen(response.data).split(" 1.5x, ")[1]
              ).replace(" 2x", "");
            });
        }

        let location = { longitude: 0, latitude: 0 };
        //  console.log(adresse);

        //  adresse = adresse.text();
        // adresse.replace('1',' ');
        //console.log(adresse);
        // adresse.replace(" am Neusiedler See", "");
        //console.log(adresse);
        await axios
          .get(
            `https://geocode.maps.co/search?q=${adresse}&api_key=6644faaa93baa336499224tfh67afef`
          )
          .then(async (response) => {
            if (response.data[0]) {
              if (response.data[0].lon && response.data[0].lat) {
                findPlaceId(
                  "Gemeindeamt " + gemeinde,
                  response.data[0].lon + "," + response.data[0].lat
                )
                  .then((placeId) => {
                    console.log(`Erhaltene Place ID: ${placeId}`);
                  })
                  .catch((error) => {
                    console.error("Fehler:", error);
                  });
                location.longitude = Number(response.data[0].lon);
                location.latitude = Number(response.data[0].lat);
              }
            } else {
              await axios
                .get(
                  `https://geocode.maps.co/search?q=gemeindeamt+${name
                    .toLowerCase()
                    .replace(
                      " am neusiedler see",
                      ""
                    )}&api_key=6644faaa93baa336499224tfh67afef`
                )
                .then((response2) => {
                  if (response2.data[0]) {
                    if (response2.data[0].lon && response2.data[0].lat) {
                      // Beispielaufruf der Funktion
                      findPlaceId(
                        "Gemeindeamt " + gemeinde,
                        response2.data[0].lon + "," + response2.data[0].lat
                      )
                        .then((placeId) => {
                          console.log(`Erhaltene Place ID: ${placeId}`);
                        })
                        .catch((error) => {
                          console.error("Fehler:", error);
                        });

                      location.longitude = Number(response2.data[0].lon);
                      location.latitude = Number(response2.data[0].lat);
                    }
                  } else {
                    fss.appendFile(
                      "logs/address_fail_log.txt",
                      gemeinde +
                        " An error occurred: Failed to find address\n\n",
                      (err) => {
                        if (err) throw err;
                        console.log(
                          "Address failed! Error logged in address_fail_log.txt"
                        );
                      }
                    );
                  }
                });
            }
          });

        var url =
          "https://commons.wikimedia.org/w/api.php?action=query&generator=geosearch&ggsprimary=all&ggsnamespace=6&ggsradius=500&ggscoord=" +
          location.latitude +
          "|" +
          location.longitude +
          "&prop=imageinfo&iiprop=url&iiurlwidth=200&format=json";
        let images = [];
        await fetch(url)
          .then(function (response) {
            return response.json();
          })
          .then(async function (response) {
            var pages = response.query.pages;
            let count = 0;
            let attribution = "";
            for (var page in pages) {
              if (count == 5) {
                break;
              }
              if (pages[page].imageinfo[0].url) {
                //.responsiveUrls["2"]
                //  console.log(location);
                //  console.log(pages[page].imageinfo[0].url);
                await axios
                  .get(
                    `https://commons.wikimedia.org/w/api.php?action=query&titles=${pages[page].title}&prop=imageinfo&iiprop=extmetadata&format=json`
                  )
                  .then((res) => {
                    let page_key = Object.keys(res.data.query.pages)[0];
                    let tag =
                      res.data.query.pages[page_key].imageinfo[0].extmetadata;
                    let author = tag.Artist.value;
                    let license = tag.LicenseShortName.value;
                    if (license != "Public domain") {
                      let license_url = tag.LicenseUrl.value;
                      attribution = `${author}, ${license} <${license_url}>, via Wikimedia Commons`;
                    }
                    images.push({
                      thumb: pages[page].imageinfo[0].responsiveUrls["2"],
                      url: pages[page].imageinfo[0].url, //.responsiveUrls["2"]
                      attribution: attribution,
                    });
                    count++;
                  });
              }
            }
            //console.log(images);

            // The Gemini 1.5 models are versatile and work with both text-only and multimodal prompts
            const model = genAI.getGenerativeModel({
              model: "gemini-1.5-flash",
            });

            const model2 = genAI.getGenerativeModel({
              model: "gemini-1.0-pro",
            });

            //Zum Beispiel: "Beschreibe die Gemeinde **[Name der Gemeinde]** im **[Bundesland]** im Bezirk **[Bezirk]**."
            const prompt = `Beschreibe die Gemeinde ${name} in 150 Wörtern, auch etwas was fur touristen interessant sein koennte also die lage was mann machen kann z.B. machnchmal radfahren usw. und sehenswurdigkeit max 1-2 in den text reinbringen. Aber denke dir keine Sachen aus wenn es keine sehenswurdigkeiten gibt schreibe einfach uber keine, das ist dann auch uberhaupt kein problem. Verwende auch keine extremen ubertreibungen wie malerische Landschaft ausser wenn es wirklich stimmt wie bei zB Hallstadt. Manchmal gibt es in der nahe grosse freizeitaktivitaten wie aquaparks oder freizeitparks erehne die falls es welche in sehr nahe gibt.
              Hier einige Basisdaten zur Hilfe:
              Bevölkerung: ${einwohner},
              Bundeland: ${bundesland},
              Bezirk: ${bezirk}
          
              Hier eine gelungene beschreibung als beispiel:
              Deutsch Jahrndorf, eine beschauliche Gemeinde im Burgenland mit etwa 653 Einwohnern, liegt im Bezirk Neusiedl am See. Die ruhige Lage am Rande des Seewinkels bietet ideale Voraussetzungen zum Radfahren und Wandern, zum Beispiel entlang der Seewinkelradroute. Entdecken Sie die reiche Vogelwelt des Nationalparks Neusiedler See – Seewinkel, der nur einen Katzensprung entfernt liegt. 
              `;

            // const result = await model.generateContent(prompt);
            //     const response2 = await result.response;
            //    const beschreibung = response2.text();
            //    console.log(beschreibung);

            //const prompt2 = `what are the opening hours of the Gemeindeamt in Andau? according to this link here, the link: https://www.google.com/maps/place/Gemeindeamt+Andau/@47.775325,17.0318443,18.77z/data=!4m6!3m5!1s0x476c72d74e4cc7c1:0x7497d0369a867448!8m2!3d47.7749682!4d17.0326502!16s%2Fg%2F1tfk36vx?entry=ttu`;
            /*   const result2 = await model2.generateContent(prompt2);
            const response22 = await result2.response;
            const beschreibung2 = response22.text();
            console.log(beschreibung2);*/

            /*  get_opening_hours.get_opening_hours(
              "Gemeindeamt",
              `${location.latitude},${location.longitude}`
            );*/

            const content = {
              name: name,
              code: gemeinde,
              wappen: wappen,
              bilder: images,
              //        beschreibung: beschreibung,
              plz: plz.replace("\n", ""),
              kennziffer: kennziffer,
              burgermeister: burgerking,
              flaeche: area,
              homepage: seite,
              bezirk: bezirk,
              bundesland: bundesland,
              email: email,
              tel: telefon1,
              tel_int: telefon2,
              adress: adresse.replace("\n", ""),
              location: location,
              population: einwohner,
            };
            console.log(content);
            console.log("Data received successfully!");

            fs.writeFile(
              `gemeinden/${gemeinde}.json`, // /Users/alexpolan/gk360/node_scripts/
              JSON.stringify(content)
            );

            /*  await axios
              .post(
                "https://alex.polan.sk/api/gemeinde-kompass-360/write_data.php",
                qs.stringify({ gemeinde: content })
              )
              .then((res) => {
                console.log(res.data);
                console.log("Data written successfully!");
              });*/

            await axios
              .post("https://www.gk360.at/api/write.php", content)
              .then((res) => {
                console.log(res.data);
                console.log("Data written successfully!");
              });
          })
          .catch(function (error) {
            console.log(error);
          });
      });
  } catch (error) {
    fss.appendFile(
      "logs/error_log.txt", ///Users/alexpolan/gk360/node_scripts/
      gemeinde + " An error occurred: " + error.message + "\n\n",
      (err) => {
        if (err) throw err;
        console.log("Error logged in error_log.txt");
      }
    );
  }
}

fss.readFile(
  //`/Users/alexpolan/gk360/node_scripts/json/all.json`,
  "json/all.json",
  "utf-8",
  (err, data) => {
    if (err) {
      console.error("An error occurred:", err.message);
      return;
    } else {
      const gemeinden = JSON.parse(data);
      gemeinden.forEach((gemeinde, index) => {
        setTimeout(() => {
          getData(gemeinde.name, gemeinde.population);
        }, index * 9200);
      });
    }
  }
);
