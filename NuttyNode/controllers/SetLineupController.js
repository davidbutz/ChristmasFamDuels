(function (SetLineupController) {

    //DB models used.
    var League = require('../models/League.js');
    var UserXLeague = require('../models/UserXLeague.js');
    var Login = require('../models/Login.js');
    var User = require('../models/User.js');
    var PasswordResetRequest = require("../models/PasswordResetRequest.js");
    var NotificationToken = require("../models/NotificationToken.js");
    var Week = require("../models/Week.js");

    //controls used.
    var crypto = require("crypto");
    ObjectID = require('mongodb').ObjectID;
    
    //3rd party librarys used.
    var mongoosesync = require('mongoose');
    
    //standard configuration
    var config = require('../config/index.js');
    var settings = {
        config: config
    };

    var MongoClient = require('mongodb').MongoClient;
    var db;
    MongoClient.connect(settings.config().MONGOCONNMONGDB, function (err, database) {
        console.log("i am here");
        if (err) {
            console.log(err);
            if (db !== undefined) {
                console.log(typeof (db));
                try {
                    db.close();
                }
                catch (e) {
                    console.log(e);
                }
            }
        }
        else {
            db = database;
        }
    });
    var debugging = false;

    function mongocallback(err, numAffected) {
        // numAffected is the number of updated documents
        if (err) {
            console.log("error!!!");
            console.log(err);
        }
    }
    
    function dateFormat(date, fstr, utc) {
        utc = utc ? 'getUTC' : 'get';
        return fstr.replace(/%[YmdHMS]/g, function (m) {
            switch (m) {
                case '%Y': return date[utc + 'FullYear'](); // no leading zeros required
                case '%m': m = 1 + date[utc + 'Month'](); break;
                case '%d': m = date[utc + 'Date'](); break;
                case '%H': m = date[utc + 'Hours'](); break;
                case '%M': m = date[utc + 'Minutes'](); break;
                case '%S': m = date[utc + 'Seconds'](); break;
                default: return m.slice(1); // unknown code, remove %
            }
            // add leading zero if required
            return ('0' + m).slice(-2);
        });
    }
    
    SetLineupController.getNextWeekID = function (res, callback) {
        var currentDate = new Date();
        currentDate.setDate(currentDate.getDate() + 7);
        var queryDate = dateFormat(new Date(currentDate), "%Y-%m-%d %H:%M:%S", false);
        var year = currentDate.getFullYear();
        
        var collection = db.collection('weeks').find({ "weekYear": year , $and : [{ "weekStart" : { $lte : new Date(queryDate) } }, { "weekEnd": { $gte : new Date(queryDate) } }] });
        collection.toArray(function (err, docs) {
            if (docs) {
                if (docs.length > 0) {
                    console.log(docs);
                    callback(res, { "success": true });
                }
                else {
                    callback(res, { "success": false });
                }
            }
            else {
                callback(res, { "success": false });
            }
        });
    }

    SetLineupController.getCurrentWeekID = function (res, callback) {
        var currentDate = new Date();
        var queryDate = dateFormat(new Date(currentDate), "%Y-%m-%d %H:%M:%S", false);
        var year = currentDate.getFullYear();

        var collection = db.collection('weeks').find({ "weekYear": year , $and : [{ "weekStart" : { $lte : new Date(queryDate) } }, { "weekEnd": { $gte : new Date(queryDate) } }] });
        collection.toArray(function (err, docs) {
            if (docs) {
                if (docs.length > 0) {
                    console.log(docs);
                    callback(res, { "success": true });
                }
                else {
                    callback(res, { "success": false });
                }
            }
            else {
                callback(res, { "success": false });
            }
        });
    }
})(module.exports);