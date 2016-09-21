// What is this page?:
// Essentially it is the Web API layer to communicate with sensor data
// Intended for prototyping the MongoDB on Controller/Hub Raspberry Pi.
var http = require('http');

//TO DO : This could technically come from the pre-populated "Controllers" data model.
var port = 80;//process.env.port || 1337;
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var config = require('./config/index.js');

//var ejsEngine = require('ejs-locals');
var controllers = require("./controllers");
//var mongoose = require('mongoose');

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

// REGISTER OUR ROUTES -------------------------------
// all of our routes will be prefixed with /api
//app.use('/api', require('./routes')(app,settings));
routes = require('./routes')(app, settings);


var server = http.createServer(app);
server.listen(port);
