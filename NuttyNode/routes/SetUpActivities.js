//routes/SetUpActivities.js
module.exports = function (app, settings) {
    var User = require('../models/User.js');
    var League = require('../models/League.js');
    var UserXLeague = require('../models/UserXLeague.js');
    var url = require('url'), 
        express = require('express'), 
        rRouter = express.Router();
    
    rRouter.use(function (req, res, next) {
        // do logging that any /api call got madevv 
        console.log('Something is happening in /api/users layer.');
        next();
    });
    
    
    //users adds themselves to the system.
    rRouter.post("/users", function (req, res) {
        var user = new User(req);
        user.save(function (err) {
            if (err)
                res.send(err);
            
            res.json({ message: 'users created!' });
        });
    });
    
    //users call to get a list of leagues they belong to.
    rRouter.get("/getleagues/:user_id", function (req, res) {
        var user_id = req.params.user_id;
        UserXLeague.find({ "userID": user_id }, function (err, dataUserXLeagues) {
            var array_userleagues = [];
            for (var i = 0; i < dataUserXLeagues.length; i++) {
                array_userleagues.push(dataUserXLeagues[i].leagueID);
            }
            League.find({ "_id": { $in: arraydevices } }, function (err, dataLeague) {
                sendresponse(res, dataLeague);
            });
        });
    });
    
    //generic send reponse.
    function sendresponse(res, response) {
        res.json(response);
    }

    app.use('/api/setup', rRouter);
}; 