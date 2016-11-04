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
            console.log('Something is happening in /api/accounts layer.');
        }
        next();
    });
    
    ///api/setlineup/week/getcurrent/:logintoken
    rRouter.get("/week/getcurrent/:logintoken", function (req, res) {
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
    //user logins with token and supplies app with data
    rRouter.get("/loginTokenValid/:logintoken", function (req, res) {
        var login_token = req.params.logintoken;
        authentication.iftokenvalid(login_token, function (err, valid) {
            if (valid) {
                authentication.getAccountInformationFromToken(req, res, login_token, sendresponse);
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