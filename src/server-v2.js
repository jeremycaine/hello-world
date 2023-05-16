const express = require("express")
const app = express();

const PORT = process.env.PORT || 3000;

const version = "v2";
const desc = "Simple server; With Signal intercept"
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

function shutdown(signal) {
  console.log(`${signal} signal received`);
  server.close();
  console.log('HTTP server closed');
  console.log(`hello-world app shutting down`);
  process.exit();
}


// https://thomashunter.name/posts/2021-03-08-the-death-of-a-nodejs-process
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);

module.exports = server;
