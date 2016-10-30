(function (Authentication) {
    
    var User = require('../models/User.js');
    var League = require('../models/League.js');
    var UserXLeague = require('../models/UserXLeague.js');
    var Login = require('../models/Login.js');
    var crypto = require("crypto");
    
    //variables used during function calls.
    var thisfname = "";
    var thislname = "";
    var thisphoneNumber = "";
    var thisleague_name = "";
    var thisuserid = "";
    var thisleagueid = "";
    
    
    //Authentication is the mechanism for logging into the system.
    //This can be at the local network or production level.
    Authentication.authenticate = function (req, res) {
        return User.findOne({ "username": req.body.username, "password": req.body.password }, function (err, user) {
            if (err)
                res.json({ "status": "fail", "message": err, "token": "" , "fname": "", "lname": "", "account_name": "", "userid" : "", "account_id": "", "cellphone": "" });
            if (user) {
                console.log(user);
                thisfname = user.fname;
                thislname = user.lname;
                if (user.phonenumber) {
                    thisphoneNumber = user.phonenumber;
                }
                User.findOne({ "username": user.username }, function (err, usrresult) {
                    if (err)
                        console.log(err);
                    if (usrresult) {
                        thisuserid = usrresult._id.toString();
                        UserXLeague.findOne({ "userID": usrresult._id.toString() }, function (err, usrxacctresult) {
                            if (err)
                                console.log(err);
                            if (usrxacctresult) {
                                League.findOne({ "_id": usrxacctresult.leagueID.toString() }, function (err, acctresult) {
                                    if (err)
                                        console.log(err);
                                    if (acctresult) {
                                        if (acctresult.account_name) {
                                            thisleague_name = acctresult.account_name;
                                            thisleagueid = acctresult._id.toString();
                                        }
                                        var login_token = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
                                            var r = crypto.randomBytes(1)[0] % 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
                                            return v.toString(16);
                                        });
                                        //send new login_token, along with user_id to the MongoDB with an expiration of 24hrs. (now 30 days)
                                        var validuntil = new Date().getTime() + 60 * 60 * 24 * 1000 * 30;
                                        
                                        jsonLogin = { "user_id": thisuserid, "login_token": login_token, "validuntil": validuntil }
                                        var logins = new Login(jsonLogin);
                                        logins.save(function (err) {
                                            if (err)
                                                console.log(err);
                                        });
                                        res.json({ "status": "success", "message": "token", "token": login_token , "fname": thisfname, "lname": thislname, "account_name": thisleague_name, "userid" : thisuserid, "account_id": thisleagueid, "cellphone" : thisphoneNumber });
                                    }
                                })
                            }
                            else {
                                var login_token = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
                                    var r = crypto.randomBytes(1)[0] % 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
                                    return v.toString(16);
                                });
                                //send new login_token, along with user_id to the MongoDB with an expiration of 24hrs. (now 30 days)
                                var validuntil = new Date().getTime() + 60 * 60 * 24 * 1000 * 30;
                                
                                jsonLogin = { "user_id": thisuserid, "login_token": login_token, "validuntil": validuntil }
                                var logins = new Login(jsonLogin);
                                logins.save(function (err) {
                                    if (err)
                                        console.log(err);
                                });
                                res.json({ "status": "success", "message": "token", "token": login_token , "fname": thisfname, "lname": thislname, "account_name": "", "userid" : thisuserid, "account_id": "", "cellphone" : thisphoneNumber });
                            }
                        })
                    }
                })
            }
            else {
                res.json({ "status": "fail", "message": "not valid", "token": ""  , "fname": "", "lname": "", "account_name": "", "userid" : "", "account_id": "", "cellphone" : "" });
            }
        });
    };
    
    //addNewUser is a private function for this page. It is used to create the user.
    function addNewUser(req) {
        var userobj;
        var cellPhone = "";
        if (req.cellphone) {
            cellPhone = req.cellphone
        }
       
        var newuser = { "fname": req.fname, "lname": req.lname, "username": req.username, "password": req.password, "phonenumber": cellPhone }
        var userobj = new User(newuser);
        
        userobj.save(function (err) {
            if (err)
                console.log(err);
        });
    }
    
    Authentication.addLeagueMember = function (leagueID, userID, callback) {
        //what do we send back if something goes wrong?
        var errorhandlingResponse = { "success": false };
        
        UserXLeague.find({ "userID": user_id, "leagueID": leagueID }, function (err, dataUserXLeague) {
            
            if (dataUserXLeague) {
                console.log("addLeagueMember - user exists in league already.")
                callback(errorhandlingResponse);
            }
            else {
                var newUserXLeague = new UserXLeague({ "userID": user_id, "leagueID": leagueID, "roleID" : 2 });
                newUserXLeague.save(function (err) {
                    if (err) {
                        console.log(err);
                        callback(errorhandlingResponse);
                    }
                    else {
                        callback({ "success": true });
                    }
                });
            }
        });
    }
    
    Authentication.getAccountInformationFromToken = function (req, res, token, callback) {
        Login.findOne({ "login_token": token } , function (err, loginresult) {
            User.findOne({ _id : loginresult.user_id }, function (err, users) {
                if (err) {
                    console.log(err);
                    resjson = {
                        success: false
                    }
                    callback(res, resjson);
                }
                
                if (users) {
                    
                    UserXLeague.findOne({ "userID": users._id.toString() }, function (err, usrxacctresult) {
                        if (err) {
                            console.log(err);
                            resjson = {
                                success: false
                            }
                            callback(res, resjson);
                        }
                        if (usrxacctresult) {
                            League.findOne({ "_id": usrxacctresult.leagueID.toString() }, function (err, acctresult) {
                                if (err) {
                                    console.log(err);
                                    resjson = {
                                        success: false
                                    }
                                    callback(res, resjson);
                                }
                                if (acctresult) {
                                    var cellPhone = "";
                                    if (users.phonenumber) {
                                        cellPhone = users.phonenumber;
                                    }
                                    resjson = { success: true, username: users.username, authenticationtoken: token, userid: users._id.toString(), account_id: acctresult._id.toString(), firstname: users.fname, lastname: users.lname, account_name: acctresult.account_name, password: users.password , cellphone: cellPhone }
                                    callback(res, resjson);
                                }
                                else {
                                    resjson = {
                                        success: false
                                    }
                                    callback(res, resjson);
                                }
                            });
                        }
                        else {
                            resjson = {
                                success: false
                            }
                            callback(res, resjson);
                        }
                    });
                }
                else {
                    console.log("something is WRONG");
                    resjson = {
                        success: false
                    }
                    callback(res, resjson);
                }
            });
        });
    }
    
    Authentication.iftokenvalid = function (login_token, callback) {
        Login.findOne({ "login_token": login_token }).exec(function (err, loginresult) {
            //callback(err, loginresult);
            if (err) {
                callback(err, false);
            }
            if (loginresult) {
                if (loginresult.validuntil >= new Date()) {
                    //return true;
                    callback(err, true);
                }
                else {
                    console.log("no longer valid");
                    //return false;
                    callback(err, false);
                }
            }
            else {
                callback(err, false);
            }
        });
    }
    
    Authentication.register = function (req, res, callback) {
        return User.findOne({ "username": req.username, "password": req.password }, function (err, userresult) {
            if (err)
                res.json({ "status": "fail", "message": err, "account_name": "", "email": req.username , "password": req.password });
            
            if (userresult) {
                //res.json({ "status": "fail", "message": "user already exists", "account_name": ""});
                callback(res, { "status": "fail", "message": "user already exists", "account_name": "", "email": req.username, "password": req.password });
            }
            else {
                addNewUser(req);
                resjson = { "status": "success", "message": "new account, new user", "account_name": "", "email": req.username, "password": req.password }
                callback(res, resjson);
            }
        });
    }

})(module.exports);