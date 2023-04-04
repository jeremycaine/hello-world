const express = require("express")
const app = express();

const PORT = process.env.PORT || 3000;

app.get("/", (req, res) => {
  res.send("Hello World!\n");
})

const server = app.listen(PORT, () =>
  console.log(`Server is running on http://localhost:${PORT}`)
);

function shutdown(signal) {
  console.log(`${signal} signal received`);
  server.close();
  console.log('HTTP server closed');
  console.log('hello-world app shutting down');
  process.exit();
}

//process.on('SIGINT', shutdown);
//process.on('SIGTERM', shutdown);

// https://thomashunter.name/posts/2021-03-08-the-death-of-a-nodejs-process