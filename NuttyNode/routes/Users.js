//routes/Accounts.js
module.exports = function (app, settings) {
    var User = require('../models/User.js');
    var url = require('url'), 
        express = require('express'), 
        rRouter = express.Router();
    
    rRouter.use(function (req, res, next) {
        // do logging that any /api call got madevv 
        console.log('Something is happening in /api/users layer.');
        next();
    });
    

    
    rRouter.post("/", function (req, res) {
        var user = new User(req);
        user.save(function (err) {
            if (err)
                res.send(err);
            
            res.json({ message: 'users created!' });
        });
    });
    

    
    app.use('/api/users', rRouter);
}; 