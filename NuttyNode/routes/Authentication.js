module.exports = function (app, settings) {
    
    var League = require('../models/League.js');
    var Login = require('../models/Login.js');
    
    var url = require('url'), 
        express = require('express'), 
        rRouter = express.Router();
    
    var authentication = require("../controllers/Authentication");
    var christmasfamduelcontroller = require("../controllers/ChristmasFamDuelsController");
    
    var debugging = true;
    
    rRouter.use(function (req, res, next) {
        // do logging that any /api call got made 
        if (debugging) {
            console.log('Something is happening in /api/accounts layer.');
        }
        next();
    });
    
    //user requests a new password be sent to them.
    rRouter.get("/resetpassword/:email", function (req, res) {
        var email = req.params.email;
        var platform = "ios";
        christmasfamduelcontroller.resetPassword(req, res, email, platform, sendresponse);
    });
    
    //user supplies a new password and it is reset.
    rRouter.post("/changepassword", function (req, res) {
        var token = req.body.token;
        var password = req.body.password;
        christmasfamduelcontroller.changePassword(req, res, token, password, sendresponse);
    });

    //user logins
    rRouter.get("/loginTokenValid/:logintoken", function (req, res) {
        var login_token = req.params.logintoken;
        authentication.iftokenvalid(login_token, function (err, valid) {
            if (valid) {
                authentication.getAccountInformationFromToken(req, res, login_token, sendresponse);
            }
            else {
                res.json({ success: false, message: 'token not valid' });
            }
        });
    });
    
    
    rRouter.post("/authenticate", function (req, res) {
        authentication.authenticate(req, res);
    });
    

    //generic send reponse.
    function sendresponse(res, response) {
        res.json(response);
    }
    
    app.use('/api/accounts', rRouter);
}; 