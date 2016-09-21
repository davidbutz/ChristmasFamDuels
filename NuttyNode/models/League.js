//models/League
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var LeaguesSchema = new Schema({
    leaguename: String,     
    leagueownerid: String,  
    leagueyear: Number,
    leaguetype: Number
});

module.exports = mongoose.model('League', LeaguesSchema);