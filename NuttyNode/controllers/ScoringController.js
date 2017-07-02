(function (ScoringController) {
    
    var LineUp = require('../models/LineUp.js');
    var Points = require('../models/Points.js');
    var https = require('http');
    var testingWLIF = false;
    
    ScoringController.heardSong = function (req, res, lineupID, leagueID, userName, song, songID, userID, callback) {
        var errorhandlingResponse = { "success": false };
        var isodate = new Date().toISOString();
        var newPoints = new Points({ "lineupID": lineupID, "leagueID": leagueID, "score": 3, "referenceID": songID, "referenceType": "Song", "referenceName": song, "referenceUser": userName, "datecreated": isodate });
        newPoints.save(function (err, datanewPoints) {
            if (err) {
                callback(res, errorhandlingResponse);
            }
            else {
                var notificationMessage = userName + ":" +  song;
                //try to confirm against http://todays1019.cbslocal.com/?action=now-playing&type=json
                sendWebRequest("todays1019.cbslocal.com", "/?action=now-playing&type=json", "GET", "80", "", function (error, response) {
                    if (error) {
                        sendLeagueNotification(leagueID, notificationMessage, userID);
                        callback(res, { "success": true });
                    }
                    else {
                        if (response) {
                            if (response.message) {
                                var json = JSON.parse(response.message);
                                if (json[0].title) {
                                    if (json[0].title.toLowerCase().indexOf(song.toLowerCase()) > -1 || testingWLIF == true) {
                                        console.log("confirmed song hit!");
                                        //update the datanewPoints just saved.
                                        ScoringController.confirmed(null, null, datanewPoints._id.toString(), "1", function (err, resp) {
                                            console.log("i just auto-confirmed a point");
                                        });
                                        callback(res, { "success": true });
                                    }
                                    else {
                                        sendLeagueNotification(leagueID, notificationMessage, userID);
                                        callback(res, { "success": true });
                                    }
                                }
                                else {
                                    sendLeagueNotification(leagueID, notificationMessage, userID);
                                    callback(res, { "success": true });
                                }
                            }
                            else {
                                sendLeagueNotification(leagueID, notificationMessage, userID);
                                callback(res, { "success": true });
                            }
                        }
                        else {
                            sendLeagueNotification(leagueID, notificationMessage, userID);
                            callback(res, { "success": true });
                        }
                    }
                });
            }
        });
    }
    
    function sendWebRequest(_url, _path, _method, _port, _body, callback) {
        var options = {
            host: _url,
            path: _path,
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                'Cache-control': 'no-cache'
            }
        };
        console.log(options);
        var req2 = https.request(options, function (res) {
            res.setEncoding('utf8');
            res.on('data', function (chunk) {
                callback(null, { "success": true, "message": chunk });
            });
        });
        req2.on('error', function (e) {
            console.log("error Man!s: " + e);
            callback(e, { "success": false, "message": "error" });
        });
        req2.write(_body);
        req2.end();
    }
    
    
    ScoringController.heardArtist = function (req, res, lineupID, leagueID, userName, artist, artistID, userID, callback) {
        var errorhandlingResponse = { "success": false };
        var isodate = new Date().toISOString();
        var newPoints = new Points({ "lineupID": lineupID, "leagueID": leagueID, "score": 1, "referenceID": artistID, "referenceType": "Artist", "referenceName": artist, "referenceUser": userName, "datecreated": isodate });
        newPoints.save(function (err, datanewPoints) {
            if (err) {
                callback(res, errorhandlingResponse);
            }
            else {
                //send notification to league that 
                var notificationMessage = userName + ":" + artist;
                sendWebRequest("todays1019.cbslocal.com", "/?action=now-playing&type=json", "GET", "80", "", function (error, response) {
                    if (error) {
                        sendLeagueNotification(leagueID, notificationMessage, userID);
                        callback(res, { "success": true });
                    }
                    else {
                        if (response) {
                            if (response.message) {
                                var json = JSON.parse(response.message);
                                if (json[0].title) {
                                    if (json[0].title.toLowerCase().indexOf(artist.toLowerCase()) > -1 || testingWLIF == true) {
                                        console.log("confirmed artist hit!");
                                        //update the datanewPoints just saved.
                                        ScoringController.confirmed(null, null, datanewPoints._id.toString(), "1", function (err, resp) {
                                            console.log("i just auto-confirmed a point");
                                        });
                                        callback(res, { "success": true });
                                    }
                                    else {
                                        sendLeagueNotification(leagueID, notificationMessage, userID);
                                        callback(res, { "success": true });
                                    }
                                }
                                else {
                                    sendLeagueNotification(leagueID, notificationMessage, userID);
                                    callback(res, { "success": true });
                                }
                            }
                            else {
                                sendLeagueNotification(leagueID, notificationMessage, userID);
                                callback(res, { "success": true });
                            }
                        }
                        else {
                            sendLeagueNotification(leagueID, notificationMessage, userID);
                            callback(res, { "success": true });
                        }
                    }
                });
            }
        });
    }
    
    ScoringController.heardRelease = function (req, res, lineupID, leagueID, userName, release, releaseID, userID, callback) {
        var errorhandlingResponse = { "success": false };
        var isodate = new Date().toISOString();
        var newPoints = new Points({ "lineupID": lineupID, "leagueID": leagueID, "score": 7, "referenceID": releaseID, "referenceType": "Release", "referenceName": release, "referenceUser": userName, "datecreated": isodate });
        newPoints.save(function (err, datanewPoints) {
            if (err) {
                callback(res, errorhandlingResponse);
            }
            else {
                //send notification to league that 
                var notificationMessage = userName + " heard their artist and song";
                sendWebRequest("todays1019.cbslocal.com", "/?action=now-playing&type=json", "GET", "80", "", function (error, response) {
                    if (error) {
                        sendLeagueNotification(leagueID, notificationMessage, userID);
                        callback(res, { "success": true });
                    }
                    else {
                        if (response) {
                            if (response.message) {
                                var json = JSON.parse(response.message);
                                if (json[0].title) {
                                    if (json[0].title.indexOf("-") > -1 && release.indexOf("-") > -1) {
                                        
                                        var artistsongArray = json[0].title.split("-");
                                        var releaseArray = release.split("-");
                                        var artist1 = artistsongArray[0].toLowerCase();
                                        artist1 = artist1.replace(/^\s+|\s+$/g, '')
                                        console.log(artist1);
                                        var artist2 = releaseArray[0].toLowerCase();
                                        artist2 = artist2.replace(/^\s+|\s+$/g, '')
                                        console.log(artist2);
                                        var song1 = artistsongArray[1].toLowerCase();
                                        song1 = song1.replace(/^\s+|\s+$/g, '')
                                        console.log(song1);
                                        var song2 = releaseArray[1].toLowerCase();
                                        song2 = song2.replace(/^\s+|\s+$/g, '')
                                        console.log(song2);
                                        if (artist1.indexOf(artist2) > -1 && song1.indexOf(song2) > -1) {
                                            console.log("confirmed release hit!");
                                            //update the datanewPoints just saved.
                                            ScoringController.confirmed(null, null, datanewPoints._id.toString(), "1", function (err, resp) {
                                                console.log("i just auto-confirmed a point");
                                            });
                                            callback(res, { "success": true });
                                        }
                                        else {
                                            sendLeagueNotification(leagueID, notificationMessage, userID);
                                            callback(res, { "success": true });
                                        }
                                    }
                                    else {
                                        if (json[0].title.toLowerCase().indexOf(release.toLowerCase()) > -1 || testingWLIF == true) {
                                            console.log("confirmed release hit!");
                                            //update the datanewPoints just saved.
                                            ScoringController.confirmed(null, null, datanewPoints._id.toString(), "1", function (err, resp) {
                                                console.log("i just auto-confirmed a point");
                                            });
                                            callback(res, { "success": true });
                                        }
                                        else {
                                            sendLeagueNotification(leagueID, notificationMessage, userID);
                                            callback(res, { "success": true });
                                        }
                                    }
                                }
                                else {
                                    sendLeagueNotification(leagueID, notificationMessage, userID);
                                    callback(res, { "success": true });
                                }
                            }
                            else {
                                sendLeagueNotification(leagueID, notificationMessage, userID);
                                callback(res, { "success": true });
                            }
                        }
                        else {
                            sendLeagueNotification(leagueID, notificationMessage, userID);
                            callback(res, { "success": true });
                        }
                    }
                });
            }
        });
    }
    
    ScoringController.confirmed = function (req, res, pointID, userID, callback) {
        var conditions = { _id: pointID };
        var update = { $set: { confirmationuserID: userID } };
        var options = { upsert: true };
        Points.update(conditions, update, options, mongocallback);
        callback(res, { "success": true });
    }
    
    function sendLeagueNotification(leagueID, message, userID) {
        var subject = "Christmas Fam Duels";
        var AWS = require('aws-sdk');
        var cloudconfig = require('../cloud/index.js');
        var cloudsettings = {
            cloudconfig: cloudconfig
        };
        var profile = cloudsettings.cloudconfig().cloud_aws;
        AWS.config.update(profile);
        var sns = new AWS.SNS();
        
        var NotificationTokens = require('../models/NotificationToken.js');
        NotificationTokens.find({ "leagueID": leagueID }, function (err, notificationtokens) {
            if (notificationtokens) {
                for (var x = 0; x < notificationtokens.length; x++) {
                    if (notificationtokens[x].userID.toString() != userID) {
                        var endpointARN = notificationtokens[x].endpointARN.toString();
                        sns.publish({
                            TargetArn: endpointARN,
                            Message: message,
                            Subject: subject
                        },
                        function (err, data) {
                            if (err) {
                                console.log("Error sending a message " + err);
                            }
                            else {
                                console.log("Sent message: " + data.MessageId);
                            }
                        });
                    }
                    else {
                        console.log("you were going to notify yourself...")
                        //BEGIN: TEMPORARY!!!
                        /*
                        var endpointARN = notificationtokens[x].endpointARN.toString();
                        sns.publish({
                            TargetArn: endpointARN,
                            Message: message,
                            Subject: subject
                        },
                        function (err, data) {
                            if (err) {
                                console.log("Error sending a message " + err);
                            }
                            else {
                                console.log("Sent message: " + data.MessageId);
                            }
                        });
                        */
                        //END: TEMPORARY!!!
                    }
                }
            }
            else {
                console.log("apparently...db.notificationtokens.find({'leagueID':'" + leagueID + "'}) yielded nothing...")
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
    