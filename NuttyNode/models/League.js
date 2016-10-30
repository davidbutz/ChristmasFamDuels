//models/League
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var LeaguesSchema = new Schema({
    leagueName: String,     
    leagueYear: Number
});

module.exports = mongoose.model('League', LeaguesSchema);