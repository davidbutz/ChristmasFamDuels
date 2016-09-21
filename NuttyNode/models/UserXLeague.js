//models/UserXLeague
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var UserXLeaguesSchema = new Schema({
    userID: String,
    leagueID: String,
});

module.exports = mongoose.model('UserXLeagues', UserXLeaguesSchema);