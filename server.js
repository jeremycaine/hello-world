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

function shutdown(signal) {
  console.log(`${signal} signal received`);
  server.close();
  console.log('HTTP server closed');
  console.log(`hello-world app release ${release} shutting down`);
  process.exit();
}

//process.on('SIGINT', shutdown);
//process.on('SIGTERM', shutdown);

// https://thomashunter.name/posts/2021-03-08-the-death-of-a-nodejs-process