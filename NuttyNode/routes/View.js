module.exports = function (app, settings) {
    
    var League = require('../models/League.js');
    var Login = require('../models/Login.js');
    

    var url = require('url'), 
        express = require('express'), 
        rRouter = express.Router();
    
    var authentication = require("../controllers/Authentication");
    var viewcontroller = require("../controllers/ViewController");
    
    var debugging = true;
    
    rRouter.use(function (req, res, next) {
        // do logging that any /api call got made 
        if (debugging) {
            console.log('Something is happening in /api/view layer.');
        }
        next();
    });
    
    
    ///summarizepoints/:lineupID/:logintoken
    //summarize your points so far...
    rRouter.get("/summarizepoints/:lineupID/:logintoken", function (req, res) {
        var lineupID = req.params.lineupID;
        var logintoken = req.params.logintoken;
        authentication.iftokenvalid(logintoken, function (err, valid) {
            if (valid) {
                viewcontroller.summarizePoints(req, res, lineupID, sendResponse);
            }
            else {
                res.json({ "success": false , message: 'token not valid' });
            }
        });
    });

    //check if user is scamming system by clicking too much...
    rRouter.get("/getNeededConfirmations/:leagueID/:logintoken", function (req, res) {
        var leagueID = req.params.leagueID;
        var logintoken = req.params.logintoken;
        authentication.iftokenvalid(logintoken, function (err, valid) {
            if (valid) {
                viewcontroller.getNeededConfirmations(req, res, leagueID, sendResponse);
            }
            else {
                res.json({ "success": false , message: 'token not valid' });
            }
        });
    });

    //check if user is scamming system by clicking too much...
    rRouter.get("/thresholdOK/:lineupID/:logintoken", function (req, res) {
        var lineupID = req.params.lineupID;
        var logintoken = req.params.logintoken;
        authentication.iftokenvalid(logintoken, function (err, valid) {
            if (valid) {
                viewcontroller.thresholdOK(req, res, lineupID, sendResponse);
            }
            else {
                res.json({ "success": false , message: 'token not valid' });
            }
        });
    });
    

    //user gets their lineup for the week.
    rRouter.get("/getLineUp/:weekID/:userxleagueID/:logintoken", function (req, res) {
        var userxleagueID = req.params.userxleagueID;
        var weekID = req.params.weekID;
        var logintoken = req.params.logintoken;
        authentication.iftokenvalid(logintoken, function (err, valid) {
            if (valid) {
                viewcontroller.getLineUp(req, res, userxleagueID, weekID, sendResponse);
            }
            else {
                res.json({ "success": false , message: 'token not valid' });
            }
        });
    });
    
    rRouter.get("/points/:weekID/:leagueID/:logintoken", function (req, res) {
        var leagueID = req.params.leagueID;
        var weekID = req.params.weekID;
        var logintoken = req.params.logintoken;
        authentication.iftokenvalid(logintoken, function (err, valid) {
            if (valid) {
                viewcontroller.viewPoints(req, res, leagueID, weekID, sendResponse);
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
    app.use('/api/view', rRouter);
}; 