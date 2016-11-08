module.exports = function (app, settings) {
    
    var League = require('../models/League.js');
    var Login = require('../models/Login.js');
    
    
    var url = require('url'), 
        express = require('express'), 
        rRouter = express.Router();
    
    var authentication = require("../controllers/Authentication");
    var scoringcontroller = require("../controllers/ScoringController");
    
    var debugging = true;
    
    rRouter.use(function (req, res, next) {
        // do logging that any /api call got made 
        if (debugging) {
            console.log('Something is happening in /api/scoring layer.');
        }
        next();
    });
    
    rRouter.get("/points/heardsong/:userName/:leagueID/:song/:songID/:lineupID/:logintoken", function (req, res) {
        var lineupID = req.params.lineupID;
        var logintoken = req.params.logintoken;
        var userName = req.params.userName;
        var song = req.params.song;
        var songID = req.params.songID;
        var leagueID = req.params.leagueID;
        authentication.iftokenvalid(logintoken, function (err, valid) {
            if (valid) {
                scoringcontroller.heardSong(req, res, lineupID, leagueID, userName, song, songID, sendResponse);
            }
            else {
                res.json({ "success": false , message: 'token not valid' });
            }
        });
    });
    
    rRouter.get("/points/heardartist/:userName/:leagueID/:artist/:artistID/:lineupID/:logintoken", function (req, res) {
        var lineupID = req.params.lineupID;
        var logintoken = req.params.logintoken;
        var userName = req.params.userName;
        var artist = req.params.artist;
        var artistID = req.params.artistID;
        var leagueID = req.params.leagueID;
        authentication.iftokenvalid(logintoken, function (err, valid) {
            if (valid) {
                scoringcontroller.heardArtist(req, res, lineupID, leagueID, userName, artist, artistID, sendResponse);
            }
            else {
                res.json({ "success": false , message: 'token not valid' });
            }
        });
    });
    
    rRouter.get("/points/heardrelease/:userName/:leagueID/:release/:releaseID/:lineupID/:logintoken", function (req, res) {
        var lineupID = req.params.lineupID;
        var logintoken = req.params.logintoken;
        var userName = req.params.userName;
        var release = req.params.release;
        var releaseID = req.params.releaseID;
        var leagueID = req.params.leagueID;
        authentication.iftokenvalid(logintoken, function (err, valid) {
            if (valid) {
                scoringcontroller.heardRelease(req, res, lineupID, leagueID, userName, release, releaseID, sendResponse);
            }
            else {
                res.json({ "success": false , message: 'token not valid' });
            }
        });
    });
    
    rRouter.get("/confirmed/:pointID/:userID/:logintoken", function (req, res) {
        var pointID = req.params.pointID;
        var logintoken = req.params.logintoken;
        var userID = req.params.userID;
        authentication.iftokenvalid(logintoken, function (err, valid) {
            if (valid) {
                scoringcontroller.confirmed(req, res, pointID, userID, sendResponse);
            }
            else {
                res.json({ "success": false , message: 'token not valid' });
            }
        });
    });

    //generic send reponse.
    function sendResponse(res, response) {
        res.json(response);
    }
    
    app.use('/api/scoring', rRouter);
}; 