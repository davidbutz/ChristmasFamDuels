﻿var res = "";
var Week = require("./models/Week.js");
var setlineupcontroller = require("./controllers/SetLineupController");
var config = require('./config/index.js');
var settings = {
    config: config
};
var userID = "ABCDEFGHI";
var weekID = "123456789";

var mongoose = require('mongoose');
mongoose.connect(settings.config().MONGOCONN);

//test variables.
var email = "cfd1@nuttyrobot.com;cfd2@nuttyrobot.com";
var invitation_token = "xxx";
var artistsearchterm = "john denver";
var artistDiscogsID = 342;
var songsearchterm = "Have yourself a merry little christmas";
var release_search_song_term = "all i want for christmas";
var release_search_artist_term = "mariah carey";
var releaseDiscogsID = 222;

//adding and searching artists/songs/releases
var testAddArtist = true;
var testArtistSearch = true;
var testAddSong = true;
var testSongSearch = true;
var testAddRelease = true;
var testReleaseSearch = true;

//login and invitation
var testEmailInvitations = false;

//weeks
var testWeekQueries = false;
var addWeeks = false;

if (testAddArtist) {
    setlineupcontroller.addArtist(res, artistsearchterm, artistDiscogsID, callback);
}
if (testArtistSearch) {
    setlineupcontroller.searchArtist(res, artistsearchterm, userID, weekID, callback);
}


if (testAddSong) {
    setlineupcontroller.addSong(res, songsearchterm, callback);
}
if (testSongSearch) {
    setlineupcontroller.searchSong(res, songsearchterm, userID, weekID, callback);
}



if (testAddRelease) {
    setlineupcontroller.addRelease(res, release_search_artist_term + "-" + release_search_song_term, releaseDiscogsID, callback);
}
if (testReleaseSearch) {
    setlineupcontroller.searchRelease(res, release_search_song_term, release_search_artist_term, userID, weekID, callback);
}


if (testWeekQueries) {
    setTimeout(function () {
        console.log("Timeout fired");
        setlineupcontroller.getCurrentWeekID(res, callback);
        setlineupcontroller.getNextWeekID(res, callback);
    }, 3000);
}
if (testEmailInvitations) {
    //REQUIRED to communicate with AWS.
    var AWS = require('aws-sdk-promise');
    var cloudconfig = require('./cloud/index.js');
    var cloudsettings = {
        cloudconfig: cloudconfig
    };
    //standard configuration
    var config = require('./config/index.js');
    var settings = {
        config: config
    };
    var profile = cloudsettings.cloudconfig().cloud_aws;
    AWS.config.update(profile);
    
    var productionurl = settings.config().ProductionWeb.toString() + "/inviteUser?invitationToken=" + invitation_token;
    var ses = new AWS.SES({ apiVersion: '2010-12-01' });
    var to = [email];
    var from = cloudsettings.cloudconfig().christmasFamDuelsEmail;
    var messagebody = "You have been invited to play 'Christmas Fam Duels'.<br>";
    messagebody += "<b>Get the App!</b> Then click <a href=\"" + productionurl + "\"> THIS LINK </a> to accept your invitation!";
    messagebody += "<br><br>If you are having trouble finding the app, please contact NuttyRobot (getChristmasFamDuelsapp@nuttyrobot.com)";
    
    var finalToEmailArray = [];
    var arrayEmails = email.split(";");
    for (var i = 0; i < arrayEmails.length; i++) {
        finalToEmailArray.push(arrayEmails[i]);
    }
    to = finalToEmailArray;
    var params = {
        Destination: { ToAddresses: to },
        Source: from,
        Message: {
            Body: {
                Html: {
                    Data: messagebody
                },
                Text: {
                    Data: 'message text'
                }
            },
            Subject: {
                Data: 'Christmas Fam Duels - Invitation to League!'
            }
        }
    }
    
    ses.sendEmail(params, function (err, data) {
        if (err) {
            console.log(err);
            callback(res, errorhandlingResponse);
        }
        if (data.MessageId) {
            callback(res, { "success": true });
        }
        else {
            console.log(data);
            callback(res, data);
        }
    });
}

function callback(res, json) {
    console.log(json);
}

if (addWeeks) {
    var newWeek = { "weekStart": "10/30/2016", "weekEnd": "11/5/2016", "weekYear": 2016 };
    var newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    
    newWeek = { "weekStart": "11/6/2016", "weekEnd": "11/12/2016", "weekYear": 2016 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "11/13/2016", "weekEnd": "11/19/2016", "weekYear": 2016 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "11/20/2016", "weekEnd": "11/26/2016", "weekYear": 2016 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "11/27/2016", "weekEnd": "12/3/2016", "weekYear": 2016 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
}