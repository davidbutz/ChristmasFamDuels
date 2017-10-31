module.exports = function (app, settings) {
    
    var League = require('../models/League.js');
    var Login = require('../models/Login.js');
    
    var url = require('url'), 
        express = require('express'), 
        rRouter = express.Router();
    
    var authentication = require("../controllers/Authentication");
    var setlineupcontroller = require("../controllers/SetLineupController");
    
    var debugging = true;
    
    rRouter.use(function (req, res, next) {
        // do logging that any /api call got made 
        if (debugging) {
            console.log('Something is happening in /api/setlineup layer.');
        }
        next();
    });
    
    ///api/setlineup/week/getcurrent/:logintoken
    rRouter.get("/week/getcurrent/:logintoken", function (req, res) {
        console.log("getcurrent");
        var login_token = req.params.logintoken;
        authentication.iftokenvalid(login_token, function (err, valid) {
            if (valid) {
                setlineupcontroller.getCurrentWeekID(res, sendresponse);
            }
            else {
                sendresponse(res, { success: false, message: 'token not valid' });
            }
        });
    });
    
    ///api/setlineup/week/getnext/:logintoken
    rRouter.get("/week/getnext/:logintoken", function (req, res) {
        console.log("getnext");
        var login_token = req.params.logintoken;
        authentication.iftokenvalid(login_token, function (err, valid) {
            if (valid) {
                setlineupcontroller.getNextWeekID(res, sendresponse);
            }
            else {
                sendresponse(res, { success: false, message: 'token not valid' });
            }
        });
    });
    
    rRouter.get("/add/song/:title/:logintoken", function (req, res) {
        console.log("addsong");
        var login_token = req.params.logintoken;
        var title = req.params.title;
        authentication.iftokenvalid(login_token, function (err, valid) {
            if (valid) {
                setlineupcontroller.addSong(res, title, sendresponse);
            }
            else {
                sendresponse(res, { success: false, message: 'token not valid' });
            }
        });
    });
    
    ///api/setlineup/search/song/:keywords/:logintoken/:userID/:weekID"
    rRouter.get("/search/song/:keywords/:logintoken/:userID/:weekID", function (req, res) {
        var login_token = req.params.logintoken;
        var keywords = req.params.keywords;
        var weekID = req.params.weekID;
        var userID = req.params.userID;
        authentication.iftokenvalid(login_token, function (err, valid) {
            if (valid) {
                setlineupcontroller.searchSong(res, keywords, userID, weekID, sendresponse);
            }
            else {
                sendresponse(res, { success: false, message: 'token not valid' });
            }
        });
    });
    
    rRouter.get("/add/artist/:artist/:discogArtistID/:logintoken", function (req, res) {
        var login_token = req.params.logintoken;
        var artist = req.params.artist;
        var discogArtistID = req.params.discogArtistID;
        authentication.iftokenvalid(login_token, function (err, valid) {
            if (valid) {
                setlineupcontroller.addArtist(res, artist, discogArtistID, sendresponse);
            }
            else {
                sendresponse(res, { success: false, message: 'token not valid' });
            }
        });
    });
    
    ///api/setlineup/search/song/:keywords/:logintoken
    rRouter.get("/search/artist/:keywords/:logintoken/:userID/:weekID", function (req, res) {
        var login_token = req.params.logintoken;
        var keywords = req.params.keywords;
        var weekID = req.params.weekID;
        var userID = req.params.userID;
        authentication.iftokenvalid(login_token, function (err, valid) {
            if (valid) {
                setlineupcontroller.searchArtist(res, keywords, userID, weekID, sendresponse);
            }
            else {
                sendresponse(res, { success: false, message: 'token not valid' });
            }
        });
    });
    
    
    rRouter.get("/add/release/:release/:discogReleaseID/:logintoken", function (req, res) {
        var login_token = req.params.logintoken;
        var release = req.params.release;
        var discogReleaseID = req.params.discogReleaseID;
        authentication.iftokenvalid(login_token, function (err, valid) {
            if (valid) {
                setlineupcontroller.addRelease(res, release, discogReleaseID, sendresponse);
            }
            else {
                sendresponse(res, { success: false, message: 'token not valid' });
            }
        });
    });
    
    rRouter.get("/search/release/:track/:artist/:logintoken/:userID/:weekID", function (req, res) {
        var login_token = req.params.logintoken;
        var track = req.params.track;
        var artist = req.params.artist;
        var weekID = req.params.weekID;
        var userID = req.params.userID;
        authentication.iftokenvalid(login_token, function (err, valid) {
            if (valid) {
                setlineupcontroller.searchRelease(res, track, artist, userID, weekID, sendresponse);
            }
            else {
                sendresponse(res, { success: false, message: 'token not valid' });
            }
        });
    });
    
    ///api/setlineup/artist/:logintoken/:leagueID/:userID/:artistID/:weekID
    rRouter.get("/artist/:logintoken/:leagueID/:userxleagueID/:artistID/:weekID", function (req, res) {
        var login_token = req.params.logintoken;
        var leagueID = req.params.leagueID;
        var artistID = req.params.artistID;
        var weekID = req.params.weekID;
        var userxleagueID = req.params.userxleagueID;
        authentication.iftokenvalid(login_token, function (err, valid) {
            if (valid) {
                setlineupcontroller.setLineUpArtist(res, leagueID, artistID, userxleagueID, weekID, sendresponse);
            }
            else {
                sendresponse(res, { success: false, message: 'token not valid' });
            }
        });
    });
    
    rRouter.get("/song/:logintoken/:leagueID/:userxleagueID/:songID/:weekID", function (req, res) {
        var login_token = req.params.logintoken;
        var leagueID = req.params.leagueID;
        var songID = req.params.songID;
        var weekID = req.params.weekID;
        var userxleagueID = req.params.userxleagueID;
        authentication.iftokenvalid(login_token, function (err, valid) {
            if (valid) {
                setlineupcontroller.setLineUpSong(res, leagueID, songID, userxleagueID, weekID, sendresponse);
            }
            else {
                sendresponse(res, { success: false, message: 'token not valid' });
            }
        });
    });
    
    
    rRouter.get("/release/:logintoken/:leagueID/:userxleagueID/:releaseID/:weekID", function (req, res) {
        var login_token = req.params.logintoken;
        var leagueID = req.params.leagueID;
        var releaseID = req.params.releaseID;
        var weekID = req.params.weekID;
        var userxleagueID = req.params.userxleagueID;
        authentication.iftokenvalid(login_token, function (err, valid) {
            if (valid) {
                setlineupcontroller.setLineUpRelease(res, leagueID, releaseID, userxleagueID, weekID, sendresponse);
            }
            else {
                sendresponse(res, { success: false, message: 'token not valid' });
            }
        });
    });
    
    //generic send reponse.
    function sendresponse(res, response) {
        res.json(response);
    }
    
    app.use('/api/setlineup', rRouter);
}; 