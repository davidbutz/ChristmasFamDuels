//routes/RegisterMobilePushService.js
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
    
    
    rRouter.get("/iOS/:notification_token/:controller_id/:logintoken", function (req, res) {
        var notification_token = req.params.notification_token;
        var controller_id = req.params.controller_id;
        var login_token = req.params.logintoken;
        authentication.iftokenvalid(login_token, function (err, valid) {
            if (valid) {
                christmasfamduelscontroller.saveiOSNotificationToken(req, res, notification_token, controller_id, sendresponse);
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