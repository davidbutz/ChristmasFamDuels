//models/LineUp
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var LineUpsSchema = new Schema({
    userxleagueID: String,
    weekID: String,
    songID: String,     //From MongoDB
    artistID: String,     //From MongoDB
    songartistID: String  //From MongoDB
});

module.exports = mongoose.model('LineUps', LineUpSchema);