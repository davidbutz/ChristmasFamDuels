(function (ChristmasFamDuelsController) {
    //DB models used.
    var League = require('../models/League.js');
    var UserXLeague = require('../models/UserXLeague.js');
    var Login = require('../models/Login.js');
    var User = require('../models/User.js');
    var PasswordResetRequest = require("../models/PasswordResetRequest.js");
    var NotificationToken = require("../models/NotificationToken.js");

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


    //user has requested a password reset, they know their email, but not their password.
    ChristmasFamDuelsController.resetPassword = function (req, res, email, platform, callback) {
        
        //generate a token.
        var reset_token = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = crypto.randomBytes(1)[0] % 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
        
        //Place a record into PasswordResetRequests
        var newPasswordResetRequests = new PasswordResetRequest({
            username : email,
            requesttoken : reset_token
        });
        
        newPasswordResetRequests.save(function (err) {
            if (err)
                console.log("ERROR saving newPasswordResetRequests: " + err);
            
            //REQUIRED to communicate with AWS.
            var AWS = require('aws-sdk-promise');
            var cloudconfig = require('../cloud/index.js');
            var cloudsettings = {
                cloudconfig: cloudconfig
            };
            var profile = cloudsettings.cloudconfig().cloud_aws;
            AWS.config.update(profile);
            
            var productionurl = settings.config().ProductionWeb.toString() + "/resetPassword?requesttoken=" + reset_token;
            var ses = new AWS.SES({ apiVersion: '2010-12-01' });
            var to = [email];
            var from = cloudsettings.cloudconfig().christmasFamDuelsEmail;
            var messagebody = "You have requested to reset your password.<br>";
            messagebody += "Please click <a href=\"" + productionurl + "\"> THIS LINK </a> to reset your password";
            messagebody += "<br><br>If you have not requested this reset, please contact NuttyRobot (emailresetconcern@nuttyrobot.com)";
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
                        Data: 'Christmas Fam Duels - Reset Password Request'
                    }
                }
            }
            
            ses.sendEmail(params, function (err, data) {
                if (err) {
                    console.log(err);
                    callback(res, { "status": "failure" });
                }
                if (data.MessageId) {
                    callback(res, { "status": "success" });
                }
                else {
                    console.log(data);
                    callback(res, data);
                }
            });
        });
    }
    
    //user has clicked the web page - or native app- and is pushing request back
    ChristmasFamDuelsController.changePassword = function (req, res, token, password, callback) {
        //Validate token:
        var newpassword = password; // simply to avoid confusion...
        PasswordResetRequest.findOne({ requesttoken: token }, function (err, request) {
            if (request) {
                // token valid, i have the username from the request.username...
                // simply update the password here
                var conditions = { username: request.username };
                var update = { $set: { password: newpassword } };
                var options = { upsert: true };
                Users.update(conditions, update, options, mongocallback);
                callback(res, { "status": "success", "message": "password changed" });
            }
            else {
                callback(res, { "status": "fail", "message": "not a valid token" });
            }
        });
    }
    
    //user simply logs in and we capture their unique_id
    ChristmasFamDuelsController.saveiOSNotificationToken = function (req, res, notification_token, leagueID, userID, callback) {
        //see if it exists in Mongo.
        NotificationToken.findOne({ "notification_token_id" : notification_token, "leagueID" : leagueID, "type" : "iOS" }, function (err, notificationtoken) {
            if (notificationtoken) {
                if (debugging) {
                    console.log("its ok, we have it already, just callback with success.")
                }
                callback(res, { "success": true });
            }
            else {
                
                //REQUIRED to communicate with AWS.
                var AWS = require('aws-sdk-promise');
                var cloudconfig = require('../cloud/index.js');
                var cloudsettings = {
                    cloudconfig: cloudconfig
                };
                var profile = cloudsettings.cloudconfig().cloud_aws;
                AWS.config.update(profile);
                var sns = new AWS.SNS();
                var params = {
                    PlatformApplicationArn: cloudsettings.cloudconfig().iOSPlatformApplicationArn,
                    Token: notification_token,
                    CustomUserData: leagueID.toString()
                };
                sns.createPlatformEndpoint(params, function (err, data) {
                    if (err) {
                        console.log(err, err.stack);
                        //error could be that the endpoint ARN already exists...
                        //given a token: can i get the endpointARN.? not from AWS....
                        //so i have to look internally to find it. Then associate the token with the controller... 
                        //this handles the "hey my device logs into multiple (BOATSHOW) REMOs"
                        NotificationToken.findOne({ "notification_token_id" : notification_token }, function (err, notifToken) {
                            if (notifToken) {
                                var token_endpointARN = notifToken.endpointARN;
                                var notificationtoken = new NotificationToken({
                                    "notification_token_id": notification_token, 	
                                    "leagueID": leagueID,
                                    "userID" : userID,
                                    "endpointARN": token_endpointARN.toString(),	
                                    "type": "iOS"
                                });
                                notificationtoken.save(function (err) {
                                    if (err) {
                                        console.log("ERROR saving saveiOSNotificationToken");
                                        callback(res, { "success": false, "err": "failed to save" });
                                    }
                                    else {
                                        callback(res, { "success": true });
                                    }
                                });
                            }
                            else {
                                callback(res, { "success": false , "error": err.stack });
                            }
                        });
                        //callback(res, { "success": false , "error": err.stack});
                    }
                    else {
                        if (debugging) {
                            console.log(data);
                        }
                        var notificationtoken = new NotificationToken({
                            "notification_token_id": notification_token, 	
                            "leagueID": leagueID,
                            "userID" : userID,
                            "endpointARN": data.EndpointArn.toString(),	
                            "type": "iOS"
                        });
                        notificationtoken.save(function (err) {
                            if (err) {
                                console.log("ERROR saving saveiOSNotificationToken");
                                callback(res, { "success": false });
                            }
                            else {
                                callback(res, { "success": true });
                            }
                        });
                    }
                });
            }
        });
    }


})(module.exports);