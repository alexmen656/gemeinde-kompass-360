const { OpenAI } = require("openai");
const dotenv = require("dotenv");

const openai = new OpenAI({apiKey: "**currently not in use**"});

async function main() {
  const completion = await openai.chat.completions.create({
   //    messages: [{ role: "system", content: "Was sind die Öffnungzeiten der gemeinde antau? Durchsuche die Websites!" }],
 messages: [{ role: "system", content: "Dursuche die Homepage der gemeinde antau" }],
    model: "gpt-4o",
  });

  console.log(completion.choices[0]);
}

main();