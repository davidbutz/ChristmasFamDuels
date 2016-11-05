module.exports = function (app, settings) {
    //REQUIRED to act as a route. (API)
    var Week = require('../models/Week.js');
    var LineUp = require('../models/LineUp.js');
    var UserXLeague = require('../models/UserXLeague.js');
    var setlineupcontroller = require('../controllers/SetLineupController.js');
    var res = "";
    
    var url = require('url'), 
        express = require('express'), 
        rRouter = express.Router();
    
    //run every hour, synce every 12 hours, kick off every week!
    var iteration = 0, minutes = 60, synchours = 12, the_interval = minutes * 60 * 1000;
    var synceinterval = 0;
    var debugging = true;
    
    rRouter.use(function (req, res, next) {
        next();
    });
    
    function runLoop() {
        if (debugging) {
            console.log(iteration);
        }
        if (synceinterval >= synchours) {
            synceinterval = 0;
            
            //for the current week...
            setlineupcontroller.getCurrentWeekID(res, function (res, currentweekJSON) {
                //if successful..
                if (currentweekJSON.success) {
                    var currentWeekID = currentweekJSON._id.toString();
                    if (currentWeekID != previousWeekID) {

                    }
                    //get all the people 
                    UserXLeague.find({}, function (err, dataUserXLeagues) {
                        arrayUserXLeague = [];
                        for (var a = 0; a < dataUserXLeagues.length; a++) {
                            arrayUserXLeague.push({ "_id": dataUserXLeagues[a]._id.toString() });
                        }
                        //and Lineups for the week...
                        LineUp.find({"weekID": currentweekJSON._id.toString()}, function (err, dataLineUps) {
                            arrayLineUp = [];
                            for (var b = 0; b < dataLineUps.length; b++) {
                                arrayLineUp.push({ "userxleagueID": dataLineUps[b].userxleagueID.toString() });
                            }
                            //without any lineups...
                            arrayMissingLineUp = [];
                            for (var c = 0; c < arrayUserXLeague.length; c++) {
                                var found = false;
                                for (var d = 0; d < arrayLineUp.length; d++) {
                                    if (arrayUserXLeague[c]._id == arrayLineUp[d].userxleagueID) {
                                        found = true;
                                        break;
                                    }
                                }
                                if (!found) {
                                    arrayMissingLineUp.push(arrayUserXLeague[c]._id);
                                }
                            }
                            //get the previous week
                            var currentDate = new Date();
                            currentDate.setDate(currentDate.getDate() - 4);
                            var queryDate = dateFormat(new Date(currentDate), "%Y-%m-%d %H:%M:%S", false);
                            var year = currentDate.getFullYear();
                            Week.find({ "weekStart" : { $lte : new Date(queryDate) } }).sort({ "weekEnd": -1 }).limit(1).exec(function (err, dataWeeks) {
                                if (err) {
                                    console.log("something with Week.find went wrong");
                                }
                                else {
                                    if (dataWeeks) {
                                        var previousweekID = dataWeeks[0]._id.toString();
                                        //get the lineups from last week
                                        LineUp.find({ "weekID": previousweekID }, function (err, dataprevLineUps) {
                                            arrayprevLineUp = [];
                                            for (var e = 0; e < dataprevLineUps.length; e++) {
                                                for (var f = 0; f < arrayMissingLineUp.length; f++) {
                                                    if (dataprevLineUps[e].userxleagueID == arrayMissingLineUp[f]._id) {
                                                        //create a lineup based on that week...
                                                        createLineUp({ "userxleagueID": dataprevLineUps[e].userxleagueID, "weekID": currentWeekID, "songID": dataprevLineUps[e].songID, "artistID": dataprevLineUps[e].artistID, "releaseID": dataprevLineUps[e].releaseID });
                                                    }
                                                }
                                            }
                                        });
                                    }
                                    else {
                                        console.log("there wasnt a previous week?");
                                    }
                                }

                            });
                        });
                    });
                    previousWeekID = currentWeekID;
                }
                else {
                    if (debugging) {
                        console.log("there was an issue with currentweekJSON.success");
                    }
                }
            });
        }
        iteration += 1;
        synchours += 1;
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

    function createLineUp(lineUpJSON){
        var newLineUp = new LineUp(lineUpJSON);
        newLineUp.save(function (err) {
            if (err) {
                console.log(err);
            }
        });
    }

    setInterval(runLoop, the_interval);
    
    app.use('/api/syncassurance', rRouter);
}; 