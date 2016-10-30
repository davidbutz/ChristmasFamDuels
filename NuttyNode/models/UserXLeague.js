//models/UserXLeague
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var UserXLeaguesSchema = new Schema({
    userID: String,
    leagueID: String,
    roleID: Number
});

module.exports = mongoose.model('UserXLeagues', UserXLeaguesSchema);