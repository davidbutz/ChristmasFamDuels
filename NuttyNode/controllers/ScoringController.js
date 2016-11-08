(function (ScoringController) {

    var LineUp = require('../models/LineUp.js');
    var Points = require('../models/Points.js');

    ScoringController.heardSong = function (req, res, lineupID, leagueID, userName, song, songID, callback) {
        var errorhandlingResponse = { "success": false };
        var newPoints = new Points({ "lineupID": lineupID, "leagueID": leagueID, "score": 3, "referenceID": songID, "referenceType": "Song", "referenceName": song, "referenceUser": userName });
        newPoints.save(function (err) {
            if (err) {
                callback(res, errorhandlingResponse);
            }
            else {
                //send notification to league that 
                var notificationMessage = userName + " heard their song";
                sendLeagueNotification(leagueID, notificationMessage);
                callback(res, { "success": true });
            }
        });
    }
    
    ScoringController.heardArtist = function (req, res, lineupID, leagueID, userName, artist, artistID, callback) {
        var errorhandlingResponse = { "success": false };
        var newPoints = new Points({ "lineupID": lineupID, "leagueID": leagueID, "score": 1, "referenceID": artistID, "referenceType": "Artist", "referenceName": artist, "referenceUser": userName });
        newPoints.save(function (err) {
            if (err) {
                callback(res, errorhandlingResponse);
            }
            else {
                //send notification to league that 
                var notificationMessage = userName + " heard their artist";
                sendLeagueNotification(leagueID, notificationMessage);
                callback(res, { "success": true });
            }
        });
    }
    
    ScoringController.heardRelease = function (req, res, lineupID, leagueID, userName, release, releaseID, callback) {
        var errorhandlingResponse = { "success": false };
        var newPoints = new Points({ "lineupID": lineupID, "leagueID": leagueID, "score": 7, "referenceID": releaseID, "referenceType": "Release", "referenceName": release, "referenceUser": userName });
        newPoints.save(function (err) {
            if (err) {
                callback(res, errorhandlingResponse);
            }
            else {
                //send notification to league that 
                var notificationMessage = userName + " heard their artist and song";
                sendLeagueNotification(leagueID, notificationMessage);
                callback(res, { "success": true });
            }
        });
    }
    
    ScoringController.confirmed = function (req, res, pointID, userID, callback) {
        var conditions = { _od: pointID };
        var update = { $set: { confirmationuserID: userID } };
        var options = { upsert: true };
        Points.update(conditions, update, options, mongocallback);
        callback(res, { "success": true });
    }

    function sendLeagueNotification(leagueID, message){
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
    