(function (ViewController) {

    var LineUp = require('../models/LineUp.js');
    var Week = require('../models/Week.js');
    var Song = require('../models/Song.js');
    var Artist = require('../models/Artist.js');
    var Release = require('../models/Release.js');
    var Points = require('../models/Points.js');
    var UserXLeague = require('../models/UserXLeague.js');
    var User = require('../models/User.js');
    ObjectID = require('mongodb').ObjectID;
    
    //view league standings overall.....weekID is optional.
    ViewController.viewPoints = function (req, res, leagueID, weekID, callback) {
        var errorhandlingResponse = { "success": false };
        // Get League Members
        UserXLeague.find({ "leagueID": leagueID }, function (err, dataUserXLeague) {
            if (err) {
                console.log("error in UserXLeague.find");
                console.log(err);
                callback(res, errorhandlingResponse);
            }
            else {
                //console.log(dataUserXLeague);
                array_UserXLeague = [];
                for (var y = 0; y < dataUserXLeague.length; y++) {
                    array_UserXLeague.push(dataUserXLeague[y]._id.toString());
                }
                if (weekID != "") {
                    // If weekID <> "", then we get that week's lineups
                    console.log("weekID != ''");
                }
                else {
                    // we get all lineups!
                    LineUp.find({ "userxleagueID": { $in: array_UserXLeague } }, function (err, dataLineUp) {
                        //console.log(dataLineUp);
                        if (err) {
                            console.log("error in LineUp.find");
                            console.log(err);
                            callback(res, errorhandlingResponse);
                        }
                        else {
                            array_LineUp = [];
                            for (var y = 0; y < dataLineUp.length; y++) {
                                array_LineUp.push(dataLineUp[y]._id.toString());
                            }
                            // then get points...
                            Points.find({ "lineupID": { $in: array_LineUp } }, function (err, dataPoints) {
                                //console.log(dataPoints);
                                if (err) {
                                    console.log("error in Points.find");
                                    console.log(err);
                                    callback(res, errorhandlingResponse);
                                }
                                else {
                                    var array_UserXLeague_userID = [];
                                    for (var y = 0; y < dataUserXLeague.length; y++) {
                                        array_UserXLeague_userID.push(dataUserXLeague[y].userID.toString());
                                    }

                                    // then get Users...
                                    User.find({ "_id": { $in: array_UserXLeague_userID } }, function (err, dataUser) {
                                        if (err) {
                                            console.log("error in User.find");
                                            console.log(err);
                                            callback(res, errorhandlingResponse);
                                        }
                                        else {
                                            var PointsEarned = 0;
                                            var output = [];
                                            //console.log(dataUser.length);
                                            //now we build up this elaborate matrix of the user, points (confirmed)
                                            for (var a = 0; a < dataUser.length; a++) {
                                                PointsEarned = 0;
                                                for (var b = 0; b < dataPoints.length; b++) {
                                                    for (var c = 0; c < dataLineUp.length; c++) {
                                                        for (var d = 0; d < dataUserXLeague.length; d++) {
                                                            //points need to be :
                                                            // confirmed
                                                            // attached to a lineup which is attached to a league which is attached to this user
                                                            if (dataPoints[b].lineupID.toString() == dataLineUp[c]._id.toString() && dataLineUp[c].userxleagueID.toString() == dataUserXLeague[d]._id.toString() && dataUserXLeague[d].userID.toString() == dataUser[a]._id.toString()) {
                                                                if (dataPoints[b].confirmationuserID) {
                                                                    PointsEarned += dataPoints[b].score;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                //console.log(dataUser[a].fname + " " + dataUser[a].lname);
                                                output.push({ "name": dataUser[a].fname + " " + dataUser[a].lname, "score": PointsEarned });
                                            }
                                            //var sampleoutput = [{ "userName": "Mary Butz", "points": 24 },{ "userName": "Mary Butz", "points": 44} ]
                                            //then sort it by points.
                                            output.sort(function (a, b) {
                                                return parseFloat(b.score) - parseFloat(a.score);
                                            });
                                            callback(res, { "success": true, "outputarray": output });
                                        }
                                    });
                                }
                            });
                        }
                    });
                }
            }
        });
    }
    
    ViewController.getNeededConfirmations = function (req, res, leagueID, userID, weekID, callback) {
        var errorhandlingResponse = { "success": false };
        var showmyownpoints = false;
        // for these userxleagues
        UserXLeague.find({ "leagueID": leagueID }, function (err, dataUserXLeague) {
            if (err) {
                console.log("error in UserXLeague.find");
                console.log(err);
                callback(res, errorhandlingResponse);
            }
            else {
                // minus the user i am
                array_UserXLeague = [];
                for (var y = 0; y < dataUserXLeague.length; y++) {
                    if (!showmyownpoints) {
                        if (dataUserXLeague[y].userID.toString() != userID) {
                            array_UserXLeague.push(dataUserXLeague[y]._id.toString());
                        }
                    }
                    else {
                        array_UserXLeague.push(dataUserXLeague[y]._id.toString());
                    }
                }
                // get their lineups for this week.
                LineUp.find({ "weekID": weekID, "userxleagueID": { $in: array_UserXLeague } }, function (err, dataLineUp) {
                    if (err) {
                        console.log("error in LineUp.find");
                        console.log(err);
                        callback(res, errorhandlingResponse);
                    }
                    else {
                        array_LineUp = [];
                        for (var y = 0; y < dataLineUp.length; y++) {
                            array_LineUp.push(dataLineUp[y]._id.toString());
                        }
                        // then get points where confirmationuserID is not there...
                        Points.find({ "lineupID": { $in: array_LineUp }, "confirmationuserID": null }, function (err, dataPoints) {
                            if (err) {
                                console.log("error in Points.find");
                                console.log(err);
                                callback(res, errorhandlingResponse);
                            }
                            else {
                                var pointsArray = [];
                                
                                for (var y = 0; y < dataPoints.length; y++) {
                                    var datecreated = new Date(dataPoints[y].datecreated.toString());
                                    var currentDate = new Date();
                                    currentDate.setDate(datecreated.getDate());
                                    currentDate.setTime(datecreated.getTime());
                                    //console.log(currentDate);
                                    //console.log(currentDate.toISOString());
                                    //console.log(currentDate.toUTCString());
                                    var point = {
                                        "_id": dataPoints[y]._id,
                                        "lineupID": dataPoints[y].lineupID,
                                        "leagueID": dataPoints[y].leagueID,
                                        "score": dataPoints[y].score,
                                        "referenceID": dataPoints[y].referenceID,
                                        "referenceType": dataPoints[y].referenceType,
                                        "referenceName": dataPoints[y].referenceName,
                                        "referenceUser": dataPoints[y].referenceUser,
                                        "__v": dataPoints[y].__v,
                                        "datecreated": currentDate.toISOString()
                                    }
                                    pointsArray.push(point);
                                }
                                callback(res, { "success": true , "points": pointsArray });
                            }
                        });
                    }
                });
            }
        });
    }
    
    ViewController.summarizePoints = function (req, res, lineupID, callback) {
        var errorhandlingResponse = { "success": false };
        Points.find({ "lineupID": lineupID }, function (err, dataPoints) {
            if (err) {
                console.log("error in Points.find");
                console.log(err);
                callback(res, errorhandlingResponse);
            }
            else {
                var PointsEarned = 0;
                for (var y = 0; y < dataPoints.length; y++) {
                    if (dataPoints[y].confirmationuserID) {
                        PointsEarned += dataPoints[y].score;
                    }
                }
                callback(res, { "success": true, "points" : PointsEarned });
            }
        });
    }

    ViewController.thresholdOK = function (req, res, lineupID, callback){
        var errorhandlingResponse = { "success": false };

        //console.log("calling  db.points.find({'lineupID':'" + lineupID + "'}).sort({ 'datecreated': -1 }).limit(1) yielded nothing...")

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
                    //console.log(secondselapsed);
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
    