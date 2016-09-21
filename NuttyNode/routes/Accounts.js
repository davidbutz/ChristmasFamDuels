//routes/Accounts.js
module.exports = function (app, settings) {
    var Account = require('../models/Accounts.js');
    var url = require('url'), 
        express = require('express'), 
        rRouter = express.Router();

    rRouter.use(function (req, res, next) {
        // do logging that any /api call got made 
        console.log('Something is happening in /api/accounts layer.');
        next();
    });
    
    // will handle any request that ends in /events
    // depends on where the router is "use()'d"
    rRouter.get('/events', function (req, res, next) {
  // ..
    });
    
    rRouter.post("/", function (req, res) {
        var account = new Account(req);
        account.save(function (err) {
            if (err)
                res.send(err);
                
            res.json({ message: 'account created!' });
        });
    });
    
    rRouter.get("/", function (req, res) {
        Account.find(function (err, accounts) {
            if (err)
                res.send(err);
            
            res.json(accounts);
        });
    });
    
    app.use('/api/accounts', rRouter);
}; 