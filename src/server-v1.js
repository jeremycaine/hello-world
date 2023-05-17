const express = require("express");
const app = express();

const PORT = process.env.PORT || 3000;

const version = "v1";
const desc = "Simple server; No Signal intercept"
const message = `Build:\n-version: ${version}\n-description: ${desc}\n`;

app.get("/", (req, res) => {
  console.log(`hello-world called`);
  res.send(`Hello World ! (version ${version})\n`);
});

const server = app.listen(PORT, () => {
  console.log(message);
  console.log(`Process ID: ${process.pid}`);
  console.log(`Server version is running on http://localhost:${PORT}`);
});

module.exports = app;
