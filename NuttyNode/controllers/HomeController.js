(function (homeController) {
    var data = require("../data");
    var config = require('../config/index.js');
    var settings = {
        config: config
    };
    homeController.init = function (app) {
        app.get("/", function (req, res) {
            res.render("index", { title: "ChristmasFamDuels", controller: settings.config().Version });
        });
        app.get("/resetPassword", function (req, res) {
            var requesttoken = req.query.requesttoken;
            //console.log('*********** 1TOKEN  *******************');
            //console.log(requesttoken);
            if (requesttoken) {
                //minor todo: validate requesttoken (we validate it on the post back)
                console.log('token present, needs validation then rendering.');
            }
            else {
                console.log('either no token in QS, or token invalid. Not handling for now.');
            }
            //todo: validate requesttoken
            res.render("resetPassword/index", { title: "Reset Password", OS: getMobileOperatingSystem(req), token: requesttoken, productionurl: settings.config().ProductionWeb });
        });
        app.get("/inviteUser", function (req, res) {
            var requesttoken = req.query.requesttoken;
            //console.log('*********** 1TOKEN  *******************');
            //console.log(requesttoken);
            if (requesttoken) {
                //minor todo: validate requesttoken (we validate it on the post back)
                console.log('token present, needs validation then rendering.');
            }
            else {
                console.log('either no token in QS, or token invalid. Not handling for now.');
            }
            //todo: validate requesttoken
            res.render("inviteUser/index", { title: "Accept Invitation", OS: getMobileOperatingSystem(req), token: requesttoken, productionurl: settings.config().ProductionWeb });
        });
    };
    
    function getMobileOperatingSystem(req) {
        var userAgent = req.headers['user-agent'];
        
        if (userAgent.match(/iPad/i) || userAgent.match(/iPhone/i) || userAgent.match(/iPod/i)) {
            return 'iOS';
        }
        else if (userAgent.match(/Android/i)) {
            return 'Android';
        }
        else {
            return userAgent;
        }
    }

})(module.exports);