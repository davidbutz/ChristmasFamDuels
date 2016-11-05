(function (SetLineupController) {

    //DB models used.
    var League = require('../models/League.js');
    var UserXLeague = require('../models/UserXLeague.js');
    var Login = require('../models/Login.js');
    var User = require('../models/User.js');
    var PasswordResetRequest = require("../models/PasswordResetRequest.js");
    var NotificationToken = require("../models/NotificationToken.js");
    var Week = require("../models/Week.js");
    var Song = require("../models/Song.js");
    var Artist = require("../models/Artist.js");
    var Release = require("../models/Release.js");
    var Lineup = require("../models/Lineup.js");
    
    //controls used.
    var crypto = require("crypto");
    ObjectID = require('mongodb').ObjectID;
    var Discogs = require('disconnect').Client;
    
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
    
    
    var AWS = require('aws-sdk-promise');
    
    //set up credentials for aws 
    var profile = settings.config().aws;
    AWS.config.update(profile);
    //here is where the AWS.config.httpOptions get set.
    AWS.config.httpOptions = { timeout: 240000 };
    var s3 = new AWS.S3({
        httpOptions: {
            timeout: 480000
        }
    });

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
    
    
    var discogs_db = new Discogs({
        consumerKey: settings.config().discogsconsumerKey,
        consumerSecret: settings.config().discogsconsumerSecret
    }).database();
    

    SetLineupController.getNextWeekID = function (res, callback) {
        var currentDate = new Date();
        currentDate.setDate(currentDate.getDate() + 7);
        var queryDate = dateFormat(new Date(currentDate), "%Y-%m-%d %H:%M:%S", false);
        var year = currentDate.getFullYear();
        
        var collection = db.collection('weeks').find({ "weekYear": year , $and : [{ "weekStart" : { $lte : new Date(queryDate) } }, { "weekEnd": { $gte : new Date(queryDate) } }] });
        collection.toArray(function (err, docs) {
            if (docs) {
                if (docs.length > 0) {
                    callback(res, { "success": true , "_id": docs[0]._id, "weekStart": dateFormat(docs[0].weekStart, "%Y-%m-%d %H:%M:%S", false), "weekEnd": dateFormat(docs[0].weekEnd, "%Y-%m-%d %H:%M:%S", false) });
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
                    callback(res, { "success": true , "_id": docs[0]._id, "weekStart": dateFormat(docs[0].weekStart, "%Y-%m-%d %H:%M:%S", false), "weekEnd": dateFormat(docs[0].weekEnd, "%Y-%m-%d %H:%M:%S", false) });
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

    SetLineupController.addSong = function (res, title, callback){
        var errorhandlingResponse = { "success": false };
        Song.findOne({ "title" : { $regex: new RegExp('^' + title.toLowerCase(), 'i') }}, function (err, dataSong) {
            if (err) {
                callback(res, errorhandlingResponse);
            }
            if (dataSong) {
                callback(res, { "success": true, "songID" : dataSong._id.toString(), "title": dataSong.title });
            }
            else {
                var newSong = new Song({ "title": title });
                newSong.save(function (err, newSongObject) {
                    if (err) {
                        callback(res, errorhandlingResponse);
                    }
                    else {
                        callback(res, { "success": true, "songID" : newSongObject._id.toString(), "title": newSongObject.title });
                    }
                });
            }
        });
    }
    
    SetLineupController.addArtist = function (res, artist, discogArtistID, callback) {
        var errorhandlingResponse = { "success": false };
        Artist.findOne({ "artist" : { $regex: new RegExp('^' + artist.toLowerCase(), 'i') } }, function (err, dataArtist) {
            if (err) {
                callback(res, errorhandlingResponse);
            }
            if (dataArtist) {
                callback(res, { "success": true, "artistID" : dataArtist._id.toString(), "artist": dataArtist.artist, "discogArtistID": dataArtist.discogArtistID });
            }
            else {
                var newArtist = new Artist({ "artist": artist, "discogArtistID": discogArtistID });
                newArtist.save(function (err, newArtistObject) {
                    if (err) {
                        callback(res, errorhandlingResponse);
                    }
                    else {
                        callback(res, { "success": true, "artistID" : newArtistObject._id.toString(), "artist": newArtistObject.artist, "discogArtistID": newArtistObject.discogArtistID });
                    }
                });
            }
        });
    }
    
    SetLineupController.addRelease = function (res, release, discogReleaseID, callback) {
        var errorhandlingResponse = { "success": false };
        Release.findOne({ "release" : { $regex: new RegExp('^' + release.toLowerCase(), 'i') } }, function (err, dataRelease) {
            if (err) {
                callback(res, errorhandlingResponse);
            }
            if (dataRelease) {
                callback(res, { "success": true, "releaseID" : dataRelease._id.toString(), "release": dataRelease.release, "discogReleaseID": dataRelease.discogReleaseID });
            }
            else {
                var newRelease = new Release({ "release": release, "discogReleaseID": discogReleaseID });
                newRelease.save(function (err, newReleaseObject) {
                    if (err) {
                        callback(res, errorhandlingResponse);
                    }
                    else {
                        callback(res, { "success": true, "releaseID" : newReleaseObject._id.toString(), "release": newReleaseObject.release, "discogReleaseID": newReleaseObject.discogReleaseID });
                    }
                });
            }
        });
    }

    SetLineupController.searchSong = function (res, searchterm, userID, weekID, callback) {
        var errorhandlingResponse = { "success": false };
        // Researching for "song" is harder than i thought , as the song databases out there really dont search and return a single Title.
        // So instead, i am going to store this "internally"
        //({'name': {'$regex': 'sometext'}})
        Song.findOne({ "title" : { $regex: new RegExp('^' + searchterm.toLowerCase(), 'i') }}, function (err, dataSong) {
            if (err) {
                callback(res, errorhandlingResponse);
            }
            if (dataSong) {
                callback(res, { "success": true, "songID" : dataSong._id.toString(), "title": dataSong.title });
            }
            else {
                callback(res, errorhandlingResponse);
            }
        });
    }

    SetLineupController.searchArtist = function (res, searchterm, userID, weekID, callback){
        var errorhandlingResponse = { "success": false };
        discogs_db.search(searchterm , { "type": "artist" } , function (err, data) {
            if (err) {
                console.log(err);
                callback(res, errorhandlingResponse);
            }
            if (data.results.length > 0) {
                var artistID = data.results[0].id;
                discogs_db.getArtist(artistID, function (err, dataArtist) {
                    var newartistID = artistID;
                    var artistname;
                    var artisturl;
                    if (dataArtist.images.length > 0) {
                        artisturl = dataArtist.images[0].resource_url;
                        //getImagefromRelease(url, userID, weekID, searchtype)
                        getImagefromRelease(artisturl, userID, weekID, "artist");
                    }
                    if (dataArtist.name) {
                        artistname = dataArtist.name;
                    }
                    var buildJSON = {"success" : true, "imageurl" : artisturl, "discogArtistID" : artistID, "artist" : artistname };
                    callback(res, buildJSON);
                });
            }
            else {
                callback(res, errorhandlingResponse);
            }
        });
    }
    
    SetLineupController.searchRelease = function (res, track, artist, userID, weekID, callback) {
        var errorhandlingResponse = { "success": false };
        discogs_db.search(track, { "track" : track, "artist" : artist, "type": "master", "page" : 1, "perpage" : 1 }, function (err, data) {
            if (err) {
                console.log(err);
                callback(res, errorhandlingResponse);
            }
            else {
                //var imagename = song.replace(/\s/g, '') + artist.replace(/\s/g, '');
                if (data.results.length > 0) {
                    if (data.results[0].type) {
                        if (data.results[0].type == "master") {
                            discogs_db.getMaster(data.results[0].id, function (err, masterdata) {
                                var releaseID = masterdata.main_release;
                                discogs_db.getRelease(releaseID, function (err, releasedata) {
                                    //return to the user: 
                                    var imageurl;
                                    var videourl;
                                    var title;
                                    var artist;
                                    var trackname;
                                    
                                    //imageurl (to see the image of the release)
                                    if (releasedata.images.length > 0) {
                                        imageurl = releasedata.images[0].resource_url;
                                        getImagefromRelease(imageurl, userID, weekID, "release");
                                    }
                                    //videouri (to listen to the song...)
                                    if (masterdata.videos) {
                                        if (masterdata.videos.length > 0) {
                                            videourl = masterdata.videos[0].uri;
                                        }
                                    }
                                    if (masterdata.title) {
                                        title = masterdata.title;
                                    }
                                    if (masterdata.artists.length > 0) {
                                        artist = masterdata.artists[0].name;
                                    }
                                    if (masterdata.tracklist) {
                                        if (masterdata.tracklist.length > 0) {
                                            for (var i = 0; i < masterdata.tracklist.length; i++) {
                                                if (masterdata.tracklist[i].title.toLowerCase().includes(track.toLowerCase())) {
                                                    trackname = masterdata.tracklist[i].title;
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                    var buildJSON = { "success": true, "imageurl" : imageurl, "videourl" : videourl , "title" : title, "artist" : artist, "track" : trackname };
                                    callback(res, buildJSON);
                                });
                            });
                        }
                    }
                    else {
                        console.log("there was no type in the response.");
                        callback(res, errorhandlingResponse);
                    }
                }
                else {
                    //we have a tricker situation. lets start with the song search first...
                    discogs_db.search(track, { "track" : track }, function (err, trackdata) {
                        var output;
                        if (trackdata.results.length > 0) {
                            for (var y = 0; y < trackdata.results.length; y++) {
                                if (trackdata.results[y].title.toLowerCase().includes(artist.toLowerCase())) {
                                    output = trackdata.results[y];
                                    break;
                                }
                            }
                            if (output !== undefined) {
                                if (output.type == "release") {
                                    getReleaseInformation(output.id, res, userID, weekID, function (json) {
                                        callback(res, json);
                                    });
                                }
                                else {
                                    console.log({ "success": false, "message": "Match from track did not have release." });
                                    callback(res, errorhandlingResponse);
                                }
                            }
                            else {
                                console.log({ "success": false, "message": "Could not match Discog results to your search term." });
                                callback(res, errorhandlingResponse);
                            }
                        }
                        else {
                            //an even tougher road here...
                            console.log({ "success": false, "message": "No Results from Discogs" });
                            callback(res, errorhandlingResponse);
                        }
                    });
                }
            }
        });
    }
    
    function getReleaseInformation(releaseID, res, userID, weekID, callback) {
        var errorhandlingResponse = { "success": false };
        discogs_db.getRelease(releaseID, function (err, releasedata) {
            
            if (err) {
                callback(errorhandlingResponse);
            }
            else {
                //return to the user: 
                var imageurl;
                var videourl;
                var title;
                var artist;
                var trackname;
                discogs_db.getMaster(releasedata.master_id, function (err, masterdata) {
                    if (err) {
                        callback(errorhandlingResponse);
                    }
                    else {
                        //imageurl (to see the image of the release)
                        if (releasedata.images.length > 0) {
                            imageurl = releasedata.images[0].resource_url;
                            getImagefromRelease(imageurl, userID, weekID, "release");
                        }
                        //videouri (to listen to the song...)
                        if (masterdata.videos) {
                            if (masterdata.videos.length > 0) {
                                videourl = masterdata.videos[0].uri;
                            }
                        }
                        if (masterdata.title) {
                            title = masterdata.title;
                        }
                        if (masterdata.artists.length > 0) {
                            artist = masterdata.artists[0].name;
                        }
                        if (masterdata.tracklist) {
                            if (masterdata.tracklist.length > 0) {
                                for (var i = 0; i < masterdata.tracklist.length; i++) {
                                    if (masterdata.tracklist[i].title.toLowerCase().includes(track.toLowerCase())) {
                                        trackname = masterdata.tracklist[i].title;
                                        break;
                                    }
                                }
                            }
                        }
                        var buildJSON = { "success": true, "imageurl" : imageurl, "videourl" : videourl , "title" : title, "artist" : artist, "track" : trackname };
                        callback(buildJSON);
                    }
                });
            }
        });
    }

    function getImagefromRelease(url, userID, weekID, searchtype) {
        discogs_db.getImage(url, function (err, data, rateLimit) {
            // save to AWS
            // save as userID_search_searchtype_weekID
            var saveName = userID.toString() + "_search_" + searchtype + "_" + weekID.toString() + ".jpg";
            //tried to save directly to s3, but the Body: did not accept "data" and i ran out of time to play with it
            // Data contains the raw binary image data
            require('fs').writeFile('/tmp/' + saveName, data, 'binary', function (err) {
                if (err) {
                    console.log(err);
                }
                else {
                    //console.log('Image saved!');
                    var body = require('fs').createReadStream('/tmp/' + saveName);
                    s3
                    .upload({ Bucket: settings.config().awsbucketname, Key: saveName, Body: body })
				    .on('httpUploadProgress', function (evt) { console.log("AWSController.pushImage httpUploadProgress", evt.key, evt.total, evt.loaded / (evt.total + 1) * 100); })
				    .send(
                        function (err, data) {
                            if (err) {
                                console.error("AWSController.pushImage error", err);
                            }
                            if (data) {
                                console.log("AWSController.pushImage data", data);
                            }
                        }
                    );
                }
            });
        });
    }

    SetLineupController.setLineUpArtist = function (res, leagueID, artistID, userxleagueID, weekID, callback) {
        var errorhandlingResponse = { "success": false };
        LineUp.findOne({ "weekID": weekID, "userxleagueID": userxleagueID }, function (err, dataLineUp) {
            if (err) {
                callback(res, errorhandlingResponse);
            }
            else {
                if (dataLineUp) {
                    //Update the state..
                    var conditions = { _id: dataLineUp._id.toString() };
                    var update = { $set: { "artistID" : artistID } };
                    var options = { upsert: true };
                    LineUp.update(conditions, update, options, mongocallback);
                }
                else {
                    var newLineUp = { "weekID": weekID, "userxleagueID": userxleagueID, "artistID": artistID };
                    var newLineUpObj = new LineUp(newLineUp);
                    newLineUpObj.save(function (err) {
                        if (err) {
                            callback(res, errorhandlingResponse);
                        }
                        else {
                            callback(res, { "success": true });
                        }
                    });
                }
            }
        });
    }
    
    SetLineupController.setLineUpSong = function (res, leagueID, songID, userxleagueID, weekID, callback) {
        var errorhandlingResponse = { "success": false };
        LineUp.findOne({ "weekID": weekID, "userxleagueID": userxleagueID }, function (err, dataLineUp) {
            if (err) {
                callback(res, errorhandlingResponse);
            }
            else {
                if (dataLineUp) {
                    //Update the state..
                    var conditions = { _id: dataLineUp._id.toString() };
                    var update = { $set: { "songID" : songID } };
                    var options = { upsert: true };
                    LineUp.update(conditions, update, options, mongocallback);
                }
                else {
                    var newLineUp = { "weekID": weekID, "userxleagueID": userxleagueID, "songID": songID };
                    var newLineUpObj = new LineUp(newLineUp);
                    newLineUpObj.save(function (err) {
                        if (err) {
                            callback(res, errorhandlingResponse);
                        }
                        else {
                            callback(res, { "success": true });
                        }
                    });
                }
            }
        });
    }
    
    SetLineupController.setLineUpRelease = function (res, leagueID, releaseID, userxleagueID, weekID, callback) {
        var errorhandlingResponse = { "success": false };
        LineUp.findOne({ "weekID": weekID, "userxleagueID": userxleagueID }, function (err, dataLineUp) {
            if (err) {
                callback(res, errorhandlingResponse);
            }
            else {
                if (dataLineUp) {
                    //Update the state..
                    var conditions = { _id: dataLineUp._id.toString() };
                    var update = { $set: { "releaseID" : releaseID } };
                    var options = { upsert: true };
                    LineUp.update(conditions, update, options, mongocallback);
                }
                else {
                    var newLineUp = { "weekID": weekID, "userxleagueID": userxleagueID, "releaseID": releaseID };
                    var newLineUpObj = new LineUp(newLineUp);
                    newLineUpObj.save(function (err) {
                        if (err) {
                            callback(res, errorhandlingResponse);
                        }
                        else {
                            callback(res, { "success": true });
                        }
                    });
                }
            }
        });
    }


    function mongocallback(err, numAffected) {
        // numAffected is the number of updated documents
        if (err) {
            console.log("error!!!");
            console.log(err);
        }
    }



})(module.exports);