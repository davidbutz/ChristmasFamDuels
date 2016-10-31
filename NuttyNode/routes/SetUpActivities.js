//routes/SetUpActivities.js
module.exports = function (app, settings) {

    var url = require('url'), 
        express = require('express'), 
        rRouter = express.Router();
    
    var leaguecontroller = require("../controllers/LeagueController");
    var authentication = require("../controllers/Authentication");

    rRouter.use(function (req, res, next) {
        // do logging that any /api call got madevv 
        console.log('Something is happening in /api/users layer.');
        next();
    });
    
    
    //user creates a new league
    rRouter.get("/league/create/:userID/:leagueName/:logintoken", function (req, res) {
        var userID = req.params.userID;
        var leagueName = req.params.leagueName;
        var logintoken = req.params.logintoken;
        authentication.iftokenvalid(login_token, function (err, valid) {
            if (valid) {
                leaguecontroller.addLeague(req, res, userID, leagueName, "2016", sendResponse);
            }
            else {
                res.json({ "success": false , message: 'token not valid' });
            }
        });
    });
    
    
    //user sends 'email invitation' to join league
    rRouter.get("/league/invite/:userID/:leagueID/:email/:logintoken", function (req, res) {
        var userID = req.params.userID;
        var leagueID = req.params.leagueID;
        var email = req.params.email;
        var logintoken = req.params.logintoken;
        authentication.iftokenvalid(login_token, function (err, valid) {
            if (valid) {
                leaguecontroller.inviteToLeague(req, res, userID, leagueID, email, sendResponse);
            }
            else {
                res.json({ status: 'error', message: 'token not valid' });
            }
        });
    });
    
    //user searches for existing leagues
    //user creates 'request to join' a league
    //league owner user accepts 'request to join' 
    
    //user accepts 'email invitation' to join. Presents the user with quick set up.
    rRouter.get("/league/acceptinvite/:userID/:token/:email", function (req, res) {
        var userID = req.params.userID;
        var token = req.params.token;
        leaguecontroller.acceptInvitation(req, res, userID, token, sendResponse);
    });
    

    //user asks to get a list of leagues they belong to.
    rRouter.get("/getleagues/:userID/:logintoken", function (req, res) {
        var userID = req.params.userID;
        var logintoken = req.params.logintoken;
        authentication.iftokenvalid(login_token, function (err, valid) {
            if (valid) {
                leaguecontroller.getLeagues(req, res, userID, sendResponse);
            }
            else {
                res.json({ success: false, message: 'token not valid' });
            }
        });
    });
    
    //generic send reponse.
    function sendResponse(res, response) {
        res.json(response);
    }

    app.use('/api/setup', rRouter);
}; 