(function (ViewController) {

    var LineUp = require('../models/LineUp.js');
    var Week = require('../models/Week.js');
    var Song = require('../models/Song.js');
    var Artist = require('../models/Artist.js');
    var Release = require('../models/Release.js');
    var Points = require('../models/Points.js');
    

    ObjectID = require('mongodb').ObjectID;
    
    ViewController.viewPoints = function (req, res, leagueID, weekID, callback) {
        var errorhandlingResponse = { "success": false };

        //**FINISH
        callback(res, errorhandlingResponse);
    }
    
    ViewController.getNeededConfirmations = function (req, res, leagueID, callback) {
        var errorhandlingResponse = { "success": false };
        
        //**FINISH
        callback(res, errorhandlingResponse);
    }
    
    ViewController.summarizePoints = function (req, res, lineupID, callback) {
        var errorhandlingResponse = { "success": false };
        
        //**FINISH
        callback(res, errorhandlingResponse);
    }

    ViewController.thresholdOK = function (req, res, lineupID, callback){
        var errorhandlingResponse = { "success": false };

        console.log("calling  db.points.find({'lineupID':'" + lineupID + "'}).sort({ 'datecreated': -1 }).limit(1) yielded nothing...")

        Points.find({ "lineupID": lineupID }).sort({ "datecreated": -1 }).limit(1).exec(function (err, dataPoints) {
            if (err) {
                callback(res, errorhandlingResponse);
            }
            else {
                if (dataPoints.length > 0) {
                    //get the datecreated.
                    var lastDateCreated = dataPoints[0].datecreated;
                    //console.log(lastDateCreated);
                    //now compare that 
                    var currentDate = new Date();
                    currentDate.setDate(currentDate.getDate());
                    var diffMs = (currentDate - lastDateCreated);
                    var secondselapsed = Math.floor((diffMs / 1000));
                    console.log(secondselapsed);
                    if (secondselapsed < 180) {
                        callback(res, errorhandlingResponse);
                    }
                    else {
                        callback(res, { "success": true });
                    }
                }
                else {
                    //no points in system...
                    callback(res, { "success": true });
                }
            }
        });
    }

    ViewController.getLineUp = function (req, res, userxleagueID, weekID, callback) {
        var errorhandlingResponse = { "success": false };
        LineUp.findOne({ "userxleagueID": userxleagueID, "weekID": weekID }, function (err, dataLineUp) {
            if (err) {
                console.log(err);
                callback(res, errorhandlingResponse);
            }
            else {
                if (dataLineUp) {
                    Song.findOne({ "_id": ObjectID(dataLineUp.songID) }, function (err, dataSong) {
                        Artist.findOne({ "_id": ObjectID(dataLineUp.artistID) }, function (err, dataArtist) {
                            Release.findOne({ "_id": ObjectID(dataLineUp.releaseID) }, function (err, dataRelease) {

                                var songID = "";
                                var artistID = "";
                                var releaseID = "";
                                var song = "";
                                var artist = "";
                                var discogArtistID = 0;
                                var release = "";
                                var discogReleaseID = 0;

                                if (dataLineUp.songID) {
                                    songID = dataLineUp.songID;
                                }
                                if (dataLineUp.artistID) {
                                    artistID = dataLineUp.artistID;
                                }
                                if (dataLineUp.releaseID) {
                                    releaseID = dataLineUp.releaseID;
                                }
                                if (dataSong) {
                                    if (dataSong.title) {
                                        song = dataSong.title;
                                    }
                                }
                                if (dataArtist) {
                                    if (dataArtist.artist) {
                                        artist = dataArtist.artist;
                                    }
                                    
                                    if (dataArtist.discogArtistID) {
                                        discogArtistID = dataArtist.discogArtistID;
                                    }
                                }
                                if (dataRelease) {
                                    if (dataRelease.release) {
                                        release = dataRelease.release;
                                    }
                                    if (dataRelease.discogReleaseID) {
                                        discogReleaseID = dataRelease.discogReleaseID;
                                    }
                                }
                                
                                var returnJSON = {
                                    "success": true ,
                                    "_id" : dataLineUp._id.toString(), 
                                    "weekID": dataLineUp.weekID,
                                    "songID": songID,
                                    "artistID": artistID,
                                    "releaseID": releaseID,
                                    "song": song,
                                    "artist" : artist,
                                    "discogArtistID": discogArtistID,
                                    "release" : release,
                                    "discogReleaseID": discogReleaseID
                                }
                                callback(res, returnJSON);
                            });
                        });
                    });
                }
                else {
                    console.log("no LineUp");
                    callback(res, errorhandlingResponse);
                }
            }
        });
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


})(module.exports);
    