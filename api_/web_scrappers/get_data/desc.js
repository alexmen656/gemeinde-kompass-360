//const axios = require("axios");
//const qs = require("qs");

const { GoogleGenerativeAI } = require("@google/generative-ai");
const genAI = new GoogleGenerativeAI("**currently not in use**");//process.env.API_KEY

// ...

// The Gemini 1.5 models are versatile and work with most use cases
//const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash"});

// ...

async function generate_description(gemeinde) {
    // The Gemini 1.5 models are versatile and work with both text-only and multimodal prompts
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash"});
  
    const prompt = `Beschreibe die Gemeinde ${gemeinde.name} in 150 Wörtern, auch etwas was fur touristen interessant sein koennte also die lage was mann machen kann z.B. machnchmal radfahren usw. und sehenswurdigkeit max 1-2 in den text reinbringen. Aber denke dir keine Sachen aus wenn es keine sehenswurdigkeiten gibt schreibe einfach uber keine, das ist dann auch uberhaupt kein problem. Verwende auch keine extremen ubertreibungen wie malerische Landschaft ausser wenn es wirklich stimmt wie bei zB Hallstadt. Manchmal gibt es in der nahe grosse freizeitaktivitaten wie aquaparks oder freizeitparks erehne die falls es welche in sehr nahe gibt.
    Hier einige Basisdaten zur Hilfe:
    Bevölkerung: ${gemeinde.einwohner},
    Bundeland: ${gemeinde.bundesland},
    Bezirk: ${gemeinde.bezirk}

    Hier eine gelungene beschreibung als beispiel:
    Deutsch Jahrndorf, eine beschauliche Gemeinde im Burgenland mit etwa 653 Einwohnern, liegt im Bezirk Neusiedl am See. Die ruhige Lage am Rande des Seewinkels bietet ideale Voraussetzungen zum Radfahren und Wandern, zum Beispiel entlang der Seewinkelradroute. Entdecken Sie die reiche Vogelwelt des Nationalparks Neusiedler See – Seewinkel, der nur einen Katzensprung entfernt liegt. 
    `;
  
    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();
    console.log(text);
  }
  
  generate_description({name: "Pama", einwohner: 983, bundesland: "Burgenland", bezirk: "Neusiedl am See"});
  generate_description({name: "Deutsch Jahrndorf", einwohner: 653, bundesland: "Burgenland", bezirk: "Neusiedl am See"});
  generate_description({name: "St. Margarethen im Burgenland", einwohner: 653, bundesland: "Burgenland", bezirk: "Eisenstadt Umgebung"});