const express = require("express");
const app = express();

app.get("/", function (req, res) {
  setTimeout(() => {
    res.status(200).send("okk");
  }, 1000);
});
app.get("/health-check", function (req, res) {
  res.status(200).send("healthy");
});
const server = app.listen(5000, function () {
  console.log("Web application is listening on port 5000");
});

const startGracefulShutdown = () => {
  console.log("Starting shutdown of express...");
  server.close(function () {
    console.log("Express shut down.");
  });
};

process.on("SIGTERM", startGracefulShutdown);
process.on("SIGINT", startGracefulShutdown);
