var res = "";
var req = "";
var Week = require("./models/Week.js");
var Points = require("./models/Points.js");
var League = require('./models/League.js');
var LeagueInvitation = require('./models/LeagueInvitation.js');

var setlineupcontroller = require("./controllers/SetLineupController");
var viewcontroller = require("./controllers/ViewController");


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
var songsearchterm = "Have Yourself a merry little christmas";
var release_search_song_term = "all i want for christmas";
var release_search_artist_term = "mariah carey";
var releaseDiscogsID = 222;
var leagueID = "581a932124cd41302ad6ce61";
var userID = "58239632c27b8ac4219c99df";//"581a73bf6dcd47a00233328e";
var weekID = "581beba54201452008ecb29a";
var lineupID = "5820b611d2641d08242551e7";//"5821347857e1e558259db299";//"5820b611d2641d08242551e7";

//test thresholdOK logic...
var testthresholdOK = false;

//adding and searching artists/songs/releases
var testAddArtist = false;
var testArtistSearch = false;
var testAddSong = false;
var testSongSearch = false;
var testAddRelease = false;
var testReleaseSearch = false;
var testdatesandsuch = false;

//login and invitation
var testEmailInvitations = false;

//weeks
var testWeekQueries = false;
var addWeeks = false;
var testlikequery = false;
var testgetConfirmations = false;
var testsummarize = false;
var testwlif = false;
var teststandings = false;
var testreleasev2 = true

if (testreleasev2) {
    var title = "Josh Groban - O Holy Night";
    var release = "Josh Groban-O holy";
    //var artistsongArray = json[0].title.split("-");
    var artistsongArray = title.split("-");
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
        console.log("score");
    }
}

if (teststandings) {
    console.log("testing standings");
    viewcontroller.viewPoints(req, res, leagueID, "", function (err, resp) {
        console.log(resp);
    });
}

if (testwlif) {
    var https = require('http');
    sendWebRequest("todays1019.cbslocal.com", "/?action=now-playing&type=json", "GET", "80", "", function (error, response) {
        if (error) {
            console.log(error);
        }
        else {
            var json = JSON.parse(response.message);
            //console.log(response.message);
            console.log(json[0].title);
            if (json[0].title.toLowerCase().indexOf("best day of".toLowerCase()) > -1) {
                console.log("confirmed hit?");
            }
        }
    });
    

    function sendWebRequest(_url, _path, _method, _port, _body, callback) {
        var options = {
            host: _url,
            path: _path,
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                'Cache -Control': 'no-cache'
            }
        };
        //console.log(options);
        var req2 = https.request(options, function (res) {
            res.setEncoding('utf8');
            res.on('data', function (chunk) {
                //console.log("123");
                callback(null, { "success": true, "message": chunk });
            });
        });
        req2.on('error', function (e) {
            console.log("error Man!s: " + e);
            callback(e, { "success": false, "message": "error" });
        });
        //console.log(_body);
        req2.write(_body);
        //console.log("when is the error happening?");
        req2.end();
    }
}

if (testsummarize) {
    viewcontroller.summarizePoints(res, res, lineupID, function (err, resp) {
        console.log(resp);
    });
}

if (testgetConfirmations) {
    viewcontroller.getNeededConfirmations(req, res, leagueID, userID, weekID, function (err, resp) {
        console.log(resp);
    });
}

if (testlikequery) {
    
    var title = "my name is dave";
    console.log(title.indexOf("me name"));
    
    var d = new Date();
    var n = d.toISOString();
    console.log(n);
    var isodate = new Date().toISOString()
    console.log(isodate);

    var varemail = "cfd9@nuttyROBOT.com";
    var varemail2 = "*cfd9*";
    LeagueInvitation.findOne({ "email" : varemail2 }, function (err, request) {
        if (err) {
            callback(res, errorhandlingResponse);
        }
        console.log("--2-----");
        console.log(request);
        console.log("--2-----");
    });
    var aa = new RegExp('^' + varemail, 'i');
    console.log(aa);
    
    LeagueInvitation.findOne({ "email" : { $regex: new RegExp('' + varemail, 'i') } }, function (err, request) {
        if (err) {
            callback(res, errorhandlingResponse);
        }
        console.log("-------");
        console.log(request);
        console.log("-------");
    });

}

if (testthresholdOK) {
    console.log("testing threhold ok");
    var lineupID = "5820b611d2641d08242551e7";
    viewcontroller.thresholdOK(req, res, lineupID, function (err, json) {
        console.log(json);
    });
}


if (testdatesandsuch) {
    var viewcontroller = require("./controllers/ViewController");
    console.log("testdatesandsuch");
    viewcontroller.thresholdOK(req, res, "abcdefg", function (res, json) {
        console.log(json);
    });
    //var newPoint = new Points({ "lineupID": "abcdefg" });
    //newPoint.save(function (err, newpointobj) {
    //    var lastDateCreated = newpointobj.datecreated;
    //    //console.log(lastDateCreated);
    //    setTimeout(function () {
    //        //now compare that 3 seconds later?
    //        var currentDate = new Date();
    //        currentDate.setDate(currentDate.getDate());
    //        console.log(currentDate);
    //        console.log(currentDate.getTime());
    //        console.log(lastDateCreated);
    //        console.log(lastDateCreated.getTime());
    //    }, 2000);
    //});
}
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
    newWeek = { "weekStart": "12/4/2016", "weekEnd": "12/10/2016", "weekYear": 2016 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "12/11/2016", "weekEnd": "12/17/2016", "weekYear": 2016 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "12/18/2016", "weekEnd": "12/24/2016", "weekYear": 2016 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "12/25/2016", "weekEnd": "12/31/2016", "weekYear": 2016 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
}