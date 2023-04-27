const express = require("express")
const app = express();

const PORT = process.env.PORT || 3000;
const release = "1";

app.get("/", (req, res) => {
  console.log(`called hello - release ${release}\n`);
  res.send(`Hello World ! (release ${release})\n`);
})

const server = app.listen(PORT, () =>
  console.log(`Server release ${release} is running on http://localhost:${PORT}`)
);

module.exports = server;
