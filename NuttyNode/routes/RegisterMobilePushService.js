﻿//routes/RegisterMobilePushService.js
/* 
 * Route handles iOS/Android app launching, then registering the DeviceID with our MongoDB.
 * This will be used to push Notifications
 * 
*/
module.exports = function (app, settings) {
    
    var url = require('url'), 
        express = require('express'), 
        rRouter = express.Router();
    
    var authentication = require("../controllers/Authentication");
    var christmasfamduelscontroller = require("../controllers/ChristmasFamDuelsController");
    
    rRouter.use(function (req, res, next) {
        next();
    });
    
    
    rRouter.get("/iOS/:notification_token/:leagueID/:userID/:logintoken", function (req, res) {
        var notification_token = req.params.notification_token;
        var leagueID = req.params.leagueID;
        var login_token = req.params.logintoken;
        var userID = req.params.userID;
        authentication.iftokenvalid(login_token, function (err, valid) {
            if (valid) {
                christmasfamduelscontroller.saveiOSNotificationToken(req, res, notification_token, leagueID, userID, sendresponse);
            }
            else {
                res.json({ "success": false });
            }
        });
    });
    
    
    //generic send reponse.
    function sendresponse(res, response) {
        res.json(response);
    }
    
    app.use('/api/registerNotifications', rRouter);
}; 