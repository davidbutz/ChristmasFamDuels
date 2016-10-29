﻿(function (LeagueController) {
    
    var League = require('../models/League.js');
    var UserXLeague = require('../models/UserXLeague.js');
    var LeagueInvitation = require('../models/LeagueInvitation.js');
    
    var authentication = require("../controllers/Authentication");

    //add: add league
    LeagueController.addLeague = function (req, res, userID, leagueName, leagueYear, callback) {
        //what do we send back if something goes wrong?
        var errorhandlingResponse = { "success": false };

        var newLeague = { "leagueName" : leagueName, "leagueYear": leagueYear };
        var leagueobj = new League(newLeague);
        leagueobj.save(function (err, league) {
            if (err) {
                console.log(err);
                callback(res, errorhandlingResponse);
            }
            else {
                var new_id = league._id.toString();
                var newUserXLeague = { "userID" : userID, "leagueID": new_id , "roleID" : 1};
            }
        });
    }
    
    LeagueController.inviteToLeague = function (req, res, userID, leagueID, email, callback) {
        //what do we send back if something goes wrong?
        var errorhandlingResponse = { "success": false };
        
        //generate a token.
        var invitation_token = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = crypto.randomBytes(1)[0] % 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
        
        //Place a record into LeagueInvitation
        var newInvitationRequest = new LeagueInvitation({
            email : email,
            invitationToken : invitation_token,
            leagueID: leagueID
        });
        
        newInvitationRequest.save(function (err) {
            if (err) {
                console.log("ERROR saving inviteToLeague: " + err);
                callback(res, errorhandlingResponse);
            }

            //REQUIRED to communicate with AWS.
            var AWS = require('aws-sdk-promise');
            var cloudconfig = require('../cloud/index.js');
            var cloudsettings = {
                cloudconfig: cloudconfig
            };
            var profile = cloudsettings.cloudconfig().cloud_aws;
            AWS.config.update(profile);
            
            var productionurl = settings.config().ProductionWeb.toString() + "/inviteUser?invitationToken=" + invitationToken;
            var ses = new AWS.SES({ apiVersion: '2010-12-01' });
            var to = [email];
            var from = cloudsettings.cloudconfig().christmasFamDuelsEmail;
            var messagebody = "You have been invited to play 'Christmas Fam Duels'.<br>";
            messagebody += "<b>Get the App!</b> Then click <a href=\"" + productionurl + "\"> THIS LINK </a> to accept your invitation!";
            messagebody += "<br><br>If you are having trouble finding the app, please contact NuttyRobot (getChristmasFamDuelsapp@nuttyrobot.com)";
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
        });
    }
    
    
    //user has accepted the invitee - through native app- and is pushing request back
    LeagueController.acceptInvitation = function (req, res, token, userID, callback) {
        //what do we send back if something goes wrong?
        var errorhandlingResponse = { "success": false };

        LeagueInvitation.findOne({ invitationToken: token }, function (err, request) {
            if (request) {
                // Add this user to the League in the invite.
                var leagueID = request.leagueID.toString();
                authentication.addLeagueMember(leagueID, userID, function (response){
                    callback(res, response);
                })
            }
            else {
                callback(res, errorhandlingResponse);
            }
        });
    }

    //query: list of leagues user belongs to
    LeagueController.getLeagues = function (req, res, userID, callback) {
        //what do we send back if something goes wrong?
        var errorhandlingResponse = { "success": false, "leagueCount": 0 };

        UserXLeague.find({ "userID": userID }, function (err, dataUserXLeagues) {
            if (err) {
                callback(res, errorhandlingResponse);
            }
            if (dataUserXLeagues) {
                var array_userleagues = [];
                for (var i = 0; i < dataUserXLeagues.length; i++) {
                    array_userleagues.push(dataUserXLeagues[i].leagueID);
                }
                //expansion point, add in years and league types to the query and output
                League.find({ "_id": { $in: arraydevices } }, function (err, dataLeague) {
                    if (err) {
                        callback(res, errorhandlingResponse);
                    }
                    if (dataLeague) {
                        var array_leagues = [];
                        for (var i = 0; i < dataLeague.length; i++) {
                            for (var x = 0; x < dataUserXLeagues.length; x++) {
                                if (dataUserXLeagues[x].leagueID.toString() == dataLeague[i]._id.toString()) {
                                    array_leagues.push({ "leagueName" : dataLeague[i].leagueName, "roleID": dataUserXLeagues[x].roleID.toString()})
                                }
                            }
                        }
                        var jsonResponse = { "success": true, "leagueCount": dataLeague.length, "leagues" : array_leagues};
                        callback(res, jsonResponse);
                    } 
                    else {
                        callback(res, errorhandlingResponse);
                    }
                });
            }
            else {
                callback(res, errorhandlingResponse);
            }
        });
    }

})(module.exports);