var res = "";
var req = "";
var Week = require("./models/Week.js");
var Points = require("./models/Points.js");
var League = require('./models/League.js');
var SongsStandard = require('./models/SongsStandard.js');
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
var artistsearchterm = "pentat";//"john denver";
var artistDiscogsID = 342;
var songsearchterm = "Have Yourself a merry";
var release_search_song_term = "all i want for christmas";
var release_search_artist_term = "penta";//"mariah carey";
var releaseDiscogsID = 222;
var leagueID = "581a932124cd41302ad6ce61";
var userID = "58239632c27b8ac4219c99df";//"581a73bf6dcd47a00233328e";
var weekID = "581beba54201452008ecb29a";
var lineupID = "5820b611d2641d08242551e7";//"5821347857e1e558259db299";//"5820b611d2641d08242551e7";

//test thresholdOK logic...
var testthresholdOK = false;

//adding and searching artists/songs/releases
var testAddArtist = false;
var testArtistSearch = true;
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
var testwlif = true;
var teststandings = false;
var testreleasev2 = false
var add2017Weeks = false;
var addStandardSongs = false;
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
if (add2017Weeks_more) {

    newWeek = { "weekStart": "10/22/2017", "weekEnd": "10/28/2017", "weekYear": 2017 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "10/29/2017", "weekEnd": "11/04/2017", "weekYear": 2017 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "11/05/2017", "weekEnd": "11/11/2017", "weekYear": 2017 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "11/12/2017", "weekEnd": "11/23/2017", "weekYear": 2017 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "11/24/2017", "weekEnd": "11/25/2017", "weekYear": 2017 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "11/26/2017", "weekEnd": "12/02/2017", "weekYear": 2017 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "12/03/2017", "weekEnd": "12/09/2017", "weekYear": 2017 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "12/10/2017", "weekEnd": "12/16/2017", "weekYear": 2017 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "12/17/2017", "weekEnd": "12/23/2017", "weekYear": 2017 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "12/24/2017", "weekEnd": "01/03/2018", "weekYear": 2017 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "01/04/2018", "weekEnd": "01/10/2018", "weekYear": 2018 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });

}
if (add2017Weeks) {
    newWeek = { "weekStart": "07/02/2017", "weekEnd": "07/08/2017", "weekYear": 2017 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "07/09/2017", "weekEnd": "07/15/2017", "weekYear": 2017 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "07/16/2017", "weekEnd": "07/22/2017", "weekYear": 2017 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    }); newWeek = { "weekStart": "07/23/2017", "weekEnd": "07/29/2017", "weekYear": 2017 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
    newWeek = { "weekStart": "07/30/2017", "weekEnd": "08/05/2017", "weekYear": 2017 };
    newWeekObj = new Week(newWeek);
    console.log("about to save...");
    newWeekObj.save(function (err, data) {
        console.log("here i am");
        console.log(err, data);
    });
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

if (addStandardSongs) {
    var SongsArray = [{ "song": " 2000 Miles " },
        { "song": " A Marshmallow World " },
        { "song": " All I Want For Christmas is You " },
        { "song": " Baby It's Cold Outside " },
        { "song": " Baby's First Christmas " },
        { "song": " Back Door Santa " },
        { "song": " Blue Christmas " },
        { "song": " Celebrate Me Home " },
        { "song": " Christmas " },
        { "song": " Christmas Auld Lang Syne " },
        { "song": " Christmas Eve " },
        { "song": " Christmas in Dixie " },
        { "song": " Christmas in Hollis " },
        { "song": " Christmas in Jail " },
        { "song": " Christmas Is the Time to Say I Love You " },
        { "song": " Christmas Rappin' " },
        { "song": " Christmas Wrapping " },
        { "song": " Deck the Halls " },
        { "song": " Do They Know It's Christmas? " },
        { "song": " Do You Hear What I Hear " },
        { "song": " Don't Believe In Christmas " },
        { "song": " Fairytale of New York " },
        { "song": " Father Christmas " },
        { "song": " Feliz Navidad " },
        { "song": " Frosty The Snowman " },
        { "song": " Give Love on Christmas Day " },
        { "song": " Grandma Got Run Over by a Reindeer " },
        { "song": " Grown-Up Christmas List " },
        { "song": " Happy Holiday " },
        { "song": " Happy Xmas " },
        { "song": " Hark The Herald Angels Sing " },
        { "song": " Here Comes Santa Claus " },
        { "song": " Hey Santa Claus " },
        { "song": " Hey Santa " },
        { "song": " I Believe in Father Christmas " },
        { "song": " I Saw Mommy Kissing Santa Claus " },
        { "song": " I Wish It Could Be Christmas Everyday " },
        { "song": " If We Make It Through December " },
        { "song": " It Doesn't Have To Be That Way " },
        { "song": " It's The Most Wonderful Time of the Year " },
        { "song": " Jingle Bell Rock " },
        { "song": " Jingle Bells " },
        { "song": " Last Christmas " },
        { "song": " Little Drummer Boy/Peace On Earth " },
        { "song": " Little Saint Nick " },
        { "song": " Lonesome Christmas " },
        { "song": " Mary's Boy Child/O My Lord " },
        { "song": " Merry Christmas All " },
        { "song": " Merry Christmas Baby " },
        { "song": " Merry Christmas Darling " },
        { "song": " Merry Christmas Everyone " },
        { "song": " Merry Xmas Everybody " },
        { "song": " O Holy Night " },
        { "song": " Please Come Home For Christmas " },
        { "song": " Pretty Paper " },
        { "song": " River " },
        { "song": " Rock and Roll Christmas " },
        { "song": " Rockin' Around the Christmas Tree " },
        { "song": " Rudolph The Red-Nosed Reindeer " },
        { "song": " Run Rudolph Run " },
        { "song": " Same Old Lang Syne " },
        { "song": " Santa Baby " },
        { "song": " Santa Claus Go Straight to the Ghetto " },
        { "song": " Santa Claus Is Back In Town " },
        { "song": " Santa Claus Is Coming To Town " },
        { "song": " Santa, Bring My Baby Back To Me " },
        { "song": " Silent Night " },
        { "song": " Sleigh Ride " },
        { "song": " Snoopy's Christmas " },
        { "song": " Someday At Christmas " },
        { "song": " Step Into Christmas " },
        { "song": " The Christmas Shoes " },
        { "song": " The Man With All the Toys " },
        { "song": " There's a New Kid in Town " },
        { "song": " This Christmas " },
        { "song": " This Time of the Year " },
        { "song": " Up On the Housetop " },
        { "song": " What Christmas Means To Me " },
        { "song": " White Christmas " },
        { "song": " Winter Wonderland " },
        { "song": " Wonderful Christmastime " },
        { "song": "(Sleep in Heavenly Peace) Silent Night" },
        { "song": "A Christmas Long Ago" },
        { "song": "All I Want For Christmas is My Two Front Teeth" },
        { "song": "Amen" },
        { "song": "Baby's First Christmas" },
        { "song": "Bells of St. Mary" },
        { "song": "Blue Christmas" },
        { "song": "Chrissy, The Christmas Mouse" },
        { "song": "Christmas (Baby Please Come Home)" },
        { "song": "Christmas Ain't Christmas" },
        { "song": "Christmas Auld Lang Syne" },
        { "song": "Christmas Dragnet" },
        { "song": "Christmas Serenade" },
        { "song": "Do They Know It's Christmas" },
        { "song": "Do You Hear What I Hear" },
        { "song": "Dominick, The Italian Christmas Donkey" },
        { "song": "Donde Esta Santa Claus" },
        { "song": "Feliz Navidad" },
        { "song": "Frosty the Snowman" },
        { "song": "Gee Whiz, It's Christmas" },
        { "song": "Give Love on Christmas Day" },
        { "song": "Grandma Got Run Over By A Reindeer" },
        { "song": "Happy Christmas (War is Over)" },
        { "song": "Happy Holidays" },
        { "song": "Have Yourself A Merry Little Christmas" },
        { "song": "Here Comes Santa Claus" },
        { "song": "Holly Jolly Christmas" },
        { "song": "Home For The Holidays" },
        { "song": "I Believe in Father Christmas" },
        { "song": "I Saw Mommy Kissing Santa Claus" },
        { "song": "If It Doesn't Snow on Christmas" },
        { "song": "It's Beginning to Look A Lot Like Christmas" },
        { "song": "It's Christmas Everywhere" },
        { "song": "It's Christmas Once Again" },
        { "song": "Jingle Bell Rock" },
        { "song": "Jingle Bells" },
        { "song": "Kissin' By The Mistletoe" },
        { "song": "Last Christmas" },
        { "song": "Let It Snow, Let It Snow, Let It Snow" },
        { "song": "Little Drummer Boy" },
        { "song": "Little St. Nick" },
        { "song": "Marshmallow World" },
        { "song": "May You Always" },
        { "song": "Merry Christmas All" },
        { "song": "Merry Christmas Baby" },
        { "song": "Merry Christmas Darling" },
        { "song": "Merry, Merry Christmas Baby" },
        { "song": "Mistletoe and Holly" },
        { "song": "Monsters' Holiday" },
        { "song": "Nuttin' for Christmas" },
        { "song": "Parade of The Wooden Soldiers" },
        { "song": "Peace on Earth/Little Drummer Boy" },
        { "song": "Please Come Home For Christmas" },
        { "song": "Pretty Paper" },
        { "song": "Rockin' Around The Christmas Tree" },
        { "song": "Rudolph, The Red Nosed Reindeer" },
        { "song": "Run Rudolph Run" },
        { "song": "Santa Baby" },
        { "song": "Santa Claus Is Coming To Town" },
        { "song": "Santa Claus Is Watching You" },
        { "song": "Silent Night" },
        { "song": "Silver Bells" },
        { "song": "Sleigh Ride" },
        { "song": "Snoopy's Christmas" },
        { "song": "Someday At Christmas" },
        { "song": "Step Into Christmas" },
        { "song": "The Chipmunk Song" },
        { "song": "The Christmas Song" },
        { "song": "The Christmas Waltz" },
        { "song": "The Man With All The Toys" },
        { "song": "The Most Wonderful Time of The Year" },
        { "song": "The Twelve Days of Christmas" },
        { "song": "This Christmas" },
        { "song": "This Time of Year" },
        { "song": "Twas The Night Before Christmas" },
        { "song": "We Need A Little Christmas" },
        { "song": "We Wish You The Merriest" },
        { "song": "What Christmas Means To Me" },
        { "song": "White Christmas" },
        { "song": "White Christmas " },
        { "song": "Winter Wonderland" },
        { "song": "Wonderful Christmastime" },
        { "song": "You're All I Want For Christmas" },
        { "song": "You're My Christmas Present" },
    ];
    //ArtistsStandard.insertMany(ArtistsArray, function (err, docs) { });
    SongsStandard.collection.insert(SongsArray, onInsert);
    
    function onInsert(err, docs) {
        if (err) {
        // TODO: handle error
        } else {
            console.info('%d songs were successfully stored.', docs.length);
        }
    }
}