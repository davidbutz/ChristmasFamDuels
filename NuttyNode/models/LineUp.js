//models/LineUp
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var LineUpSchema = new Schema({
    userxleagueID: String,
    weekID: String,
    songID: String,         //From MongoDB
    artistID: String,     //From MongoDB
    releaseID: String  //From MongoDB
});

module.exports = mongoose.model('LineUp', LineUpSchema);