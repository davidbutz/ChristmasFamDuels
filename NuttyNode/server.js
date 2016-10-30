
var http = require('http');

var port = 1337;//process.env.port || 1337;
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var config = require('./config/index.js');

var controllers = require("./controllers");

var settings = {
    config: config
};

// Web layer configuration.

// configure app to use bodyParser()
// this will let us get the data from a POST
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.set("view engine", "vash");
controllers.init(app);

// Below is a command that allows public exposure to items.
app.use(express.static(__dirname + "/public"));
app.use(express.static(__dirname + "/ReleaseScripts"));

// REGISTER OUR ROUTES -------------------------------
// all of our routes will be prefixed with /api
//app.use('/api', require('./routes')(app,settings));
routes = require('./routes')(app, settings);

var server = http.createServer(app);
server.listen(port);
